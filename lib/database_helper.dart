import 'dart:async';
import 'dart:math';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:libsql_dart/libsql_dart.dart';
import 'package:mutex/mutex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import 'l10n/app_localizations.dart';
part 'database_helper.freezed.dart';

class OnlineModel with ChangeNotifier {
  bool _isOnline = false;
  bool get isOnline => _isOnline;

  void online(BuildContext? context) {
    if (!_isOnline && context != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.reconnected),
          backgroundColor: Colors.green,
        ),
      );
    }
    _isOnline = true;
    notifyListeners();
  }

  void offline(BuildContext? context) {
    if (_isOnline && context != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.disconnected),
          backgroundColor: Theme.of(context).colorScheme.error,
          showCloseIcon: true,
        ),
      );
    }
    _isOnline = false;
    notifyListeners();
  }
}

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  DatabaseHelper._init();

  bool _isConnecting = false;

  LibsqlClient? _onlineClient;
  Database? _offlineClient;
  Timer? _retryTimer;
  final OnlineModel _onlineModel = OnlineModel();

  final Completer<void> _initCompleter = Completer<void>();

  OnlineModel get onlineModel => _onlineModel;

  static const String _syncUrl = String.fromEnvironment("TURSO_DATABASE_URL");
  static const String _authToken = String.fromEnvironment("TURSO_AUTH_TOKEN");
  static const Duration _retryInterval = Duration(seconds: 60);

  BuildContext? _context;

  // init completes when the app is either online or offline
  // for the first time
  Future<void> initialize() async {
    if (_initCompleter.isCompleted || _isConnecting) {
      return _initCompleter.future;
    }

    await tryGoOnline(true); // go online

    // Start connectivity listener
    Connectivity().onConnectivityChanged.listen(_handleConnectivityChange);

    return _initCompleter.future;
  }

  // Returns true if online, false if offline
  Future<bool> tryGoOnline(bool doSync) async {
    _isConnecting = true;

    print("Attempting online connection...");

    try {
      // Dispose previous online client if exists
      await _onlineClient?.dispose();
      _onlineClient = null;

      _onlineClient = LibsqlClient(
        _syncUrl,
        authToken: _authToken.isNotEmpty ? _authToken : null,
      );

      await _onlineClient!.connect();

      _stopRetryTimer();

      if (!_initCompleter.isCompleted) {
        _initCompleter.complete();
      }

      if (doSync) {
        // start a sync in the background
        sync().catchError((e) => print("Sync failed: $e"));
      }

      return true;
    } catch (e) {
      return false;
    } finally {
      _isConnecting = false;
    }
  }

  // Returns true if online, false if offline
  Future<bool> goOffline() async {
    if (_onlineClient != null) {
      await _onlineClient?.dispose();
      _onlineClient = null;
    }
    onlineModel.offline(_context);
    _startRetryTimer();

    return false;
  }

  void _handleConnectivityChange(List<ConnectivityResult> results) async {
    // Check if there's any connection, not just WiFi/Mobile
    bool hasConnection = !results.contains(ConnectivityResult.none);

    print("Connectivity changed: $results, Has connection: $hasConnection");

    if (hasConnection && !onlineModel.isOnline) {
      print("Network available, attempting online connection...");
      await tryGoOnline(true);
    } else if (!hasConnection && onlineModel.isOnline) {
      await goOffline();
    }
  }

  void _startRetryTimer() {
    _stopRetryTimer();

    print(
      "Starting online connection retry timer (${_retryInterval.inSeconds}s)...",
    );

    _retryTimer = Timer.periodic(_retryInterval, (timer) async {
      if (onlineModel.isOnline) {
        _stopRetryTimer(); // Stop if we somehow got online
        return;
      }

      print("Retry timer: Attempting online connection...");
      await tryGoOnline(true);
    });
  }

  void _stopRetryTimer() {
    if (_retryTimer != null) {
      print("Stopping online connection retry timer.");
      _retryTimer?.cancel();
      _retryTimer = null;
    }
  }

  // --- Data Access Methods ---

  Future<void> sync() async {
    await _initCompleter.future;
  }

  // Generic Query Method
  Future<List<Map<String, dynamic>>> query(
    String sql, {
    List<Object?>? positional,
    Map<String, Object?>? named,
  }) async {
    await _initCompleter.future; // Ensure initialization is complete

    var resp =
        await _onlineClient?.query(sql, named: named, positional: positional) ??
        [];

    _onlineModel.online(_context);

    return resp;
  }

  // Generic Execute Method (for INSERT, UPDATE, DELETE)
  Future<int> execute(
    String sql, {
    List<Object?>? positional,
    Map<String, Object?>? named,
  }) async {
    await _initCompleter.future;

    var resp =
        await _onlineClient?.execute(
          sql,
          named: named,
          positional: positional,
        ) ??
        0;

    _onlineModel.online(_context);

    return resp;
  }

  // --- Specific Data Fetching Methods ---

  Future<List<Map<String, dynamic>>> fetchCurrentItems() async {
    return await query(
      'SELECT work_title, composer, user_name, user_id, work_id, checkout_timestamp, instance FROM checked_out_works ORDER BY checkout_timestamp DESC',
    );
  }

  Future<List<Map<String, dynamic>>> fetchArchiveItems() async {
    return await query(
      'SELECT work_title, composer, user_name, user_id, work_id, checkout_timestamp, return_timestamp, instance FROM completed_checkouts ORDER BY return_timestamp DESC',
    );
  }

  // --- Existing Methods Adapted ---

  Future<(bool, int)> insertCheckout(
    NewOrExistingWork work,
    NewOrExistingUser user,
  ) async {
    final now = DateTime.now().toIso8601String();

    var checkoutId;
    if (work case ExistingWork(id: final workId)) {
      if (user case ExistingUser(id: final userId)) {
        final existingCheckouts = await query(
          'SELECT checkout_id FROM checkouts WHERE work_id = ? AND user_id = ? AND return_timestamp IS NULL',
          positional: [workId, userId],
        );
        if (existingCheckouts.isNotEmpty) {
          checkoutId = existingCheckouts.first["checkout_id"];
        }
      }
    }

    if (checkoutId != null) {
      // User is checked out, so return the item (update return_timestamp)
      if (checkoutId is! int) {
        throw Exception("Invalid checkout ID type found: $checkoutId");
      }

      await execute(
        'UPDATE checkouts SET return_timestamp = ? WHERE checkout_id = ?',
        positional: [now, checkoutId],
      );

      print(
        "Returned item: workId=$work, userId=$user, checkoutId=$checkoutId",
      );

      return (false, checkoutId);
    } else {
      var tx = await _onlineClient?.transaction();

      if (user case CreateUser(:final id, :final name, :final email)) {
        await tx?.execute(
          "insert into users (user_id, name, email) values (?, ?, ?)",
          positional: [id, name, email],
        );
      }

      if (work case CreateWork(:final id, :final name, :final composer)) {
        await tx?.execute(
          "insert into works (work_id, title, composer) values (?, ?, ?)",
          positional: [id, name, composer],
        );
      }

      print("Checking out item: workId=$work.id, userId=$user.id");

      final id = await tx?.execute(
        'INSERT INTO checkouts (work_id, user_id, checkout_timestamp, return_timestamp, instance) VALUES (?, ?, ?, NULL, ?)',
        positional: [work.id, user.id, now, work.instance],
      );

      print("attempting commit");

      await tx?.commit();

      print("Checked out item: workId=$work, userId=$user, newCheckoutId=$id");

      return (true, id!);
    }
  }

  Future<Map<String, dynamic>?> getWorkById(String workId, int? instance) async {
    print("work and instance $workId $instance");
    final results = await query(
      'SELECT co.work_id, title, composer, co.user_id FROM works left join checkouts co on co.instance = ? and co.work_id = works.work_id WHERE works.work_id = ? AND co.return_timestamp IS NULL',
      positional: [instance, workId],
    );
    return results.isNotEmpty ? results.first : null;
  }

  Future<Map<String, dynamic>?> getUserById(String userIdString) async {
    final results = await query(
      'SELECT user_id, name FROM users WHERE user_id = ?',
      positional: [userIdString],
    );
    print("User by ID: $results");
    return results.isNotEmpty ? results.first : null;
  }

  Future<bool> checkExistingCheckout(String workId, String userIdString) async {
    final results = await query(
      'SELECT checkout_id FROM checkouts WHERE work_id = ? AND user_id = ? AND return_timestamp IS NULL',
      positional: [workId, userIdString],
    );
    return results.isNotEmpty;
  }

  // --- Cleanup ---

  Future<void> dispose() async {
    print("Disposing DatabaseHelper...");
    _stopRetryTimer();
    await _onlineClient?.dispose();
    await _offlineClient?.close();
    _onlineClient = null;
    _offlineClient = null;
    onlineModel.offline(null);
    print("DatabaseHelper disposed.");
  }

  // --- Status ---
  bool get isCurrentlyOnline => onlineModel.isOnline;

  void setContext(BuildContext context) {
    _context = context;
  }
}

@freezed
sealed class NewOrExistingUser with _$NewOrExistingUser {
  const factory NewOrExistingUser.existing(String id) = ExistingUser;
  const factory NewOrExistingUser.create(
    String id,
    String name,
    String? email,
  ) = CreateUser;
}

@freezed
sealed class NewOrExistingWork with _$NewOrExistingWork {
  const factory NewOrExistingWork.existing(String id, int? instance) = ExistingWork;
  const factory NewOrExistingWork.create(
    String id,
    String name,
    String? composer,
    int? instance,
  ) = CreateWork;
}

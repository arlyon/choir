import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:libsql_dart/libsql_dart.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class OnlineModel with ChangeNotifier {
  bool _isOnline = false;
  bool get isOnline => _isOnline;

  void online(BuildContext? context) {
    if (!_isOnline && context != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Reconnected to network.'),
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
          content: Text('Disconnected from network.'),
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

  LibsqlClient? _onlineClient;
  Database? _offlineClient;
  bool _isConnecting = false;
  Timer? _retryTimer;
  final Completer<void> _initCompleter = Completer<void>();
  final OnlineModel _onlineModel = OnlineModel();

  OnlineModel get onlineModel => _onlineModel;

  static const String _syncUrl = String.fromEnvironment("TURSO_DATABASE_URL");
  static const String _authToken = String.fromEnvironment("TURSO_AUTH_TOKEN");
  static const Duration _retryInterval = Duration(seconds: 60);
  static const Duration _syncInterval = Duration(seconds: 60);

  BuildContext? _context;

  Future<void> initialize() async {
    if (_initCompleter.isCompleted || _isConnecting) {
      return _initCompleter.future;
    }
    _isConnecting = true;

    sqfliteFfiInit(); // Uncomment if running on desktop/web

    await _initializeOfflineDb(); // init offline schema
    await _tryGoOnline(); // go online

    // Start connectivity listener
    Connectivity().onConnectivityChanged.listen(_handleConnectivityChange);

    _isConnecting = false;
    if (!_initCompleter.isCompleted) {
      _initCompleter.complete();
    }
    return _initCompleter.future;
  }

  Future<void> _initializeOfflineDb() async {
    try {
      final dir = await getApplicationCacheDirectory();
      final path = '${dir.path}/local.db';
      _offlineClient = await databaseFactory.openDatabase(path);
      print("Offline database initialized at $path");

      // --- Ensure Schema Exists (Crucial for Offline First) ---
      await _executeSchema(_offlineClient);
      print("Offline database schema loaded from lib/schema.sql.");
    } catch (e) {
      print("Error initializing offline database: $e");
      // Handle error appropriately, maybe prevent app from starting
    }
  }

  Future<void> _executeSchema(Database? db) async {
    if (db == null) return;
    try {
      print("Loading schema from lib/schema.sql...");
      final schemaSql = await rootBundle.loadString('lib/schema.sql');
      // Split statements by semicolon, handling potential comments and empty lines
      final statements =
          schemaSql
              .split(';')
              .map((s) => s.trim())
              .where((s) => s.isNotEmpty && !s.startsWith('--'))
              .toList();

      await db.transaction((txn) async {
        for (final statement in statements) {
          if (kDebugMode) print("Executing Schema: $statement");
          await txn.execute(statement);
        }
      });
      print("Schema execution complete.");
    } catch (e) {
      print("Error executing schema from lib/schema.sql: $e");
      // Decide how to handle schema execution errors (e.g., rethrow, log)
    }
  }

  // Returns true if online, false if offline
  Future<bool> _tryGoOnline() async {
    if (_syncUrl.isEmpty) {
      print("Online connection skipped: TURSO_DATABASE_URL not set.");
      return await _goOffline();
    }

    print("Attempting online connection...");
    try {
      final dir = await getApplicationCacheDirectory();
      final path = '${dir.path}/local.db'; // LibSQL still needs a local path

      // Dispose previous online client if exists
      await _onlineClient?.dispose();
      _onlineClient = null;

      _onlineClient = LibsqlClient(
        path,
        syncUrl: _syncUrl,
        authToken: _authToken.isNotEmpty ? _authToken : null,
        syncIntervalSeconds: _syncInterval.inSeconds,
        readYourWrites: true,
      );

      await _onlineClient!.connect();

      print("Online connection successful!");
      onlineModel.online(_context);
      _stopRetryTimer();
      await sync();
      return true;
    } catch (e) {
      print("Online connection failed: $e");
      return await _goOffline();
    }
  }

  // Returns true if online, false if offline
  Future<bool> _goOffline() async {
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
      await _tryGoOnline();
    } else if (!hasConnection && onlineModel.isOnline) {
      await _goOffline();
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
      await _tryGoOnline();
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
    await _initCompleter.future; // Ensure initialization is complete
    if (onlineModel.isOnline && _onlineClient != null) {
      print("Attempting manual sync...");
      try {
        await _onlineClient!.sync();
        print("Manual sync completed.");
      } catch (e) {
        print("Manual sync failed: $e");
        // Consider switching to offline mode on sync failure
        onlineModel.offline(_context);
        await _onlineClient?.dispose();
        _onlineClient = null;
        _startRetryTimer();
      }
    } else {
      print("Sync skipped: Not online or online client not available.");
    }
  }

  // Generic Query Method
  Future<List<Map<String, dynamic>>> query(
    String sql, {
    List<Object?>? positional,
    Map<String, Object?>? named,
  }) async {
    await _initCompleter.future; // Ensure initialization is complete
    try {
      if (onlineModel.isOnline && _onlineClient != null) {
        if (kDebugMode) print("Querying ONLINE: $sql");
        // LibSQL Dart query method returns ResultSet, need to adapt
        final rs = await _onlineClient!.query(
          sql,
          positional: positional,
          named: named,
        );
        // Convert ResultSet to List<Map<String, dynamic>>
        return rs;
      } else if (_offlineClient != null) {
        if (kDebugMode) print("Querying OFFLINE: $sql");
        // Use sqflite query method
        return await _offlineClient!.rawQuery(sql, positional);
      } else {
        throw Exception(
          "Database not initialized (neither online nor offline)",
        );
      }
    } catch (e) {
      print("Query failed ($sql): $e");
      if (onlineModel.isOnline) {
        print("Online query failed, attempting offline fallback...");
        onlineModel.offline(_context); // Assume online is down
        await _onlineClient?.dispose();
        _onlineClient = null;
        _startRetryTimer();
        if (_offlineClient != null) {
          if (kDebugMode) print("Querying OFFLINE (fallback): $sql");
          return await _offlineClient!.rawQuery(sql, positional);
        } else {
          print("Offline fallback failed: Offline DB not available.");
          throw Exception(
            "Online query failed and no offline database available.",
          );
        }
      } else {
        // If offline query failed, rethrow the original exception
        print("Offline query failed.");
        rethrow;
      }
    }
  }

  // Generic Execute Method (for INSERT, UPDATE, DELETE)
  Future<int> execute(
    String sql, {
    List<Object?>? positional,
    Map<String, Object?>? named,
  }) async {
    await _initCompleter.future; // Ensure initialization is complete
    try {
      if (onlineModel.isOnline && _onlineClient != null) {
        if (kDebugMode) print("Executing ONLINE: $sql");
        // LibSQL Dart execute method returns the number of affected rows (usually 0 for INSERTs unless RETURNING is used)
        // or last insert row ID depending on dialect. Let's assume we want last insert ID for inserts.
        // For simplicity here, we might just return the result directly,
        // but LibSQL's execute result might differ from sqflite's.
        // LibSQL returns last insert rowid for inserts.
        final result = await _onlineClient!.execute(
          sql,
          positional: positional,
          named: named,
        );
        return result; // Assuming result is compatible with sqflite's return for common cases
      } else if (_offlineClient != null) {
        if (kDebugMode) print("Executing OFFLINE: $sql");
        // Use sqflite rawInsert, rawUpdate, rawDelete or execute
        // rawInsert returns the last inserted row ID
        // rawUpdate/rawDelete return the number of changes
        // execute doesn't return a useful value here.
        // We need to be more specific based on the SQL command type.
        if (sql.trim().toLowerCase().startsWith('insert')) {
          return await _offlineClient!.rawInsert(sql, positional);
        } else if (sql.trim().toLowerCase().startsWith('update')) {
          return await _offlineClient!.rawUpdate(sql, positional);
        } else if (sql.trim().toLowerCase().startsWith('delete')) {
          return await _offlineClient!.rawDelete(sql, positional);
        } else {
          // For other DDL/DML commands that don't fit above
          await _offlineClient!.execute(sql);
          return 0; // Or handle appropriately
        }
      } else {
        throw Exception(
          "Database not initialized (neither online nor offline)",
        );
      }
    } catch (e) {
      print("Execute failed ($sql): $e");
      if (onlineModel.isOnline) {
        print("Online execute failed, attempting offline fallback...");
        onlineModel.offline(_context); // Assume online is down
        await _onlineClient?.dispose();
        _onlineClient = null;
        _startRetryTimer();
        if (_offlineClient != null) {
          if (kDebugMode) print("Executing OFFLINE (fallback): $sql");
          if (sql.trim().toLowerCase().startsWith('insert')) {
            return await _offlineClient!.rawInsert(sql, positional);
          } else if (sql.trim().toLowerCase().startsWith('update')) {
            return await _offlineClient!.rawUpdate(sql, positional);
          } else if (sql.trim().toLowerCase().startsWith('delete')) {
            return await _offlineClient!.rawDelete(sql, positional);
          } else {
            await _offlineClient!.execute(sql);
            return 0;
          }
        } else {
          print("Offline fallback failed: Offline DB not available.");
          throw Exception(
            "Online execute failed and no offline database available.",
          );
        }
      } else {
        // If offline execute failed, rethrow the original exception
        print("Offline execute failed.");
        rethrow;
      }
    }
  }

  // --- Specific Data Fetching Methods ---

  Future<List<Map<String, dynamic>>> fetchCurrentItems() async {
    return await query(
      'SELECT work_title, user_name, checkout_timestamp FROM checked_out_works ORDER BY checkout_timestamp DESC',
    );
  }

  Future<List<Map<String, dynamic>>> fetchArchiveItems() async {
    return await query(
      'SELECT work_title, user_name, checkout_timestamp, return_timestamp FROM completed_checkouts ORDER BY return_timestamp DESC',
    );
  }

  // --- Existing Methods Adapted ---

  Future<(bool, int)> insertCheckout(String workId, String userIdString) async {
    final now = DateTime.now().toIso8601String();
    final int? userId = int.tryParse(userIdString);
    if (userId == null) {
      throw ArgumentError("Invalid user ID format: $userIdString");
    }

    // Check if the user is already checked out (using the generic query method)
    final existingCheckouts = await query(
      'SELECT checkout_id FROM checkouts WHERE work_id = ? AND user_id = ? AND return_timestamp IS NULL',
      positional: [workId, userId],
    );

    if (existingCheckouts.isNotEmpty) {
      // User is checked out, so return the item (update return_timestamp)
      final checkoutId = existingCheckouts.first["checkout_id"];
      if (checkoutId is! int) {
        throw Exception("Invalid checkout ID type found: $checkoutId");
      }

      await execute(
        'UPDATE checkouts SET return_timestamp = ? WHERE checkout_id = ?',
        positional: [now, checkoutId],
      );
      print(
        "Returned item: workId=$workId, userId=$userId, checkoutId=$checkoutId",
      );
      return (false, checkoutId); // false indicates return, not new checkout
    } else {
      // User is not checked out, so check out the item (insert new record)
      final id = await execute(
        'INSERT INTO checkouts (work_id, user_id, checkout_timestamp, return_timestamp) VALUES (?, ?, ?, NULL)',
        positional: [workId, userId, now],
      );
      print(
        "Checked out item: workId=$workId, userId=$userId, newCheckoutId=$id",
      );
      return (true, id); // true indicates new checkout
    }
  }

  Future<Map<String, dynamic>?> getWorkById(String workId) async {
    final results = await query(
      'SELECT work_id, title, composer FROM works WHERE work_id = ?',
      positional: [workId],
    );
    return results.isNotEmpty ? results.first : null;
  }

  Future<Map<String, dynamic>?> getUserById(String userIdString) async {
    final int? userId = int.tryParse(userIdString);
    if (userId == null) return null;
    final results = await query(
      'SELECT user_id, name FROM users WHERE user_id = ?',
      positional: [userId],
    );
    return results.isNotEmpty ? results.first : null;
  }

  Future<bool> checkExistingCheckout(String workId, String userIdString) async {
    final int? userId = int.tryParse(userIdString);
    if (userId == null) return false;
    final results = await query(
      'SELECT checkout_id FROM checkouts WHERE work_id = ? AND user_id = ? AND return_timestamp IS NULL',
      positional: [workId, userId],
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

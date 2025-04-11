import 'package:flutter/material.dart';
import 'dart:async';

import 'package:libsql_dart/libsql_dart.dart';
import 'package:path_provider/path_provider.dart';

import 'main.dart';

class CheckedOutList extends StatefulWidget {
  final WriteModel writeModel;

  const CheckedOutList({super.key, required this.writeModel});

  @override
  State<CheckedOutList> createState() => _CheckedOutListState();
}

class _CheckedOutListState extends State<CheckedOutList> {
  LibsqlClient? _client;
  Timer? _syncTimer;
  String? _error;
  List<Map<String, dynamic>> _currentItems = [];
  List<Map<String, dynamic>> _archiveItems = [];

  @override
  void initState() {
    super.initState();
    _refreshData(true);

    _syncTimer = Timer.periodic(const Duration(seconds: 60), (timer) {
      _refreshData(true);
    });

    widget.writeModel.addListener(() {
      _refreshData(false);
    });
  }

  @override
  void dispose() {
    _syncTimer?.cancel();
    _client?.dispose();
    super.dispose();
  }

  Future<LibsqlClient> _initializeDb() async {
    final dir = await getApplicationCacheDirectory();
    final path = '${dir.path}/local.db';

    const syncUrl = String.fromEnvironment("TURSO_DATABASE_URL");
    const authToken = String.fromEnvironment("TURSO_AUTH_TOKEN");

    final client =
        LibsqlClient(path)
          ..authToken = authToken
          ..syncUrl = syncUrl
          ..syncIntervalSeconds =
              5 // Or your desired sync interval
          ..readYourWrites = true;

    await client.connect();
    return client;
  }

  Future<Map<String, List<Map<String, dynamic>>>> _fetchData(
    LibsqlClient client,
    bool sync,
  ) async {
    if (sync) {
      await client.sync();
    }

    final currentResults = await client.query(
      'SELECT work_title, user_name, checkout_timestamp FROM checked_out_works ORDER BY checkout_timestamp DESC',
    );

    final archiveResults = await client.query(
      'SELECT work_title, user_name, checkout_timestamp, return_timestamp FROM completed_checkouts ORDER BY return_timestamp DESC',
    );

    return {'current': currentResults, 'archive': archiveResults};
  }

  Future<void> _refreshData(bool sync) async {
    if (!mounted) return;

    try {
      _client ??= await _initializeDb();
      final data = await _fetchData(_client!, sync);
      if (mounted) {
        setState(() {
          _currentItems = data['current']!;
          _archiveItems = data['archive']!;
          _error = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = "Failed to refresh data: $e";
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        await _refreshData(true);
      },
      child: _buildContent(),
    );
  }

  Widget _buildContent() {
    if (_error != null) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: Text(
                _error!,
                style: TextStyle(color: Theme.of(context).colorScheme.primary),
              ),
            ),
          ),
        ],
      );
    }

    if (_currentItems.isEmpty && _archiveItems.isEmpty) {
      return LayoutBuilder(
        // Use LayoutBuilder to get constraints
        builder: (context, constraints) {
          return SingleChildScrollView(
            // Ensure scrollability
            physics: const AlwaysScrollableScrollPhysics(),
            child: ConstrainedBox(
              // Ensure it takes at least viewport height
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: const Center(
                child: Text('No items checked out and archive is empty.'),
              ),
            ),
          );
        },
      );
    }

    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        // List of Current Items
        if (_currentItems.isNotEmpty)
          SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              final item = _currentItems[index];
              final title = item['work_title']?.toString() ?? 'Unknown Title';
              final user = item['user_name']?.toString() ?? 'Unknown User';
              final timestamp =
                  item['checkout_timestamp']?.toString() ?? 'No Date';

              return ListTile(
                title: Text(title),
                subtitle: Text('Checked out by: $user'),
                trailing: Text(timestamp),
                leading: const Icon(Icons.outbox), // Icon for checked out
              );
            }, childCount: _currentItems.length),
          )
        else
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Center(
                child: Text(
                  'No items currently checked out.',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            ),
          ),

        SliverToBoxAdapter(
          child: ExpansionTile(
            title: const Text(
              'Archive',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            children: [
              if (_archiveItems.isNotEmpty)
                ListView.builder(
                  // Use ListView.builder inside ExpansionTile
                  shrinkWrap: true, // Important inside another scroll view
                  physics:
                      const NeverScrollableScrollPhysics(), // Disable scrolling for this inner list
                  itemCount: _archiveItems.length,
                  itemBuilder: (context, index) {
                    final item = _archiveItems[index];
                    final title =
                        item['work_title']?.toString() ?? 'Unknown Title';
                    final user =
                        item['user_name']?.toString() ?? 'Unknown User';
                    final checkoutTs =
                        item['checkout_timestamp']?.toString() ??
                        'No Checkout Date';
                    final returnTs =
                        item['return_timestamp']?.toString() ??
                        'No Return Date';

                    return ListTile(
                      title: Text(title),
                      subtitle: Text(
                        'Checked out by: $user\nReturned: $returnTs',
                      ),
                      trailing: Text('Checked out: $checkoutTs'),
                      leading: const Icon(
                        Icons.archive_outlined,
                      ), // Icon for archived
                      isThreeLine: true,
                    );
                  },
                )
              else
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Center(child: Text('Archive is empty.')),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

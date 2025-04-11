import 'package:flutter/material.dart';
import 'dart:async';

import 'package:libsql_dart/libsql_dart.dart';
import 'package:path_provider/path_provider.dart';

import 'main.dart'; // Import WriteModel

class CheckedOutList extends StatefulWidget {
  final WriteModel writeModel; // Add this line

  const CheckedOutList({
    super.key,
    required this.writeModel,
  }); // Modify constructor

  @override
  State<CheckedOutList> createState() => _CheckedOutListState();
}

class _CheckedOutListState extends State<CheckedOutList> {
  // Access the model via widget.writeModel
  LibsqlClient? _client;
  Timer? _syncTimer;
  bool _isLoading = true;
  String? _error;
  List<Map<String, dynamic>> _currentItems = [];
  List<Map<String, dynamic>> _archiveItems = [];
  bool _showArchive = false; // State for archive visibility

  @override
  void initState() {
    super.initState();
    _initializeAndFetchData();

    // refresh from the cloud every 60s
    _syncTimer = Timer.periodic(const Duration(seconds: 60), (timer) {
      _refreshData(true);
    });

    // reload data if we have written
    widget.writeModel.addListener(() {
      _refreshData(false);
    });
  }

  @override
  void dispose() {
    _syncTimer?.cancel(); // Cancel the timer
    _client?.dispose(); // Dispose the client connection
    super.dispose();
  }

  Future<LibsqlClient> _initializeDb() async {
    final dir = await getApplicationCacheDirectory();
    final path = '${dir.path}/local.db';

    // --- IMPORTANT ---
    // Replace with your actual Turso/LibSQL URL and Auth Token
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
    // You might want to run schema creation here if the DB is new
    // await _ensureSchema(client);
    return client;
  }

  // Example function to ensure schema exists (call from _initializeDb if needed)
  // Future<void> _ensureSchema(LibsqlClient client) async {
  //   // Read schema.sql and execute it
  //   // final schemaSql = await rootBundle.loadString('lib/schema.sql');
  //   // await client.executeMultiple(schemaSql);
  //   print("Schema checked/applied.");
  // }

  // Fetches both current and archived items
  Future<Map<String, List<Map<String, dynamic>>>> _fetchData(
    LibsqlClient client,
    bool sync,
  ) async {
    if (sync) {
      await client.sync();
    }

    // Fetch current items (return_timestamp is NULL)
    final currentResults = await client.query(
      'SELECT work_title, user_name, checkout_timestamp FROM checked_out_works ORDER BY checkout_timestamp DESC',
    );

    // Fetch archive items (return_timestamp is NOT NULL)
    final archiveResults = await client.query(
      'SELECT work_title, user_name, checkout_timestamp, return_timestamp FROM completed_checkouts ORDER BY return_timestamp DESC',
    );

    return {'current': currentResults, 'archive': archiveResults};
  }

  Future<void> _initializeAndFetchData() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Initialize DB only if not already initialized
      _client ??= await _initializeDb();

      final data = await _fetchData(_client!, true);
      if (mounted) {
        setState(() {
          _currentItems = data['current']!;
          _archiveItems = data['archive']!;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        print("Error initializing/fetching data: $e");
        setState(() {
          _error = "Failed to load data: $e";
          _isLoading = false;
        });
      }
    }
  }

  // Method to refresh data, called by timer or pull-to-refresh
  Future<void> _refreshData(bool sync) async {
    if (_client == null || !mounted) return;

    // Optionally show a loading indicator during refresh, though
    // RefreshIndicator handles this visually.
    // setState(() => _isLoading = true); // Uncomment if you want explicit loading state

    try {
      final data = await _fetchData(_client!, sync);
      if (mounted) {
        setState(() {
          _currentItems = data['current']!;
          _archiveItems = data['archive']!;
          _error = null; // Clear previous errors on successful refresh
          // _isLoading = false; // Uncomment if using explicit loading state
        });
      }
    } catch (e) {
      if (mounted) {
        print("Error refreshing data: $e");
        setState(() {
          _error = "Failed to refresh data: $e";
          // _isLoading = false; // Uncomment if using explicit loading state
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
      child: _buildContent(), // Delegate content building
    );
  }

  // Helper method to build the main content area
  Widget _buildContent() {
    // Loading State
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // Error State
    if (_error != null) {
      // Make error message scrollable for RefreshIndicator
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

    // Empty State (Both lists are empty)
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

    // Success State (Data available)
    // Use CustomScrollView for combining different list types + ExpansionTile
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

        // Archive Section (ExpansionTile wrapped in SliverToBoxAdapter)
        SliverToBoxAdapter(
          child: ExpansionTile(
            title: const Text(
              'Archive',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            initiallyExpanded:
                _showArchive, // Controlled state not strictly needed here
            onExpansionChanged: (isExpanded) {
              // Optional: If you needed to persist the expanded state across refreshes
              // setState(() => _showArchive = isExpanded);
            },
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

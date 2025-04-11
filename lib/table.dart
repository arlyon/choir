import 'package:flutter/material.dart';
import 'dart:async';

import 'package:libsql_dart/libsql_dart.dart';
import 'package:path_provider/path_provider.dart';

class CheckedOutList extends StatefulWidget {
  const CheckedOutList({super.key});

  @override
  State<CheckedOutList> createState() => _CheckedOutListState();
}

class _CheckedOutListState extends State<CheckedOutList> {
  late final Future<List<Map<String, dynamic>>> _checkedOutItemsFuture;
  LibsqlClient? _client;
  Timer? _syncTimer;

  @override
  void initState() {
    super.initState();
    _checkedOutItemsFuture = _initializeAndFetchData();
    // Optional: Set up a timer to refresh the list periodically
    // Adjust the duration based on your sync interval and needs
    _syncTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      _refreshData();
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

    final client = LibsqlClient(path)
      ..authToken = authToken
      ..syncUrl = syncUrl
      ..syncIntervalSeconds = 5 // Or your desired sync interval
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


  Future<List<Map<String, dynamic>>> _fetchCheckedOutItems(LibsqlClient client) async {
    final results = await client.query('SELECT work_title, user_name, checkout_timestamp FROM checked_out_works ORDER BY checkout_timestamp DESC');
    return results;
  }

  Future<List<Map<String, dynamic>>> _initializeAndFetchData() async {
    try {
      _client = await _initializeDb();
    } catch (e) {
      print("Error initializing database: $e");
      // Rethrow or return an empty list/handle error appropriately
      rethrow;
    }

    try {
      return await _fetchCheckedOutItems(_client!);
    } catch (e) {
      print("Error fetching data: $e");
      rethrow;
    }
  }

  // Method to refresh data, called by timer or pull-to-refresh
  Future<void> _refreshData() async {
    if (_client != null && mounted) {
      try {
        final newData = await _fetchCheckedOutItems(_client!);
        // Update the state only if the data has actually changed
        // This requires comparing the new list with the old one,
        // or simply triggering a rebuild if FutureBuilder handles it.
        // For simplicity with FutureBuilder, we can re-assign the future.
         if (mounted) {
          setState(() {
             // Re-assigning the future will cause FutureBuilder to rebuild
             _checkedOutItemsFuture = Future.value(newData);
          });
         }
      } catch (e) {
         if (mounted) {
           print("Error refreshing data: $e");
           // Optionally update state to show an error message
           setState(() {
              _checkedOutItemsFuture = Future.error(e);
           });
         }
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    // Wrap the entire FutureBuilder result in RefreshIndicator
    return RefreshIndicator(
      onRefresh: _refreshData,
      child: FutureBuilder<List<Map<String, dynamic>>>(
        future: _checkedOutItemsFuture,
        builder: (context, snapshot) {
          // Handle loading state
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Show loading indicator within a scrollable view for RefreshIndicator
            return ListView(
              children: const [Center(child: CircularProgressIndicator())],
            );
          }

          // Handle error state
          if (snapshot.hasError) {
            // Show error message within a scrollable view
            return ListView(
              children: [Center(child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text('Error loading data: ${snapshot.error}'),
              ))],
            );
          }

          // Handle empty data state
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            // Show empty message within a scrollable view
             return LayoutBuilder( // Use LayoutBuilder to get constraints
               builder: (context, constraints) {
                 return SingleChildScrollView( // Ensure scrollability
                   physics: const AlwaysScrollableScrollPhysics(),
                   child: ConstrainedBox( // Ensure it takes at least viewport height
                     constraints: BoxConstraints(minHeight: constraints.maxHeight),
                     child: const Center(child: Text('No items currently checked out.')),
                   ),
                 );
               }
             );
          }

          // Handle success state (data available)
          final items = snapshot.data!;
          return ListView.builder(
            // physics: const AlwaysScrollableScrollPhysics(), // Already scrollable
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              final title = item['work_title']?.toString() ?? 'Unknown Title';
              final user = item['user_name']?.toString() ?? 'Unknown User';
              final timestamp = item['checkout_timestamp']?.toString() ?? 'No Date';

              return ListTile(
                title: Text(title),
                subtitle: Text('Checked out by: $user'),
                trailing: Text(timestamp),
              );
            },
          );
        },
      ),
    );
  }
}
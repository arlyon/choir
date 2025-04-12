import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/material.dart'; // Keep material import

import 'database_helper.dart'; // Import the database helper
import 'main.dart'; // Keep main import for WriteModel

class CheckedOutList extends StatefulWidget {
  final WriteModel writeModel;

  const CheckedOutList({super.key, required this.writeModel});

  @override
  State<CheckedOutList> createState() => _CheckedOutListState();
}

class _CheckedOutListState extends State<CheckedOutList> {
  // Remove direct client and sync timer
  // LibsqlClient? _client;
  // Timer? _syncTimer;
  String? _error;
  bool _isLoading = true; // Add loading state
  List<Map<String, dynamic>> _currentItems = [];
  List<Map<String, dynamic>> _archiveItems = [];

  @override
  void initState() {
    super.initState();
    DatabaseHelper.instance.initialize().then((_) {
      _refreshData(true); // Initial data load with sync attempt
    });

    widget.writeModel.addListener(() {
      _refreshData(false);
    });
  }

  @override
  void dispose() {
    // Remove timer cancellation and client disposal
    // _syncTimer?.cancel();
    // _client?.dispose();
    super.dispose();
  }

  // Remove _initializeDb and _fetchData, use DatabaseHelper instead

  Future<void> _refreshData(bool sync) async {
    if (!mounted) return;

    // Set loading state only if not already loading (prevents flicker on rapid calls)
    if (!_isLoading) {
      setState(() {
        _isLoading = true;
        _error = null; // Clear previous error on refresh attempt
      });
    }

    try {
      // Ensure DatabaseHelper is initialized (redundant if called in initState/main)
      await DatabaseHelper.instance.initialize();

      if (sync) {
        // Trigger a sync attempt if requested (e.g., on pull-to-refresh)
        await DatabaseHelper.instance.sync();
      }

      // Fetch data using DatabaseHelper methods
      final currentData = await DatabaseHelper.instance.fetchCurrentItems();
      final archiveData = await DatabaseHelper.instance.fetchArchiveItems();

      if (mounted) {
        setState(() {
          _currentItems = currentData;
          _archiveItems = archiveData;
          _error = null;
          _isLoading = false; // Data loaded successfully
        });
      }
    } catch (e) {
      print("Error refreshing data in CheckedOutList: $e");
      if (mounted) {
        setState(() {
          _error =
              "Failed to refresh data. Check connection or logs."; // User-friendly error
          _isLoading = false; // Stop loading on error
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
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      // Keep error display but ensure it's scrollable within RefreshIndicator
      return ListView(
        // Use ListView for scrollability
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.3,
          ), // Add some top padding
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: Column(
                // Use Column for text and maybe a retry button
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    color: Theme.of(context).colorScheme.error,
                    size: 48,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _error!,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.refresh),
                    label: const Text("Retry"),
                    onPressed: () => _refreshData(true), // Retry with sync
                  ),
                ],
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

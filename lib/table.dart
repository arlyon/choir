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
  List<Map<String, dynamic>> _currentItems = []; // Raw data from DB
  List<Map<String, dynamic>> _filteredCurrentItems = []; // Data after filtering
  List<Map<String, dynamic>> _archiveItems = [];

  // Filter state
  Set<String> _selectedPersons = {};
  Set<String> _selectedWorkTitles = {};
  List<String> _availablePersons = [];
  List<String> _availableWorkTitles = [];
  bool _showArchive = false; // State to control archive visibility

  @override
  void initState() {
    super.initState();

    _refreshData(true);

    widget.writeModel.addListener(() {
      _refreshData(false);
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

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
      print("Initializing DatabaseHelper...");
      await DatabaseHelper.instance.initialize(true);
      await DatabaseHelper.instance.tryGoOnline(sync);
      if (sync) {
        print("Syncing!");
        await DatabaseHelper.instance.sync();
      }

      // Fetch data using DatabaseHelper methods
      print("Fetching current items...");
      final currentData = await DatabaseHelper.instance.fetchCurrentItems();
      final archiveData = await DatabaseHelper.instance.fetchArchiveItems();
      print("Done");

      // Extract unique filter options from current items
      final Set<String> persons = {};
      final Set<String> titles = {};
      for (var item in currentData) {
        if (item['user_name'] != null) persons.add(item['user_name']);
        if (item['work_title'] != null) titles.add(item['work_title']);
      }

      if (mounted) {
        setState(() {
          _currentItems = currentData;
          _archiveItems = archiveData;
          _availablePersons = persons.toList()..sort();
          _availableWorkTitles = titles.toList()..sort();
          _applyFilters(); // Apply filters after data is loaded/refreshed
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

  void _applyFilters() {
    setState(() {
      // Wrap with setState to trigger UI updates
      if (_selectedPersons.isEmpty && _selectedWorkTitles.isEmpty) {
        _filteredCurrentItems = List.from(
          _currentItems,
        ); // No filters, show all
      } else {
        _filteredCurrentItems =
            _currentItems.where((item) {
              final personMatch =
                  _selectedPersons.isEmpty ||
                  (_selectedPersons.contains(item['user_name']));
              final titleMatch =
                  _selectedWorkTitles.isEmpty ||
                  (_selectedWorkTitles.contains(item['work_title']));
              return personMatch && titleMatch;
            }).toList();
      }
    });
  }

  // --- Filter UI Methods ---

  // Shows a dialog for selecting filters (Person or Work Title)
  Future<void> _showFilterDialog(
    String filterType,
    List<String> options,
    Set<String> selectedValues,
  ) async {
    Set<String> tempSelected = Set.from(selectedValues);
    String searchQuery = '';

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            List<String> filteredOptions =
                options
                    .where(
                      (option) => option.toLowerCase().contains(
                        searchQuery.toLowerCase(),
                      ),
                    )
                    .toList();

            return AlertDialog(
              title: Text('Filter by $filterType'),
              content: SizedBox(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      decoration: InputDecoration(
                        labelText: 'Search $filterType',
                        prefixIcon: Icon(Icons.search),
                      ),
                      onChanged: (value) {
                        setDialogState(() {
                          searchQuery = value;
                        });
                      },
                    ),
                    Expanded(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: filteredOptions.length,
                        itemBuilder: (context, index) {
                          final option = filteredOptions[index];
                          final isSelected = tempSelected.contains(option);
                          return CheckboxListTile(
                            title: Text(option),
                            value: isSelected,
                            onChanged: (bool? value) {
                              setDialogState(() {
                                if (value == true) {
                                  tempSelected.add(option);
                                } else {
                                  tempSelected.remove(option);
                                }
                              });
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                TextButton(
                  child: const Text('Apply'),
                  onPressed: () {
                    setState(() {
                      if (filterType == 'Person') {
                        _selectedPersons = tempSelected;
                      } else if (filterType == 'Work Title') {
                        _selectedWorkTitles = tempSelected;
                      }
                      _applyFilters(); // Apply the filters
                    });
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Builds the horizontally scrollable filter chip row
  Widget _buildFilterChips() {
    List<Widget> chips = [];

    // Add initial filter chips
    chips.add(
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: ActionChip(
          shape: StadiumBorder(),
          avatar: const Icon(Icons.person_add_alt_1, size: 18),
          label: const Text('Person'),
          onPressed:
              () => _showFilterDialog(
                'Person',
                _availablePersons,
                _selectedPersons,
              ),
        ),
      ),
    );
    chips.add(
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: ActionChip(
          shape: StadiumBorder(),
          avatar: const Icon(Icons.music_note, size: 18),
          label: const Text('Work Title'),
          onPressed:
              () => _showFilterDialog(
                'Work Title',
                _availableWorkTitles,
                _selectedWorkTitles,
              ),
        ),
      ),
    );

    // Add Archive toggle chip
    chips.add(
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: FilterChip(
          label: const Text('Archived'),
          selected: _showArchive,
          onSelected: (bool selected) {
            setState(() {
              _showArchive = selected;
            });
          },
          avatar: Icon(
            Icons.archive_outlined,
            color:
                _showArchive
                    ? Theme.of(context).colorScheme.onSecondaryContainer
                    : Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          shape: StadiumBorder(),
          selectedColor: Theme.of(context).colorScheme.secondaryContainer,
          checkmarkColor: Theme.of(context).colorScheme.onSecondaryContainer,
        ),
      ),
    );

    // Add chips for selected persons
    chips.addAll(
      _selectedPersons.map(
        (person) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: Chip(
            shape: StadiumBorder(),
            label: Text(person),
            onDeleted: () {
              setState(() {
                _selectedPersons.remove(person);
                _applyFilters();
              });
            },
          ),
        ),
      ),
    );

    // Add chips for selected work titles
    chips.addAll(
      _selectedWorkTitles.map(
        (title) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: Chip(
            shape: StadiumBorder(),
            label: Text(title, overflow: TextOverflow.ellipsis),
            onDeleted: () {
              setState(() {
                _selectedWorkTitles.remove(title);
                _applyFilters();
              });
            },
          ),
        ),
      ),
    );

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
      child: Row(children: chips),
    );
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

    // Use _filteredCurrentItems for checking emptiness now
    if (_filteredCurrentItems.isEmpty &&
        _archiveItems.isEmpty &&
        _selectedPersons.isEmpty &&
        _selectedWorkTitles.isEmpty) {
      return LayoutBuilder(
        // Use LayoutBuilder to get constraints
        builder: (context, constraints) {
          return SingleChildScrollView(
            // Ensure scrollability
            physics: const AlwaysScrollableScrollPhysics(),
            child: ConstrainedBox(
              // Ensure it takes at least viewport height
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: SizedBox.expand(),
            ),
          );
        },
      );
    }

    // Main content structure using CustomScrollView
    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(child: _buildFilterChips()),
        if (_filteredCurrentItems.isNotEmpty)
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final item = _filteredCurrentItems[index]; // Use filtered list
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
              },
              childCount: _filteredCurrentItems.length,
            ), // Use filtered list length
          )
        else // Show message if filters result in empty list
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Center(
                child: Text(
                  (_selectedPersons.isEmpty && _selectedWorkTitles.isEmpty)
                      ? 'No items currently checked out.' // Original message
                      : 'No items match the selected filters.', // Filtered message
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            ),
          ),

        // --- Conditionally Display Archive Section ---
        if (_showArchive) ...[
          SliverToBoxAdapter(
            // Add a header for the archive section
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                16.0,
                16.0,
                16.0,
                8.0,
              ), // Adjust padding
              child: Text(
                'Archived Items (${_archiveItems.length})', // Show count
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          ),
          if (_archiveItems.isNotEmpty)
            SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                final item = _archiveItems[index];
                final title = item['work_title']?.toString() ?? 'Unknown Title';
                final user = item['user_name']?.toString() ?? 'Unknown User';
                final checkoutTs =
                    item['checkout_timestamp']?.toString() ??
                    'No Checkout Date';
                final returnTs =
                    item['return_timestamp']?.toString() ?? 'No Return Date';

                return ListTile(
                  title: Text(title),
                  subtitle: Text('Checked out by: $user\nReturned: $returnTs'),
                  trailing: Text('Checked out: $checkoutTs'),
                  leading: const Icon(
                    Icons.archive_outlined,
                  ), // Icon for archived
                  isThreeLine: true,
                );
              }, childCount: _archiveItems.length),
            )
          else // Show message if archive is empty but shown
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                child: Center(
                  child: Text(
                    'Archive is empty.',
                    style: TextStyle(color: Theme.of(context).hintColor),
                  ),
                ),
              ),
            ),
        ],
      ],
    );
  }
}

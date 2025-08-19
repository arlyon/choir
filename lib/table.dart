import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'user_scanner_modal.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:barcode/barcode.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import 'l10n/app_localizations.dart';
import 'database_helper.dart';
import 'main.dart';

const double fontSize = 14.0;

class CheckOutCard extends StatelessWidget {
  final Map<String, dynamic> item;
  final bool isArchived;

  const CheckOutCard({Key? key, required this.item, this.isArchived = false})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    final title = (item['work_title']?.toString() ?? 'Unknown Title');
    final user = item['user_name']?.toString() ?? 'Unknown User';
    final composer = item['composer']?.toString();
    final instance = item['instance']?.toString();
    final checkoutTimestampStr = item['checkout_timestamp']?.toString();
    final returnTimestampStr = item['return_timestamp']?.toString();
    final workId = item['work_id']?.toString();
    final userId = item['user_id']?.toString();

    final relativeCheckoutTime = _formatRelativeTime(
      checkoutTimestampStr,
      context,
    );
    final relativeReturnTime = _formatRelativeTime(returnTimestampStr, context);

    return GestureDetector(
      onTap: () {
        final userBarcodeData = userId ?? "N/A";
        final workBarcodeData =
            workId ?? "" + (instance != null ? " " + instance : "");

        final userBarcodeSvg = Barcode.code128().toSvg(
          userBarcodeData,
          drawText: false,
          width: 400,
          height: 200,
        );
        final workBarcodeSvg = Barcode.code128().toSvg(
          workBarcodeData,
          drawText: false,
          width: 400,
          height: 200,
        );

        HapticFeedback.heavyImpact();
        showModalBottomSheet(
          isScrollControlled: true,

          context: context,
          showDragHandle: true,
          builder: (BuildContext context) {
            return Container(
              padding: EdgeInsets.all(32.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(user),
                  SvgPicture.string(
                    userBarcodeSvg,
                    colorFilter: ColorFilter.mode(
                      Theme.of(context).hintColor,
                      BlendMode.srcIn,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(title + " " + (item['instance']?.toString() ?? "")),
                  SvgPicture.string(
                    workBarcodeSvg,
                    colorFilter: ColorFilter.mode(
                      Theme.of(context).hintColor,
                      BlendMode.srcIn,
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(width: 1, color: Theme.of(context).splashColor),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              Row(
                children: [
                  // instance 3 characters prefixed with #
                  Text(
                    '#${(instance ?? "NAN").toString().padLeft(3, '0')} ',
                    style: GoogleFonts.ibmPlexMono(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        spacing: 4.0,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: fontSize,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (composer != null && composer.isNotEmpty)
                            Text(
                              composer,
                              style: TextStyle(
                                fontSize: fontSize,
                                color: Theme.of(context).hintColor,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                        ],
                      ),
                      Text(user, style: const TextStyle(fontSize: fontSize)),
                    ],
                  ),
                  Spacer(),
                  Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            margin: const EdgeInsets.only(bottom: 3),
                            child: Icon(
                              Icons.outbox_sharp,
                              size: fontSize,
                              color: Theme.of(context).hintColor,
                            ),
                          ),
                          SizedBox(width: 2),
                          Text(
                            relativeCheckoutTime,
                            style: TextStyle(
                              fontSize: fontSize,
                              color: Theme.of(context).hintColor,
                            ),
                          ),
                        ],
                      ),
                      if (isArchived)
                        Row(
                          children: [
                            Container(
                              margin: const EdgeInsets.only(bottom: 3),
                              child: Icon(
                                Icons.move_to_inbox_sharp,
                                size: fontSize,
                                color: Theme.of(context).hintColor,
                              ),
                            ),
                            SizedBox(width: 2),
                            Text(
                              relativeReturnTime,
                              style: TextStyle(
                                fontSize: fontSize,
                                color: Theme.of(context).hintColor,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatRelativeTime(String? timestampStr, BuildContext context) {
    if (timestampStr == null) {
      return 'Unknown date';
    }
    try {
      final dateTime = DateTime.parse(timestampStr).toLocal();
      return timeago.format(dateTime, locale: 'en_short');
    } catch (e) {
      print("Error parsing timestamp '$timestampStr': $e");
      return 'Invalid Date';
    }
  }
}

class CheckedOutList extends StatefulWidget {
  final WriteModel writeModel;

  const CheckedOutList({Key? key, required this.writeModel}) : super(key: key);

  @override
  _CheckedOutListState createState() => _CheckedOutListState();
}

class _CheckedOutListState extends State<CheckedOutList> {
  String? _error;
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();
  List<Map<String, dynamic>> _currentItems = [];
  List<Map<String, dynamic>> _filteredCurrentItems = [];
  List<Map<String, dynamic>> _archiveItems = [];
  Set<String> _selectedPersons = {};
  String? _currentUserId;
  Set<String> _selectedWorkTitles = {};
  Map<String, String> _availablePersons = {};
  Map<String, String> _availableWorkTitles = {};
  bool _showArchive = false;

  @override
  void initState() {
    super.initState();

    _refreshData(false);

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

    try {
      print("refreshing data");
      await DatabaseHelper.instance.initialize();
      if (!await DatabaseHelper.instance.tryGoOnline(sync)) {
        throw Exception("Failed to connect to database.");
      }

      final data = await Future.wait([
        DatabaseHelper.instance.fetchCurrentItems(),
        DatabaseHelper.instance.fetchArchiveItems(),
      ]);

      final currentData = data[0];
      final archiveData = data[1];

      final Map<String, String> persons = {};
      final Map<String, String> titles = {};
      for (var item in currentData) {
        if (item['user_id'] != null && item['user_name'] != null) {
          persons[item['user_id'].toString()] = item['user_name'];
        }
        if (item['work_id'] != null && item['work_title'] != null) {
          titles[item['work_id'].toString()] = item['work_title'];
        }
      }

      if (mounted) {
        setState(() {
          _currentItems = currentData;
          _archiveItems = archiveData;
          _availablePersons = persons;
          _availableWorkTitles = titles;
          _applyFilters();
          _error = null;
        });
      }
    } catch (e) {
      print("Error refreshing data in CheckedOutList: $e");
      if (mounted) {
        setState(() {
          _error = "Failed to refresh data. Check connection or logs.";
        });
      }
    }
  }

  void _applyFilters() {
    setState(() {
      if (_selectedPersons.isEmpty && _selectedWorkTitles.isEmpty) {
        _filteredCurrentItems = List.from(_currentItems);
      } else {
        _filteredCurrentItems =
            _currentItems.where((item) {
              final personMatch =
                  _selectedPersons.isEmpty ||
                  (_selectedPersons.contains(item['user_id'].toString()));
              final titleMatch =
                  _selectedWorkTitles.isEmpty ||
                  (_selectedWorkTitles.contains(item['work_id'].toString()));
              return personMatch && titleMatch;
            }).toList();
      }
    });
  }

  Future<void> _showFilterDialog(
    String filterType,
    Map<String, String> options,
    Set<String> selectedValues,
  ) async {
    Set<String> tempSelected = Set.from(selectedValues);
    String searchQuery = '';

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            List<MapEntry<String, String>> filteredOptions =
                options.entries
                    .where(
                      (entry) => entry.value.toLowerCase().contains(
                        searchQuery.toLowerCase(),
                      ),
                    )
                    .toList();

            final search = AppLocalizations.of(context)!.search;

            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              elevation: 5,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8.0, 16.0, 8.0, 8.0),
                child: SizedBox(
                  width: double.maxFinite,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        decoration: InputDecoration(
                          labelText: '$search $filterType',
                          prefixIcon: const Icon(Icons.search),
                          filled: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: BorderSide.none,
                          ),
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
                            final entry = filteredOptions[index];
                            final isSelected = tempSelected.contains(entry.key);
                            return CheckboxListTile(
                              title: Text(entry.value),
                              value: isSelected,
                              onChanged: (bool? value) {
                                setDialogState(() {
                                  if (value == true) {
                                    tempSelected.add(entry.key.toString());
                                  } else {
                                    tempSelected.remove(entry.key.toString());
                                  }
                                });
                              },
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            child: Text(AppLocalizations.of(context)!.cancel),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            child: Text(AppLocalizations.of(context)!.apply),
                            onPressed: () {
                              setState(() {
                                if (filterType ==
                                    AppLocalizations.of(context)!.person) {
                                  _selectedPersons =
                                      tempSelected.cast<String>();
                                } else if (filterType ==
                                    AppLocalizations.of(context)!.workTitle) {
                                  _selectedWorkTitles =
                                      tempSelected.cast<String>();
                                }
                                _applyFilters();
                              });
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildFilterChips() {
    List<Widget> chips = [];
    final theme = Theme.of(context);

    chips.add(
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: FilterChip(
          label: Text(AppLocalizations.of(context)!.archived),
          labelPadding: EdgeInsets.only(top: 3, left: 6, right: 6),
          showCheckmark: false,
          selected: _showArchive,
          onSelected: (bool selected) {
            HapticFeedback.mediumImpact();
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

    chips.add(
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: ActionChip(
          shape: StadiumBorder(),
          avatar: const Icon(Icons.person_add_alt_1, size: 18),
          label: Text(AppLocalizations.of(context)!.person),
          labelPadding: EdgeInsets.only(top: 3, left: 6, right: 6),
          backgroundColor:
              _selectedPersons.isNotEmpty
                  ? theme.colorScheme.secondaryContainer
                  : null,
          onPressed:
              () => _showFilterDialog(
                AppLocalizations.of(context)!.person,
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
          label: Text(AppLocalizations.of(context)!.workTitle),
          labelPadding: EdgeInsets.only(top: 3, left: 6, right: 6),
          backgroundColor:
              _selectedWorkTitles.isNotEmpty
                  ? theme.colorScheme.secondaryContainer
                  : null,
          onPressed:
              () => _showFilterDialog(
                AppLocalizations.of(context)!.workTitle,
                _availableWorkTitles,
                _selectedWorkTitles,
              ),
        ),
      ),
    );

    // chips.add(
    //   Padding(
    //     padding: const EdgeInsets.symmetric(horizontal: 4.0),
    //     child: GestureDetector(
    //       onLongPress: () {
    //         showModalBottomSheet(
    //           context: context,
    //           builder: (context) => UserScannerModal(),
    //         );
    //       },
    //       child: FilterChip(
    //         label: Text(AppLocalizations.of(context)!.me),
    //         showCheckmark: false,
    //         selected: _selectedPersons.isNotEmpty,
    //         onSelected: (bool selected) async {
    //           HapticFeedback.mediumImpact();
    //           const storage = FlutterSecureStorage();
    //           final userId = await storage.read(key: 'user_id');
    //           setState(() {
    //             _selectedPersons.clear();
    //             if (selected && userId != null) {
    //               _selectedPersons.add(userId);
    //             } else if (userId == null) {
    //               showModalBottomSheet(
    //                 context: context,
    //                 builder: (context) => UserScannerModal(),
    //               );
    //               return;
    //             }
    //             _applyFilters();
    //           });
    //         },
    //         avatar: Icon(
    //           Icons.face,
    //           color:
    //               _selectedPersons.isNotEmpty
    //                   ? Theme.of(context).colorScheme.onSecondaryContainer
    //                   : Theme.of(context).colorScheme.onSurfaceVariant,
    //         ),
    //         shape: StadiumBorder(),
    //         selectedColor: Theme.of(context).colorScheme.secondaryContainer,
    //         checkmarkColor: Theme.of(context).colorScheme.onSecondaryContainer,
    //       ),
    //     ),
    //   ),
    // );

    chips.addAll(
      _selectedPersons
          .where((p) => p != _currentUserId)
          .map(
            (person) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Chip(
                shape: StadiumBorder(),
                label: Text(_availablePersons[person] ?? person),
                labelPadding: EdgeInsets.only(top: 3, left: 6, right: 6),
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

    chips.addAll(
      _selectedWorkTitles.map(
        (title) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: Chip(
            shape: StadiumBorder(),
            label: Text(
              _availableWorkTitles[title] ?? title,
              overflow: TextOverflow.ellipsis,
            ),
            labelPadding: EdgeInsets.only(top: 3, left: 6, right: 6),
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
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
      child: Row(children: chips),
    );
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      key: _refreshIndicatorKey,
      onRefresh: () async {
        await _refreshData(true);
      },
      child: _buildContent(),
    );
  }

  Future<(String, String)?> _getUserId() async {
    const storage = FlutterSecureStorage();
    final userId = await storage.read(key: 'user_id');
    if (userId == null) return null;
    final userBarcodeData = userId;
    final userBarcodeSvg = Barcode.code128().toSvg(
      userBarcodeData,
      drawText: false,
      width: 500,
      height: 200,
    );
    _currentUserId = userId;
    return (userId, userBarcodeSvg);
  }

  Widget _buildContent() {
    List<Widget> content = [];

    if (_error != null) {
      content.add(
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: Text(
                _error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          ),
        ),
      );
    } else {
      content.addAll([
        if (_filteredCurrentItems.isNotEmpty)
          SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              final item = _filteredCurrentItems[index];
              return CheckOutCard(item: item);
            }, childCount: _filteredCurrentItems.length),
          )
        else
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Center(
                child: Text(
                  (_selectedPersons.isEmpty && _selectedWorkTitles.isEmpty)
                      ? AppLocalizations.of(context)!.noItems
                      : AppLocalizations.of(context)!.noFilterItems,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            ),
          ),
        if (_showArchive) ...[
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
              child: Text(
                AppLocalizations.of(
                  context,
                )!.archivedItems(_archiveItems.length),
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
                return CheckOutCard(item: item, isArchived: true);
              }, childCount: _archiveItems.length),
            )
          else
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                child: Center(
                  child: Text(
                    AppLocalizations.of(context)!.archiveEmpty,
                    style: TextStyle(color: Theme.of(context).hintColor),
                  ),
                ),
              ),
            ),
        ],
      ]);
    }

    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        FutureBuilder<(String, String)?>(
          future: _getUserId(),
          builder: (context, snapshot) {
            if (snapshot.data != null) {
              return SliverToBoxAdapter(
                child: AnimatedSize(
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeInOut,
                  child: SizedBox(
                    height:
                        _selectedPersons.contains(snapshot.data!.$1)
                            ? 180
                            : 0, // 200 (barcode height) + 32 (padding)
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Center(
                        child: SvgPicture.string(
                          snapshot.data!.$2,
                          colorFilter: ColorFilter.mode(
                            Theme.of(context).hintColor,
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            } else {
              return SliverToBoxAdapter(child: SizedBox.shrink());
            }
          },
        ),
        SliverToBoxAdapter(child: _buildFilterChips()),
        ...content,
      ],
    );
  }
}

import 'dart:io';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'database_helper.dart';
import 'l10n/app_localizations.dart';
import 'scanner_modal.dart';
import 'checkouts_view.dart';
import 'users_view.dart';
import 'works_view.dart';
import 'util.dart';
import 'barcode_generator.dart';

void main() {
  runApp(const MyApp());
}

class WriteModel with ChangeNotifier {
  int _count = 0;
  int get count => _count;

  void increment() {
    _count += 1;
    notifyListeners();
  }
}

// Fictitious brand color.
const _brandBlue = Color.fromARGB(255, 67, 123, 255);

CustomColors lightCustomColors = const CustomColors(danger: Color(0xFFE53935));
CustomColors darkCustomColors = const CustomColors(danger: Color(0xFFEF9A9A));

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    // Wrap MaterialApp with a DynamicColorBuilder.
    return DynamicColorBuilder(
      builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
        final baseLightTheme = ThemeData(
          useMaterial3: true,
          colorScheme: lightDynamic,
          brightness: Brightness.light,
          fontFamily: 'AktivGrotesk',
        );
        final baseDarkTheme = ThemeData(
          useMaterial3: true,
          colorScheme: darkDynamic,
          brightness: Brightness.dark,
          fontFamily: 'AktivGrotesk',
        );

        return MaterialApp(
          theme: baseLightTheme,
          darkTheme: baseDarkTheme,
          home: const MyHomePage(title: 'SSKor Note App'),
          localizationsDelegates: [
            AppLocalizations.delegate, // Add this line
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: [
            Locale('en'), // English
            Locale('nb'),
          ],
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late WriteModel _writeModel;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _writeModel = WriteModel();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    DatabaseHelper.instance.setContext(context);
    DatabaseHelper.instance.initialize();
  }

  void _openScanner() {
    HapticFeedback.heavyImpact();
    // Show the multi-step modal
    showModalBottomSheet(
      showDragHandle: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30.0)),
      ),
      context: context,
      isScrollControlled: true,
      builder: (context) => MultiStepModal(onSuccess: _writeModel.increment),
    );
  }

  void _openBarcodeSheetGenerator() async {
    HapticFeedback.heavyImpact();

    try {
      final works = await DatabaseHelper.instance.fetchAllWorks();

      if (!mounted) return;

      showModalBottomSheet(
        showDragHandle: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(30.0)),
        ),
        context: context,
        isScrollControlled: true,
        builder:
            (context) => WorkSelectionModal(
              works: works,
              onWorkSelected:
                  (work, instanceCount) =>
                      BarcodeGenerator.generateBarcodeSheet(
                        work,
                        instanceCount,
                        context,
                      ),
              onExportUsers: _exportUsersList,
            ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.failedToRefresh),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  void _exportUsersList() async {
    HapticFeedback.heavyImpact();

    try {
      final users = await DatabaseHelper.instance.fetchAllUsers();

      if (!mounted) return;

      await BarcodeGenerator.generateUsersPdf(users, context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.failedToExportUsers(e.toString())),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  void _addUser() {
    final userIdController = TextEditingController();
    final nameController = TextEditingController();
    final emailController = TextEditingController();

    showDialog(
      context: context,
      builder:
          (context) {
            final l10n = AppLocalizations.of(context)!;
            return AlertDialog(
              title: Text(l10n.addNewUser),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: userIdController,
                    decoration: InputDecoration(
                      labelText: l10n.userId,
                      border: OutlineInputBorder(),
                      helperText: l10n.userIdHelper,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: l10n.nameOptional,
                      border: OutlineInputBorder(),
                      helperText: l10n.nameHelper,
                    ),
                    textCapitalization: TextCapitalization.words,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: emailController,
                    decoration: InputDecoration(
                      labelText: l10n.emailOptional,
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(l10n.cancel),
                ),
                FilledButton(
                  onPressed: () async {
                    final userId = userIdController.text.trim();
                    if (userId.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(l10n.userIdRequired)),
                      );
                      return;
                    }

                    Navigator.of(context).pop();

                    try {
                      final name =
                          nameController.text.trim().isEmpty
                              ? userId
                              : nameController.text.trim();
                      final email =
                          emailController.text.trim().isEmpty
                              ? null
                              : emailController.text.trim();

                      await DatabaseHelper.instance.createUser(
                        userId,
                        name,
                        email,
                      );

                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(l10n.userCreatedSuccess(userId)),
                          ),
                        );
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(l10n.failedToCreateUser(e.toString())),
                            backgroundColor: Theme.of(context).colorScheme.error,
                          ),
                        );
                      }
                    }
                  },
                  child: Text(l10n.addUserButton),
                ),
              ],
            );
          },
    );
  }

  void _addWork() {
    final workIdController = TextEditingController();
    final titleController = TextEditingController();
    final composerController = TextEditingController();

    showDialog(
      context: context,
      builder:
          (context) {
            final l10n = AppLocalizations.of(context)!;
            return AlertDialog(
              title: Text(l10n.addNewWork),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: workIdController,
                    decoration: InputDecoration(
                      labelText: l10n.workId,
                      border: OutlineInputBorder(),
                      helperText: l10n.workIdHelper,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: titleController,
                    decoration: InputDecoration(
                      labelText: l10n.titleOptional,
                      border: OutlineInputBorder(),
                      helperText: l10n.titleHelper,
                    ),
                    textCapitalization: TextCapitalization.words,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: composerController,
                    decoration: InputDecoration(
                      labelText: l10n.composerOptional,
                      border: OutlineInputBorder(),
                    ),
                    textCapitalization: TextCapitalization.words,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(l10n.cancel),
                ),
                FilledButton(
                  onPressed: () async {
                    final workId = workIdController.text.trim();
                    if (workId.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(l10n.workIdRequired)),
                      );
                      return;
                    }

                    Navigator.of(context).pop();

                    try {
                      final title =
                          titleController.text.trim().isEmpty
                              ? workId
                              : titleController.text.trim();
                      final composer =
                          composerController.text.trim().isEmpty
                              ? null
                              : composerController.text.trim();

                      await DatabaseHelper.instance.createWork(
                        workId,
                        title,
                        composer,
                      );

                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(l10n.workCreatedSuccess(workId)),
                          ),
                        );
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(l10n.failedToCreateWork(e.toString())),
                            backgroundColor: Theme.of(context).colorScheme.error,
                          ),
                        );
                      }
                    }
                  },
                  child: Text(l10n.addWorkButton),
                ),
              ],
            );
          },
    );
  }

  Widget _buildFabForCurrentTab() {
    final l10n = AppLocalizations.of(context)!;
    switch (_currentIndex) {
      case 0: // Checkouts tab
        // Hide scanner button on desktop platforms
        if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
          return const SizedBox.shrink();
        }
        return FloatingActionButton(
          key: const ValueKey<String>('fab_checkouts'),
          heroTag: "scanner",
          onPressed: _openScanner,
          tooltip: l10n.scanQrCode,
          child: const Icon(Icons.qr_code),
        );
      case 1: // Users tab
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FloatingActionButton(
              heroTag: "print_users",
              onPressed: _exportUsersList,
              tooltip: l10n.printUsersList,
              child: const Icon(Icons.print),
            ),
            const SizedBox(height: 16),
            FloatingActionButton(
              key: const ValueKey<String>('fab_users'),
              heroTag: "add_user",
              onPressed: _addUser,
              tooltip: l10n.addUserTooltip,
              child: const Icon(Icons.add),
            ),
          ],
        );
      case 2: // Works tab
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FloatingActionButton(
              heroTag: "print_works",
              onPressed: _openBarcodeSheetGenerator,
              tooltip: l10n.generateBarcodeSheet,
              child: const Icon(Icons.print),
            ),
            const SizedBox(height: 16),
            FloatingActionButton(
              key: const ValueKey<String>('fab_works'),
              heroTag: "add_work",
              onPressed: _addWork,
              tooltip: l10n.addWorkTooltip,
              child: const Icon(Icons.add),
            ),
          ],
        );
      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        actions: [
          ListenableBuilder(
            listenable: DatabaseHelper.instance.onlineModel,
            builder: (BuildContext context, Widget? child) {
              return AnimatedSwitcher(
                duration: const Duration(
                  milliseconds: 300,
                ), // Consistent duration
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return FadeTransition(opacity: animation, child: child);
                },
                child:
                    !DatabaseHelper.instance.onlineModel.isOnline
                        ? const Icon(
                          Icons.wifi_off,
                          key: ValueKey<String>('wifi_off_icon'),
                        )
                        : const SizedBox.shrink(
                          key: ValueKey<String>('wifi_on_placeholder'),
                        ),
              );
            },
          ),
        ],
        actionsPadding: const EdgeInsets.all(16.0),
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          CheckedOutList(writeModel: _writeModel),
          UsersView(writeModel: _writeModel),
          WorksView(writeModel: _writeModel),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment),
            label: AppLocalizations.of(context)!.checkouts,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: AppLocalizations.of(context)!.users,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.library_music),
            label: AppLocalizations.of(context)!.works,
          ),
        ],
      ),
      floatingActionButton: ListenableBuilder(
        listenable: DatabaseHelper.instance.onlineModel,
        builder: (BuildContext context, Widget? child) {
          if (!DatabaseHelper.instance.onlineModel.isOnline) {
            return const SizedBox.shrink();
          }

          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: _buildFabForCurrentTab(),
          );
        },
      ),
    );

    // return Localizations.override(
    //   context: context,
    //   locale: const Locale('nb'),
    //   child: child,
    // );
  }
}

class WorkSelectionModal extends StatefulWidget {
  final List<Map<String, dynamic>> works;
  final Function(Map<String, dynamic>, int) onWorkSelected;
  final VoidCallback onExportUsers;

  const WorkSelectionModal({
    super.key,
    required this.works,
    required this.onWorkSelected,
    required this.onExportUsers,
  });

  @override
  State<WorkSelectionModal> createState() => _WorkSelectionModalState();
}

class _WorkSelectionModalState extends State<WorkSelectionModal> {
  String _searchQuery = '';
  List<Map<String, dynamic>> _filteredWorks = [];
  int _instanceCount = 33; // Start with 33 instances (1 page)

  @override
  void initState() {
    super.initState();
    _filteredWorks = widget.works;
  }

  void _filterWorks(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _filteredWorks = widget.works;
      } else {
        _filteredWorks =
            widget.works.where((work) {
              final title = work['title']?.toString().toLowerCase() ?? '';
              final composer = work['composer']?.toString().toLowerCase() ?? '';
              final searchLower = query.toLowerCase();
              return title.contains(searchLower) ||
                  composer.contains(searchLower);
            }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          const SizedBox(height: 16),
          TextField(
            decoration: InputDecoration(
              labelText: l10n.searchWorks,
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
            onChanged: _filterWorks,
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: _filteredWorks.length,
              itemBuilder: (context, index) {
                final work = _filteredWorks[index];
                final title = work['title']?.toString() ?? l10n.unknownTitle;
                final composer = work['composer']?.toString() ?? '';

                return Card(
                  child: ListTile(
                    title: Text(title),
                    subtitle: composer.isNotEmpty ? Text(composer) : null,
                    trailing: const Icon(Icons.print),
                    onTap: () {
                      Navigator.of(context).pop();
                      widget.onWorkSelected(work, _instanceCount);
                    },
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed:
                      _instanceCount > 33
                          ? () {
                            HapticFeedback.mediumImpact();
                            setState(() {
                              _instanceCount -= 33;
                            });
                          }
                          : null,
                  icon: const Icon(Icons.remove_circle),
                  iconSize: 40,
                ),
                const SizedBox(width: 16),
                Column(
                  children: [
                    Text(
                      l10n.instances(_instanceCount),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(
                      l10n.pages((_instanceCount / 33).ceil()),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                IconButton(
                  onPressed: () {
                    HapticFeedback.mediumImpact();
                    setState(() {
                      _instanceCount += 33;
                    });
                  },
                  icon: const Icon(Icons.add_circle),
                  iconSize: 40,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

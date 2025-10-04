import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:barcode/barcode.dart' as bc;
import 'dart:typed_data';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

import 'database_helper.dart';
import 'l10n/app_localizations.dart';
import 'scanner_modal.dart';
import 'checkouts_view.dart';
import 'users_view.dart';
import 'works_view.dart';
import 'util.dart';

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
        builder: (context) => WorkSelectionModal(
          works: works,
          onWorkSelected: _generateBarcodeSheet,
          onExportUsers: _exportUsersList,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load works: $e'),
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

      await _generateUsersPdf(users);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to export users: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  Future<void> _generateBarcodeSheet(Map<String, dynamic> work, int instanceCount) async {
    final workId = work['work_id'] as String;
    final title = work['title'] as String;
    final composer = work['composer'] as String? ?? '';

    // Generate barcode data for each instance
    final barcodeData = List.generate(instanceCount, (index) => '$workId ${index + 1}');

    final workTitle = composer.isNotEmpty ? '$title - $composer' : title;

    await _generateBarcodeListPdf(
      barcodeData: barcodeData,
      title: workTitle,
      fileName: '${workId}.pdf',
      shareText: 'Barcode sheet for $title',
    );
  }


  Future<void> _generateBarcodeListPdf({
    required List<String> barcodeData,
    required String title,
    required String fileName,
    required String shareText,
  }) async {
    try {
      final pdf = pw.Document();
      final itemsPerPage = 14;
      final numPages = (barcodeData.length / itemsPerPage).ceil();

      for (int pageNum = 0; pageNum < numPages; pageNum++) {
        final startIndex = pageNum * itemsPerPage;
        final endIndex = (startIndex + itemsPerPage).clamp(0, barcodeData.length);

        pdf.addPage(
          pw.Page(
            pageFormat: PdfPageFormat.a4,
            margin: pw.EdgeInsets.all(20),
            build: (context) {
              final widgets = <pw.Widget>[];

              // Header
              widgets.add(
                pw.Column(
                  children: [
                    pw.Text(
                      title,
                      style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
                    ),
                    pw.SizedBox(height: 10),
                    pw.Divider(),
                    pw.SizedBox(height: 10),
                  ],
                ),
              );

              // Add barcodes in rows of 2
              for (int i = startIndex; i < endIndex; i += 2) {
                widgets.add(
                  pw.Row(
                    children: [
                      pw.Expanded(
                        child: _buildSimpleBarcodeWidget(barcodeData[i]),
                      ),
                      pw.SizedBox(width: 10),
                      if (i + 1 < endIndex)
                        pw.Expanded(
                          child: _buildSimpleBarcodeWidget(barcodeData[i + 1]),
                        )
                      else
                        pw.Expanded(child: pw.SizedBox()),
                    ],
                  ),
                );
                widgets.add(pw.SizedBox(height: 15));
              }

              return pw.Column(children: widgets);
            },
          ),
        );
      }

      final pdfBytes = await pdf.save();

      if (Platform.isLinux) {
        // Use file save dialog on Linux since share_plus doesn't support it
        String? outputFile = await FilePicker.platform.saveFile(
          dialogTitle: 'Save PDF',
          fileName: fileName,
          type: FileType.custom,
          allowedExtensions: ['pdf'],
        );

        if (outputFile != null) {
          final file = File(outputFile);
          await file.writeAsBytes(pdfBytes);

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('PDF saved to $outputFile'),
                backgroundColor: Theme.of(context).colorScheme.primary,
              ),
            );
          }
        }
      } else {
        // Use share_plus for other platforms
        final tempDir = await getTemporaryDirectory();
        final file = File('${tempDir.path}/$fileName');
        await file.writeAsBytes(pdfBytes);

        await Share.shareXFiles(
          [XFile(file.path)],
          text: shareText,
        );

        try {
          await file.delete();
        } catch (e) {
          // Ignore cleanup errors
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to generate PDF: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  pw.Widget _buildSimpleBarcodeWidget(String data) {
    final barcode = bc.Barcode.code128();

    return pw.Column(
      children: [
        pw.Container(
          height: 60,
          child: pw.BarcodeWidget(
            barcode: barcode,
            data: data,
            width: 200,
            height: 60,
            drawText: false,
          ),
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          data,
          style: pw.TextStyle(fontSize: 10),
        ),
      ],
    );
  }

  Future<void> _generateUsersPdf(List<Map<String, dynamic>> users) async {
    final userIds = users.map((user) => user['user_id']?.toString() ?? '').toList();
    await _generateBarcodeListPdf(
      barcodeData: userIds,
      title: 'User IDs List',
      fileName: 'users.pdf',
      shareText: 'User IDs list',
    );
  }

  void _addUser() {
    final userIdController = TextEditingController();
    final nameController = TextEditingController();
    final emailController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New User'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: userIdController,
              decoration: const InputDecoration(
                labelText: 'User ID',
                border: OutlineInputBorder(),
                helperText: 'Unique identifier for the user',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Name (optional)',
                border: OutlineInputBorder(),
                helperText: 'If empty, will use User ID as name',
              ),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'Email (optional)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              final userId = userIdController.text.trim();
              if (userId.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('User ID is required')),
                );
                return;
              }

              Navigator.of(context).pop();

              try {
                final name = nameController.text.trim().isEmpty
                    ? userId
                    : nameController.text.trim();
                final email = emailController.text.trim().isEmpty
                    ? null
                    : emailController.text.trim();

                await DatabaseHelper.instance.createUser(userId, name, email);

                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('User "$userId" created successfully')),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to create user: $e'),
                      backgroundColor: Theme.of(context).colorScheme.error,
                    ),
                  );
                }
              }
            },
            child: const Text('Add User'),
          ),
        ],
      ),
    );
  }

  void _addWork() {
    final workIdController = TextEditingController();
    final titleController = TextEditingController();
    final composerController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Work'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: workIdController,
              decoration: const InputDecoration(
                labelText: 'Work ID',
                border: OutlineInputBorder(),
                helperText: 'Unique identifier for the work',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Title (optional)',
                border: OutlineInputBorder(),
                helperText: 'If empty, will use Work ID as title',
              ),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: composerController,
              decoration: const InputDecoration(
                labelText: 'Composer (optional)',
                border: OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.words,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              final workId = workIdController.text.trim();
              if (workId.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Work ID is required')),
                );
                return;
              }

              Navigator.of(context).pop();

              try {
                final title = titleController.text.trim().isEmpty
                    ? workId
                    : titleController.text.trim();
                final composer = composerController.text.trim().isEmpty
                    ? null
                    : composerController.text.trim();

                await DatabaseHelper.instance.createWork(workId, title, composer);

                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Work "$workId" created successfully')),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to create work: $e'),
                      backgroundColor: Theme.of(context).colorScheme.error,
                    ),
                  );
                }
              }
            },
            child: const Text('Add Work'),
          ),
        ],
      ),
    );
  }

  Widget _buildFabForCurrentTab() {
    switch (_currentIndex) {
      case 0: // Checkouts tab
        return Column(
          mainAxisSize: MainAxisSize.min,
          key: const ValueKey<String>('fab_checkouts'),
          children: [
            FloatingActionButton(
              heroTag: "barcode_sheet",
              onPressed: _openBarcodeSheetGenerator,
              tooltip: 'Generate Barcode Sheet',
              child: const Icon(Icons.print),
            ),
            const SizedBox(height: 16),
            FloatingActionButton(
              heroTag: "scanner",
              onPressed: _openScanner,
              tooltip: 'Scan QR Code',
              child: const Icon(Icons.qr_code),
            ),
          ],
        );
      case 1: // Users tab
        return FloatingActionButton(
          key: const ValueKey<String>('fab_users'),
          heroTag: "add_user",
          onPressed: _addUser,
          tooltip: 'Add User',
          child: const Icon(Icons.add),
        );
      case 2: // Works tab
        return FloatingActionButton(
          key: const ValueKey<String>('fab_works'),
          heroTag: "add_work",
          onPressed: _addWork,
          tooltip: 'Add Work',
          child: const Icon(Icons.add),
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
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment),
            label: 'Checkouts',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Users',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.library_music),
            label: 'Works',
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
  int _instanceCount = 14; // Start with 14 instances (1 page)

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
        _filteredWorks = widget.works.where((work) {
          final title = work['title']?.toString().toLowerCase() ?? '';
          final composer = work['composer']?.toString().toLowerCase() ?? '';
          final searchLower = query.toLowerCase();
          return title.contains(searchLower) || composer.contains(searchLower);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).pop();
                widget.onExportUsers();
              },
              icon: const Icon(Icons.people),
              label: const Text('Export Users List'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            decoration: const InputDecoration(
              labelText: 'Search works...',
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
                final title = work['title']?.toString() ?? 'Unknown Title';
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
                  onPressed: _instanceCount > 14 ? () {
                    HapticFeedback.mediumImpact();
                    setState(() {
                      _instanceCount -= 14;
                    });
                  } : null,
                  icon: const Icon(Icons.remove_circle),
                  iconSize: 40,
                ),
                const SizedBox(width: 16),
                Column(
                  children: [
                    Text(
                      '$_instanceCount instances',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(
                      '${(_instanceCount / 14).ceil()} page${(_instanceCount / 14).ceil() != 1 ? 's' : ''}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                IconButton(
                  onPressed: () {
                    HapticFeedback.mediumImpact();
                    setState(() {
                      _instanceCount += 14;
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

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
import 'table.dart';
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
  late WriteModel _writeModel; // Renamed for clarity

  @override
  void initState() {
    super.initState();
    _writeModel = WriteModel(); // Initialize here
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

  @override
  Widget build(BuildContext context) {
    var child = Scaffold(
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
        actionsPadding: EdgeInsets.all(16.0),
      ),
      body: CheckedOutList(writeModel: _writeModel),
      floatingActionButton: ListenableBuilder(
        listenable: DatabaseHelper.instance.onlineModel,
        builder: (BuildContext context, Widget? child) {
          return AnimatedSwitcher(
            duration: const Duration(
              milliseconds: 300,
            ), // Adjust duration as needed
            transitionBuilder: (Widget child, Animation<double> animation) {
              // Define the slide tween from bottom (Offset(0, 1)) to center (Offset.zero)
              final offsetAnimation = Tween<Offset>(
                begin: const Offset(2.0, 0.0), // Start below the screen
                end: Offset.zero, // End at the original position
              ).animate(
                CurvedAnimation(parent: animation, curve: Curves.easeOut),
              ); // Apply easing
              return SlideTransition(position: offsetAnimation, child: child);
            },
            child:
                DatabaseHelper.instance.onlineModel.isOnline
                    ? Column(
                      mainAxisSize: MainAxisSize.min,
                      key: const ValueKey<String>('fab_online'),
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
                    )
                    : const SizedBox.shrink(
                      // Use a different ValueKey for the 'offline' state
                      key: ValueKey<String>('fab_offline'),
                    ), // Use SizedBox.shrink() to represent the absence of the FAB
          );
        },
      ),
    );

    return child;

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

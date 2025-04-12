import 'package:choir/database_helper.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

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
        );
        final baseDarkTheme = ThemeData(
          useMaterial3: true,
          colorScheme: darkDynamic,
          brightness: Brightness.dark,
        );

        return MaterialApp(
          theme: baseLightTheme.copyWith(
            textTheme: GoogleFonts.interTextTheme(baseLightTheme.textTheme),
          ),
          darkTheme: baseDarkTheme.copyWith(
            textTheme: GoogleFonts.interTextTheme(baseDarkTheme.textTheme),
          ),
          home: const MyHomePage(title: 'Stavanger Symfonikor'),
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
    HapticFeedback.lightImpact();
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

  @override
  Widget build(BuildContext context) {
    // DatabaseHelper.instance.setContext(context);

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
                    ? FloatingActionButton(
                      // Use a ValueKey to ensure AnimatedSwitcher recognizes the widget change
                      key: const ValueKey<String>('fab_online'),
                      onPressed: _openScanner,
                      tooltip: 'Scan QR Code',
                      child: const Icon(Icons.qr_code),
                    )
                    : const SizedBox.shrink(
                      // Use a different ValueKey for the 'offline' state
                      key: ValueKey<String>('fab_offline'),
                    ), // Use SizedBox.shrink() to represent the absence of the FAB
          );
        },
      ),
    );
  }
}

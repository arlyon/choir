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
      isScrollControlled: true, // Allows the modal to take up more height
      builder: (context) => MultiStepModal(onSuccess: _writeModel.increment), // Use the state variable
    );
  }

  @override
  Widget build(BuildContext context) {
    // _writeModel is now initialized in initState

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: CheckedOutList(writeModel: _writeModel), // Pass the model instance
      floatingActionButton: FloatingActionButton(
        onPressed: _openScanner,
        tooltip: 'Increment',
        child: const Icon(Icons.qr_code),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

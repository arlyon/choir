import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'scanner_modal.dart';
import 'table.dart';
import 'util.dart';

void main() {
  runApp(const MyApp());
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
        ColorScheme lightColorScheme;
        ColorScheme darkColorScheme;

        if (lightDynamic != null && darkDynamic != null) {
          // On Android S+ devices, use the provided dynamic color scheme.
          // (Recommended) Harmonize the dynamic color scheme' built-in semantic colors.
          lightColorScheme = lightDynamic.harmonized();
          // (Optional) Customize the scheme as desired. For example, one might
          // want to use a brand color to override the dynamic [ColorScheme.secondary].
          lightColorScheme = lightColorScheme.copyWith(secondary: _brandBlue);
          // (Optional) If applicable, harmonize custom colors.
          lightCustomColors = lightCustomColors.harmonized(lightColorScheme);

          // Repeat for the dark color scheme.
          darkColorScheme = darkDynamic.harmonized();
          darkColorScheme = darkColorScheme.copyWith(secondary: _brandBlue);
          darkCustomColors = darkCustomColors.harmonized(darkColorScheme);
        } else {
          // Otherwise, use fallback schemes.
          lightColorScheme = ColorScheme.fromSeed(seedColor: _brandBlue);
          darkColorScheme = ColorScheme.fromSeed(
            seedColor: _brandBlue,
            brightness: Brightness.dark,
          );
        }

        return MaterialApp(
          theme: ThemeData(
            colorScheme: lightColorScheme,
            extensions: [lightCustomColors],
            textTheme: GoogleFonts.acmeTextTheme(Theme.of(context).textTheme),
          ),
          darkTheme: ThemeData(
            colorScheme: darkColorScheme,
            extensions: [darkCustomColors],
            textTheme: GoogleFonts.interTextTheme(Theme.of(context).textTheme),
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
  void _openScanner() {
    // Show the multi-step modal
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Allows the modal to take up more height
      builder: (context) => const MultiStepModal(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: const CheckedOutList(),
      floatingActionButton: FloatingActionButton(
        onPressed: _openScanner,
        tooltip: 'Increment',
        child: const Icon(Icons.qr_code),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

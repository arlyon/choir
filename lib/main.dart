import 'package:choir/table.dart'; // Import the new table widget
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_scanner/mobile_scanner.dart'; // Added import
import 'package:sqflite/sqflite.dart'; // Uncommented
import 'package:path_provider/path_provider.dart'; // Uncommented
import 'database_helper.dart'; // Uncommented

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

// New Widget for the Multi-Step Modal
class MultiStepModal extends StatefulWidget {
  const MultiStepModal({super.key});

  @override
  State<MultiStepModal> createState() => _MultiStepModalState();
}

class _MultiStepModalState extends State<MultiStepModal> {
  int _currentStep = 0;
  final List<String> _steps = [
    'Scan Music',
    'Scan Person',
    'Summary',
  ]; // Updated step names
  String? _workId; // To store scanned work ID
  String? _userId; // To store scanned user ID
  final MobileScannerController _scannerController =
      MobileScannerController(); // Scanner controller

  void _nextStep() {

    // Stop scanner if moving away from a scanner step
    if (_currentStep == 1) {
      _scannerController.stop();
    }

    if (_currentStep < _steps.length - 1) {
      setState(() {
        _currentStep++;
        // Start scanner if moving to a scanner step
        if (_currentStep == 0 || _currentStep == 1) {
          _scannerController.start();
        }
      });
    } else {
      // Finalize action
      _finalizeCheckout(); // Call finalize function
      Navigator.pop(context); // Close the modal
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
        // Start scanner if moving to a scanner step
        if (_currentStep == 0 || _currentStep == 1) {
          _scannerController.start();
        }
      });
    }
  }

  // Function to handle barcode detection
  void _handleBarcode(BarcodeCapture capture) {
    final String? code = capture.barcodes.first.rawValue;
    if (code != null) {
      setState(() {
        if (_currentStep == 0) {
          _workId = code;
          print("Scanned Work ID: $_workId"); // For debugging
          _scannerController.stop(); // Stop scanner after successful scan
          _nextStep(); // Move to next step
        } else if (_currentStep == 1) {
          _userId = code;
          print("Scanned User ID: $_userId"); // For debugging
          _scannerController.stop(); // Stop scanner after successful scan
          _nextStep(); // Move to next step
        }
      });
    }
  }

  Widget _buildStepContent(int stepIndex) {
    switch (stepIndex) {
      case 0: // Scan Music
      case 1: // Scan Person
        // Scanner start/stop is now handled in _nextStep/_previousStep
        return Column(
          children: [
            Text(
              stepIndex == 0
                  ? 'Scan the QR code on the music booklet.'
                  : 'Scan the QR code for the person.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Theme.of(context).highlightColor),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ClipRRect(
                  // Clip the scanner view for rounded corners
                  borderRadius: BorderRadius.circular(12.0),
                  child: MobileScanner(
                    controller: _scannerController,
                    onDetect: _handleBarcode,
                    // Optional: Add overlay, customize scan window, etc.
                    // scanWindow: Rect.fromCenter(center: Offset(size.width / 2, size.height / 2), width: 250, height: 250),
                  ),
                ),
              ),
            ),
            
          ],
        );
      case 2: // Summary
        // Scanner stop is handled in _nextStep
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Summary',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 20),
              Text('Work ID: ${_workId ?? 'Not Scanned'}'),
              Text('User ID: ${_userId ?? 'Not Scanned'}'),
              const SizedBox(height: 20),
              if (_workId == null || _userId == null)
                Text(
                  'Please go back and scan both QR codes.',
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                  textAlign: TextAlign.center,
                ),
            ],
          ),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  // Function to handle the finalization logic
  Future<void> _finalizeCheckout() async {
    // Make async
    if (_workId != null && _userId != null) {
      print(
        "Attempting to finalize checkout for Work ID: $_workId, User ID: $_userId",
      );
      try {
        final int result = await DatabaseHelper.instance.insertCheckout(
          _workId!,
          _userId!,
        );
        if (result > 0) {
          print("Checkout successful!");
          // Optionally show a success message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Checkout successful!'),
              backgroundColor: Colors.green,
            ),
          );
        } else if (result == -1) {
          print("Checkout failed: Invalid User ID format.");
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Checkout failed: Invalid User ID format ($_userId).',
              ),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        } else if (result == -2) {
          print("Checkout failed: Item already checked out.");
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Checkout failed: Work ID $_workId is already checked out.',
              ),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        } else {
          print("Checkout failed for an unknown reason.");
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Checkout failed. Please try again.'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      } catch (e) {
        print("Error during checkout: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('An error occurred: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
      // DatabaseHelper.instance.insertCheckout(_workId!, int.parse(_userId!)); // Example call
    } else {
      print("Cannot finalize: Missing Work ID or User ID.");
      // Optionally show an error message to the user
    }
  }

  // Start scanner when the modal first builds if starting on a scanner step
  @override
  void initState() {
    super.initState();
    if (_currentStep == 0 || _currentStep == 1) {
      // Start scanner after the first frame to avoid issues
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          // Check if the widget is still mounted
          _scannerController.start();
        }
      });
    }
  }

  @override
  void dispose() {
    // Ensure scanner is stopped and controller disposed
    _scannerController.stop();
    _scannerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: FractionallySizedBox(
        heightFactor:
            0.7, // Adjust height factor as needed (e.g., 0.7 for 70% of screen height)
        child: Scaffold(
          // Use Scaffold for AppBar and consistent structure
          appBar: AppBar(
            title: Text(
              "Check in / out",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18.0,
                color: Theme.of(context).colorScheme.primaryContainer,
              ),
            ),
            automaticallyImplyLeading: false, // Hide default back button
            centerTitle: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: _currentStep > 0 ? _previousStep : null,
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context), // Add a close button
              ),
            ],
            // bottom: PreferredSize(
            //   // Add step indicator here
            //   preferredSize: const Size.fromHeight(40.0),
            //   child: Padding(
            //     padding: const EdgeInsets.symmetric(
            //       horizontal: 16.0,
            //       vertical: 8.0,
            //     ),
            //     child: Row(
            //       mainAxisAlignment: MainAxisAlignment.spaceAround,
            //       children: List.generate(_steps.length, (index) {
            //         bool isActive = index == _currentStep;
            //         bool isCompleted = index < _currentStep;
            //         Color color =
            //             isActive
            //                 ? Theme.of(context).colorScheme.primary
            //                 : isCompleted
            //                 ? Theme.of(context).colorScheme.primary
            //                 : Theme.of(
            //                   context,
            //                 ).colorScheme.onSurface.withOpacity(0.38);
            //         FontWeight weight =
            //             isActive ? FontWeight.bold : FontWeight.normal;

            //         return Text(
            //           _steps[index],
            //           style: TextStyle(color: color, fontWeight: weight),
            //         );
            //       }),
            //     ),
            //   ),
            // ),
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Expanded(child: _buildStepContent(_currentStep)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children:
                      // Hide Continue button on scanner steps, rely on auto-advance
                      _currentStep != 2
                          ? [
                            ElevatedButton(
                              onPressed: null,
                              child: const Text("Search"),
                            ),
                            ElevatedButton(
                              onPressed:
                                  _currentStep == 0
                                      ? _workId != null
                                          ? _nextStep
                                          : null
                                      : _currentStep == 1
                                      ? _userId != null
                                          ? _nextStep
                                          : null
                                      : null, // Manual next for non-scanner steps if any
                              child: const Text('Continue'),
                            ),
                          ]
                          : // Last step (Summary)
                          [
                            ElevatedButton(
                              // Enable finalize only if both IDs are scanned
                              onPressed:
                                  (_workId != null && _userId != null)
                                      ? _nextStep
                                      : null,
                              child: const Text('Finalize'),
                            ),
                          ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

@immutable
class CustomColors extends ThemeExtension<CustomColors> {
  const CustomColors({required this.danger});

  final Color? danger;

  @override
  CustomColors copyWith({Color? danger}) {
    return CustomColors(danger: danger ?? this.danger);
  }

  @override
  CustomColors lerp(ThemeExtension<CustomColors>? other, double t) {
    if (other is! CustomColors) {
      return this;
    }
    return CustomColors(danger: Color.lerp(danger, other.danger, t));
  }

  CustomColors harmonized(ColorScheme dynamic) {
    return copyWith(danger: danger!.harmonizeWith(dynamic.primary));
  }
}

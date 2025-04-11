import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'database_helper.dart';

// New Widget for the Multi-Step Modal
class MultiStepModal extends StatefulWidget {
  const MultiStepModal({super.key});

  @override
  State<MultiStepModal> createState() => _MultiStepModalState();
}

class _MultiStepModalState extends State<MultiStepModal> {
  int _currentStep = 0;

  final List<(String, bool)> _steps = [
    ('Scan Music', true),
    ('Confirm Music', true),
    ('Scan Person', true),
    ('Confirm Person', true),
    ('Summary', false),
  ];

  String? _workId;
  String? _userId;

  final MobileScannerController _scannerController =
      MobileScannerController(); // Scanner controller

  Future<void> _nextStep() async {
    if (_currentStep < _steps.length - 1) {
      setState(() {
        _currentStep++;
      });

      if (_steps[_currentStep].$2) {
        _scannerController.start();
      } else {
        _scannerController.stop();
      }
    } else {
      // Finalize action
      await _finalizeCheckout(); // Call finalize function
      Navigator.pop(context); // Close the modal
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });

      if (_steps[_currentStep].$2) {
        _scannerController.start();
      } else {
        _scannerController.stop();
      }
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
          _nextStep(); // Move to next step
        } else if (_currentStep == 2) {
          _userId = code;
          print("Scanned User ID: $_userId"); // For debugging
          _nextStep(); // Move to next step
        }
      });
    }
  }

  Widget _buildStepContent(int stepIndex) {
    switch (stepIndex) {
      case 0:
      case 2:
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
      case 1: // Scan Person
      case 3:
        return Column(
          children: [
            Text(
              "Confirm",
              textAlign: TextAlign.center,
              style: TextStyle(color: Theme.of(context).highlightColor),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ClipRRect(
                  // Clip the scanner view for rounded corners
                  borderRadius: BorderRadius.circular(12.0),
                  child: Text(
                    "$_workId $_userId",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      case 4: // Summary
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Summary',
                style: TextStyle(color: Theme.of(context).colorScheme.primary),
              ),
              const SizedBox(height: 20),
              Text('Work ID: ${_workId ?? 'Not Scanned'}', style: TextStyle(color: Theme.of(context).colorScheme.primary),),
              Text('User ID: ${_userId ?? 'Not Scanned'}', style: TextStyle(color: Theme.of(context).colorScheme.primary),),
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
        final (created, id) = await DatabaseHelper.instance.insertCheckout(
          _workId!,
          _userId!,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(created ? 'Checkout successful!' : 'Return successful!'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Checkout failed: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
            showCloseIcon: true,
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
                      _currentStep != 4
                          ? [
                            ElevatedButton(
                              onPressed: null,
                              child: const Text("Search"),
                            ),
                            ElevatedButton(
                              onPressed:
                                  _currentStep == 1
                                      ? _workId != null
                                          ? _nextStep
                                          : null
                                      : _currentStep == 3
                                      ? _userId != null
                                          ? _nextStep
                                          : null
                                      : null, // Manual next for non-scanner steps if any
                              child: const Text('Continue'),
                            ),
                          ]
                          : // Last step (Summary)
                          [
                            Text(""),
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

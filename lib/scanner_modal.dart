import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'database_helper.dart';

// New Widget for the Multi-Step Modal
class MultiStepModal extends StatefulWidget {
  final Function() onSuccess;

  const MultiStepModal({super.key, required this.onSuccess});

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
  bool _loading = false;

  final MobileScannerController _scannerController =
      MobileScannerController(); // Scanner controller

  Future<void> _nextStep() async {
    if (_currentStep < _steps.length - 1) {
      HapticFeedback.lightImpact();

      var id = _currentStep + 1;
      if (_steps[id].$2) {
        await _scannerController.start();
      } else {
        await _scannerController.stop();
      }
      setState(() {
        _currentStep = id;
      });
    } else {
      // Finalize action
      setState(() {
        _loading = true;
      });
      await _finalizeCheckout(); // Call finalize function
      setState(() {
        _loading = false;
      });
      Navigator.pop(context); // Close the modal
    }
  }

  Future<void> _previousStep() async {
    if (_currentStep > 0) {
      var id = _currentStep - 1;

      if (_steps[id].$2) {
        await _scannerController.start();
      } else {
        await _scannerController.stop();
      }

      setState(() {
        _currentStep = id;
      });
    }
  }

  // Function to handle barcode detection
  Future<void> _handleBarcode(BarcodeCapture capture) async {
    final String? code = capture.barcodes.first.rawValue;
    if (code != null) {
      setState(() {
        if (_currentStep == 0) {
          _workId = code;
        } else if (_currentStep == 2) {
          _userId = code;
        }
      });
      if (_currentStep == 0 || _currentStep == 2) {
        await _nextStep(); // Move to next step
      }
    }
  }

  Widget _buildStepContent(int stepIndex) {
    final theme = Theme.of(context);
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
              style: theme.textTheme.labelMedium!.copyWith(
                color: theme.disabledColor,
              ),
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
      case 1: // Confirm Music
        if (_workId == null) {
          // This case should ideally not be reached if the flow is correct
          return const Center(
            child: Text('Error: Work ID not available. Please go back.'),
          );
        }
        return FutureBuilder<Map<String, dynamic>?>(
          future: DatabaseHelper.instance.getWorkById(
            _workId!,
          ), // Fetch work details
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(
                child: Text('Error fetching work details: ${snapshot.error}'),
              );
            } else if (!snapshot.hasData || snapshot.data == null) {
              return Center(child: Text('Work with ID $_workId not found.'));
            } else {
              final workData = snapshot.data!;
              // Adjust keys based on your actual database structure
              final title = workData['title'] ?? 'Unknown Title';
              final composer = workData['composer'] ?? 'Unknown Composer';
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.book,
                        size: 50,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        title,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onSurface,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        composer,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '(ID: $_workId)',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.disabledColor,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }
          },
        );
      case 3: // Confirm Person
        if (_userId == null) {
          // This case should ideally not be reached if the flow is correct
          return const Center(
            child: Text('Error: User ID not available. Please go back.'),
          );
        }
        return FutureBuilder<Map<String, dynamic>?>(
          future: DatabaseHelper.instance.getUserById(
            _userId!,
          ), // Fetch user details
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(
                child: Text('Error fetching user details: ${snapshot.error}'),
              );
            } else if (!snapshot.hasData || snapshot.data == null) {
              return Center(child: Text('User with ID $_userId not found.'));
            } else {
              final userData = snapshot.data!;
              // Adjust key based on your actual database structure
              final name = userData['name'] ?? 'Unknown User';
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.person,
                        size: 50,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        name,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onSurface,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '(ID: $_userId)',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.disabledColor,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }
          },
        );
      case 4: // Summary
        if (_workId == null || _userId == null) {
          // Should not happen if flow is correct, but handle defensively
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Error: Missing Work ID or User ID. Please go back and scan both QR codes.',
                style: TextStyle(color: theme.colorScheme.error),
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        // Use Future.wait to fetch all required data concurrently
        return FutureBuilder<List<dynamic>>(
          future: Future.wait([
            DatabaseHelper.instance.getUserById(_userId!),
            DatabaseHelper.instance.getWorkById(_workId!),
            DatabaseHelper.instance.checkExistingCheckout(_workId!, _userId!),
          ]),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError ||
                !snapshot.hasData ||
                snapshot.data == null) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Error loading summary details. Please try again.',
                    style: TextStyle(color: theme.colorScheme.error),
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }

            // Extract data - handle potential nulls from DB lookups
            final userData = snapshot.data![0] as Map<String, dynamic>?;
            final workData = snapshot.data![1] as Map<String, dynamic>?;
            final isReturning =
                snapshot.data![2] as bool; // checkExistingCheckout result

            final userName = userData?['name'] ?? 'Unknown User (ID: $_userId)';
            final workTitle = workData?['title'] ?? 'Unknown Work';
            final workComposer = workData?['composer'] ?? 'Unknown Composer';
            final workDisplay =
                workComposer.isNotEmpty
                    ? '$workTitle by $workComposer'
                    : workTitle;
            final actionText = isReturning ? 'returning' : 'checking out';

            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      isReturning
                          ? Icons.arrow_downward
                          : Icons.arrow_upward, // Icon indicating direction
                      size: 40,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(height: 16),
                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onSurface,
                        ),
                        children: <TextSpan>[
                          TextSpan(
                            text: userName,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          TextSpan(text: '\nis $actionText\n'),
                          TextSpan(
                            text: workDisplay,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '(Work ID: $_workId, User ID: $_userId)',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.disabledColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          },
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

        widget.onSuccess();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              created ? 'Checkout successful!' : 'Return successful!',
            ),
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

  void _openSearch() {}

  @override
  void dispose() {
    // Ensure scanner is stopped and controller disposed
    _scannerController.stop();
    _scannerController.dispose();
    HapticFeedback.lightImpact();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return PopScope(
      canPop: _currentStep == 0,
      onPopInvokedWithResult: (didPop, result) => {_previousStep()},
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: FractionallySizedBox(
          // Adjust height factor as needed (e.g., 0.7 for 70% of screen height)
          heightFactor: 0.6,
          child: Scaffold(
            // Use Scaffold for AppBar and consistent structure
            backgroundColor: Colors.transparent,
            body: Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 8.0),
              child: Column(
                children: [
                  Expanded(child: _buildStepContent(_currentStep)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children:
                        _currentStep != 4
                            ? [
                              TextButton(
                                onPressed: _openSearch,
                                child: const Text("Search"),
                              ),
                              TextButton(
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
                              TextButton.icon(
                                // Enable finalize only if both IDs are scanned
                                onPressed:
                                    (_workId != null &&
                                            _userId != null &&
                                            !_loading)
                                        ? _nextStep
                                        : null,
                                label: const Text('Finalize'),
                                icon:
                                    _loading
                                        ? Container(
                                          width: 24,
                                          height: 24,
                                          padding: const EdgeInsets.all(2.0),
                                          child:
                                              const CircularProgressIndicator(
                                                strokeWidth: 3,
                                              ),
                                        )
                                        : const Icon(Icons.save_sharp),
                              ),
                            ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

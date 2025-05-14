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

  NewOrExistingWork? _work;
  NewOrExistingUser? _user;

  final MobileScannerController _scannerController = MobileScannerController();

  Future<Map<String, dynamic>?>? _userFuture;
  Future<Map<String, dynamic>?>? _workFuture;
  Future<bool>? _checkoutFuture;

  VoidCallback? continueAction;

  final _formKeyWork = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _composerController = TextEditingController();

  final _formKeyUser = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();

  Future<void> _nextStep() async {
    if (_currentStep < _steps.length - 1) {
      HapticFeedback.mediumImpact();

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
      await _finalizeCheckout(); // Call finalize function
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
          _work = NewOrExistingWork.existing(code);
          _workFuture = DatabaseHelper.instance.getWorkById(code);
        } else if (_currentStep == 2) {
          _user = NewOrExistingUser.existing(code);
          _userFuture = DatabaseHelper.instance.getUserById(code);
        }
      });
      if (_currentStep == 0 || _currentStep == 2) {
        await _nextStep(); // Move to next step
      }
    }
  }

  (Widget, List<Widget>) _buildStepContent(int stepIndex) {
    final theme = Theme.of(context);
    switch (stepIndex) {
      case 0:
      case 2:
        return (
          Column(
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
          ),
          [
            TextButton(onPressed: _openSearch, child: const Text("Search")),
            TextButton(onPressed: null, child: const Text('Continue')),
          ],
        );
      case 1:
        return (
          FutureBuilder<Map<String, dynamic>?>(
            future: _workFuture,
            builder: (context, snapshot) {
              Widget body;

              if (snapshot.connectionState == ConnectionState.waiting) {
                body = const Center(child: CircularProgressIndicator());
                continueAction = null; // Disable continue while loading
              } else if (snapshot.hasError) {
                body = Center(
                  child: Text('Error fetching work details: ${snapshot.error}'),
                );
                continueAction = null; // Disable on error
              } else if (!snapshot.hasData || snapshot.data == null) {
                _titleController.text = switch (_work) {
                  ExistingWork(:final id) => id.split(" ").first,
                  CreateWork(:final name) => name,
                  null => "",
                };

                body = _buildCreateWorkForm(
                  theme,
                  _formKeyWork,
                  _titleController,
                  _composerController,
                );
                // Action: Validate form, create work object, then advance
                continueAction = () {
                  if (_formKeyWork.currentState!.validate()) {
                    setState(() {
                      // Create the work object using positional args
                      // Note: We are now storing the *intent* to create in _work
                      // The actual DB insertion happens in _finalizeCheckout
                      _work = NewOrExistingWork.create(
                        _work!.id,
                        _titleController.text,
                        _composerController
                            .text, // Pass empty string if null/empty
                        null, // Instance is null for now
                      );
                    });
                    _nextStep(); // Advance after successful validation and creation
                  }
                };
              } else {
                // Work exists, show details
                final workData = snapshot.data!;
                final title = workData['title'] ?? 'Unknown Title';
                final composer = workData['composer'] ?? 'Unknown Composer';
                body = Center(
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
                          '(ID: ${_work?.maybeMap(existing: (e) => e.id, orElse: () => 'New')})', // Show the original scanned ID or 'New'
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.disabledColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
                // Action: Just advance to the next step
                continueAction = _nextStep;
              }

              // Return the body and the correctly configured button action
              // We need to return the tuple (Widget, List<Widget>) expected by _buildStepContent
              return body;
            },
          ),
          [
            SizedBox.shrink(), // Placeholder for potential back button?
            TextButton(
              onPressed: continueAction,
              child: const Text('Continue'),
            ),
          ],
        );
      case 3:
        return (
          FutureBuilder<Map<String, dynamic>?>(
            future: _userFuture,
            builder: (context, snapshot) {
              Widget body;

              if (snapshot.connectionState == ConnectionState.waiting) {
                body = const Center(child: CircularProgressIndicator());
                continueAction = null; // Disable continue while loading
              } else if (snapshot.hasError) {
                body = Center(
                  child: Text('Error fetching work details: ${snapshot.error}'),
                );
                continueAction = null; // Disable on error
              } else if (!snapshot.hasData || snapshot.data == null) {
                _nameController.text = switch (_user) {
                  ExistingUser(:final id) => id.split(" ").first,
                  CreateUser(:final name) => name,
                  null => "",
                };

                body = _buildCreateUserForm(
                  theme,
                  _formKeyUser,
                  _nameController,
                  _emailController,
                );
                continueAction = () {
                  print(_formKeyUser);
                  if (_formKeyUser.currentState!.validate()) {
                    setState(() {
                      // Create the work object using positional args
                      // Note: We are now storing the *intent* to create in _work
                      // The actual DB insertion happens in _finalizeCheckout
                      _user = NewOrExistingUser.create(
                        _user!.id,
                        _nameController.text,
                        _emailController.text,
                      );
                    });
                    _nextStep(); // Advance after successful validation and creation
                  }
                };
              } else {
                final userData = snapshot.data!;
                // Adjust key based on your actual database structure
                final name = userData['name'] ?? 'Unknown User';
                body = Center(
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
                          '(ID: 123)',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.disabledColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
                // Action: Just advance to the next step
                continueAction = _nextStep;
              }

              return body;
            },
          ),
          [
            SizedBox.shrink(), // Placeholder for potential back button?
            TextButton(
              onPressed: continueAction,
              child: const Text('Continue'),
            ),
          ],
        );
      case 4: // Summary
        if (_work == null || _user == null) {
          return (
            Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Error: Missing Work ID or User ID. Please go back and scan both QR codes.',
                  style: TextStyle(color: theme.colorScheme.error),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            [SizedBox.shrink()],
          );
        } else {
          if (_work case ExistingWork(id: final workId)) {
            if (_user case ExistingUser(id: final userId)) {
              _checkoutFuture = DatabaseHelper.instance.checkExistingCheckout(
                workId,
                userId,
              );
            } else {
              _checkoutFuture = Future.value(false);
            }
          } else {
            _checkoutFuture = Future.value(false);
          }
        }

        // Use Future.wait to fetch all required data concurrently
        return (
          FutureBuilder<List<dynamic>>(
            future: Future.wait([_userFuture!, _workFuture!, _checkoutFuture!]),
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

              final userName = switch (_user) {
                ExistingUser() =>
                  userData?['name'] as String? ?? "Unknown User",
                CreateUser(:final name) => name,
                _ => "Unknown User",
              };

              final workTitle = switch (_work) {
                ExistingWork() =>
                  workData?['title'] as String? ?? "Unknown Work",
                CreateWork(:final name) => name,
                _ => "Unknown Work",
              };

              final workComposer = switch (_work) {
                ExistingWork() => workData?['composer'] as String?,
                CreateWork(:final composer) => composer,
                _ => null,
              };

              final workDisplay =
                  workComposer?.isNotEmpty == true
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
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextSpan(text: '\nis $actionText\n'),
                            TextSpan(
                              text: workDisplay,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '(Work ID: $_work, User ID: $_user)',
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
          ),
          [
            SizedBox.shrink(), // Placeholder for potential back button?
            TextButton.icon(
              // Enable finalize only if both IDs are scanned
              onPressed:
                  (_user != null && _work != null && true) ? _nextStep : null,
              label: const Text('Finalize'),
              icon:
                  false
                      ? Container(
                        width: 24,
                        height: 24,
                        padding: const EdgeInsets.all(2.0),
                        child: const CircularProgressIndicator(strokeWidth: 3),
                      )
                      : const Icon(Icons.save_sharp),
            ),
          ],
        );
      default:
        return (const SizedBox.shrink(), []);
    }
  }

  // Function to handle the finalization logic
  Future<void> _finalizeCheckout() async {
    // Make async
    if (_work != null && _user != null) {
      print(
        "Attempting to finalize checkout for Work ID: $_work, User ID: $_user",
      );
      try {
        final (created, id) = await DatabaseHelper.instance.insertCheckout(
          _work!,
          _user!,
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
        rethrow;
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
    HapticFeedback.heavyImpact();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    var (body, footer) = _buildStepContent(_currentStep);
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
                  Expanded(child: body),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: footer,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCreateWorkForm(
    ThemeData theme,
    GlobalKey<FormState> formKey,
    TextEditingController titleController,
    TextEditingController composerController,
  ) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 4.0,
          children: [
            Icon(
              Icons.add_to_photos,
              size: 48.0,
              color: theme.colorScheme.primaryFixed,
            ),
            Text(
              'Add a new work',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a title';
                }
                return null;
              },
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: composerController,
              decoration: const InputDecoration(
                labelText: 'Composer (optional)',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCreateUserForm(
    ThemeData theme,
    GlobalKey<FormState> formKey,
    TextEditingController nameController,
    TextEditingController emailController,
  ) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 4.0,
          children: [
            Icon(
              Icons.person_add_alt_1,
              size: 48.0,
              color: theme.colorScheme.primaryFixed,
            ),
            Text(
              'Add a new user',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a name';
                }
                return null;
              },
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'Email (optional)',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

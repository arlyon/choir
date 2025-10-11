import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'database_helper.dart';
import 'l10n/app_localizations.dart';

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

  final MobileScannerController _scannerController = MobileScannerController(
    autoStart: true,
  );

  Future<Map<String, dynamic>?>? _userFuture;
  Future<Map<String, dynamic>?>? _workFuture;
  Future<bool>? _checkoutFuture;

  ValueNotifier<VoidCallback?> continueAction = ValueNotifier(null);
  bool _isFinalizingCheckout = false;

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
        // await _scannerController.start();
      } else {
        // await _scannerController.stop();
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
        // await _scannerController.start();
      } else {
        // await _scannerController.stop();
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
          final parts = code.split(" ");
          // if there is one part, it's the workId. if there are 2 or more,
          // then the last is the instance
          String workId;
          int? instance;
          if (parts.length == 1) {
            workId = parts.first;
            instance = null;
          } else {
            // get all but the last item from the array
            workId = parts.sublist(0, parts.length - 1).join(" ");
            try {
              instance = int.parse(parts.last);
            } catch (e) {
              print("Error parsing instance '${parts.last}': $e");
              // If parsing fails, treat the whole code as workId
              workId = code;
              instance = null;
            }
          }

          _work = NewOrExistingWork.existing(workId, instance);
          // work_id and instance
          print("Work ID: $workId, Instance: $instance");
          _workFuture = DatabaseHelper.instance.getWorkById(workId, instance);
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

  void _openManualInput() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final TextEditingController workIdController = TextEditingController();
        final TextEditingController instanceController = TextEditingController();
        final TextEditingController userIdController = TextEditingController();

        return AlertDialog(
          title: Text(_currentStep == 0 ? AppLocalizations.of(context)!.enterWorkDetails : AppLocalizations.of(context)!.enterUserId),
          content: _currentStep == 0
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: workIdController,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.workId,
                      hintText: AppLocalizations.of(context)!.workIdExample,
                    ),
                    autofocus: true,
                    maxLength: 15,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: instanceController,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.instanceNumber,
                      hintText: AppLocalizations.of(context)!.instanceExample,
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ],
              )
            : TextField(
                controller: userIdController,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.userId,
                  hintText: AppLocalizations.of(context)!.userIdExample,
                ),
                autofocus: true,
                maxLength: 15,
              ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(AppLocalizations.of(context)!.cancel),
            ),
            TextButton(
              onPressed: () {
                if (_currentStep == 0) {
                  final workId = workIdController.text.trim();
                  final instanceText = instanceController.text.trim();

                  if (workId.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(AppLocalizations.of(context)!.workIdRequired),
                        backgroundColor: Theme.of(context).colorScheme.error,
                      ),
                    );
                    return;
                  }

                  if (instanceText.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(AppLocalizations.of(context)!.instanceRequired),
                        backgroundColor: Theme.of(context).colorScheme.error,
                      ),
                    );
                    return;
                  }

                  int? instance;
                  try {
                    instance = int.parse(instanceText);
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(AppLocalizations.of(context)!.instanceInvalidNumber),
                        backgroundColor: Theme.of(context).colorScheme.error,
                      ),
                    );
                    return;
                  }

                  Navigator.of(context).pop();
                  setState(() {
                    _work = NewOrExistingWork.existing(workId, instance);
                    _workFuture = DatabaseHelper.instance.getWorkById(workId, instance);
                  });
                  _nextStep();
                } else if (_currentStep == 2) {
                  final userId = userIdController.text.trim();
                  if (userId.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(AppLocalizations.of(context)!.userIdRequired),
                        backgroundColor: Theme.of(context).colorScheme.error,
                      ),
                    );
                    return;
                  }

                  Navigator.of(context).pop();
                  setState(() {
                    _user = NewOrExistingUser.existing(userId);
                    _userFuture = DatabaseHelper.instance.getUserById(userId);
                  });
                  _nextStep();
                }
              },
              child: Text(AppLocalizations.of(context)!.ok),
            ),
          ],
        );
      },
    );
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
                    ? AppLocalizations.of(context)!.scanMusic
                    : AppLocalizations.of(context)!.scanPerson,
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
                    ),
                  ),
                ),
              ),
            ],
          ),
          [
            TextButton(
              onPressed: _openManualInput,
              child: Text(AppLocalizations.of(context)!.manualInput),
            ),
            TextButton(
              onPressed: null,
              child: Text(AppLocalizations.of(context)!.continueText),
            ),
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
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  continueAction.value = null; // Disable continue while loading
                });
              } else if (snapshot.hasError) {
                body = Center(
                  child: Text(AppLocalizations.of(context)!.errorFetchingWork(snapshot.error.toString())),
                );
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  continueAction.value = null; // Disable on error
                });
              } else if (!snapshot.hasData || snapshot.data == null) {
                _titleController.text = switch (_work) {
                  ExistingWork(:final id, :final instance) => id,
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
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  continueAction.value = () {
                    if (_formKeyWork.currentState!.validate()) {
                      setState(() {
                        // Create the work object using positional args
                        // Note: We are now storing the *intent* to create in _work
                        // The actual DB insertion happens in _finalizeCheckout
                        _work = NewOrExistingWork.create(
                          _work!.id,
                          _titleController.text,
                          _composerController.text,
                          _work!.instance,
                        );
                      });
                      _nextStep(); // Advance after successful validation and creation
                    }
                  };
                });
              } else {
                // Work exists, show details
                final workData = snapshot.data!;
                final l10n = AppLocalizations.of(context)!;
                final title = workData['title'] ?? l10n.unknownTitle;
                final composer = workData['composer'] ?? l10n.unknownComposer;
                final userId = workData['user_id'];

                if (userId != null) {
                  // SET USER FUTURE AND MOVE TO STEP 4
                  _user = NewOrExistingUser.existing(userId);
                  _userFuture = DatabaseHelper.instance.getUserById(userId);
                  // Action: Just advance to the next step
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    setState(() {
                      _currentStep = 4;
                    });
                  });
                  body = const SizedBox.shrink();
                } else {
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
                            '${_work?.maybeMap(existing: (e) => e.id.toString() + " - " + e.instance.toString(), orElse: () => 'New')}', // Show the original scanned ID or 'New'
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.disabledColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                // Action: Just advance to the next step
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  continueAction.value = _nextStep;
                });
              }

              // Return the body and the correctly configured button action
              // We need to return the tuple (Widget, List<Widget>) expected by _buildStepContent
              return body;
            },
          ),
          [
            SizedBox.shrink(), // Placeholder for potential back button?
            ValueListenableBuilder(
              valueListenable: continueAction,
              builder: (context, value, child) {
                return TextButton(
                  onPressed: value,
                  child: Text(AppLocalizations.of(context)!.continueText),
                );
              },
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
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  continueAction.value = null; // Disable continue while loading
                });
              } else if (snapshot.hasError) {
                body = Center(
                  child: Text(AppLocalizations.of(context)!.errorFetchingWork(snapshot.error.toString())),
                );
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  continueAction.value = null; // Disable on error
                });
              } else if (!snapshot.hasData || snapshot.data == null) {
                _nameController.text = switch (_user) {
                  ExistingUser(:final id) => id,
                  CreateUser(:final name) => name,
                  null => "",
                };

                body = _buildCreateUserForm(
                  theme,
                  _formKeyUser,
                  _nameController,
                  _emailController,
                );
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  continueAction.value = () {
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
                });
              } else {
                final userData = snapshot.data!;
                // Adjust key based on your actual database structure
                final name = userData['name'] ?? AppLocalizations.of(context)!.unknownUser;
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
                          '${userData["user_id"]}',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.disabledColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
                // Action: Just advance to the next step
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  continueAction.value = _nextStep;
                });
              }

              return body;
            },
          ),
          [
            SizedBox.shrink(), // Placeholder for potential back button?
            ValueListenableBuilder(
              valueListenable: continueAction,
              builder:
                  (context, value, child) => TextButton(
                    onPressed: value,
                    child: Text(AppLocalizations.of(context)!.continueText),
                  ),
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
                  AppLocalizations.of(context)!.missingItems,
                  style: TextStyle(color: theme.colorScheme.error),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            [SizedBox.shrink()],
          );
        } else {
          if (_work case ExistingWork(id: final workId, instance: final instanceId)) {
            if (_user case ExistingUser(id: final userId)) {
              _checkoutFuture = DatabaseHelper.instance.checkExistingCheckout(
                workId,
                instanceId,
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
                      snapshot.error?.toString() ?? "",
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

              final l10n = AppLocalizations.of(context)!;
              final userName = switch (_user) {
                ExistingUser() =>
                  userData?['name'] as String? ?? l10n.unknownUser,
                CreateUser(:final name) => name,
                _ => l10n.unknownUser,
              };

              final workTitle = switch (_work) {
                ExistingWork() =>
                  workData?['title'] as String? ?? l10n.unknownTitle,
                CreateWork(:final name) => name,
                _ => l10n.unknownTitle,
              };

              final workInstance = switch (_work) {
                ExistingWork(:final instance) => instance,
                CreateWork(:final instance) => instance,
                _ => null,
              };

              final workInstanceText = workInstance?.toString() ?? "??";

              final workComposer = switch (_work) {
                ExistingWork() => workData?['composer'] as String?,
                CreateWork(:final composer) => composer,
                _ => null,
              };

              final workTitleText = '$workTitle #$workInstanceText';

              final workDisplay =
                  workComposer?.isNotEmpty == true
                      ? '$workTitleText by $workComposer'
                      : workTitleText;

              final actionText =
                  isReturning
                      ? AppLocalizations.of(context)!.returning
                      : AppLocalizations.of(context)!.checkingOut;

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
                            TextSpan(text: '\n$actionText\n'),
                            TextSpan(
                              text: workDisplay,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      ...(kReleaseMode
                          ? []
                          : [
                            const SizedBox(height: 8),
                            Text(
                              '(Work ID: $_work, User ID: $_user)',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.disabledColor,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ]),
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
                  (_user != null && _work != null && !_isFinalizingCheckout) ? _nextStep : null,
              label: Text(AppLocalizations.of(context)!.finalize),
              icon:
                  _isFinalizingCheckout
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
      setState(() {
        _isFinalizingCheckout = true;
      });

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
              created
                  ? AppLocalizations.of(context)!.checkoutSuccess
                  : AppLocalizations.of(context)!.returnSuccess,
            ),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.checkoutFailed(e.toString())),
            backgroundColor: Theme.of(context).colorScheme.error,
            showCloseIcon: true,
          ),
        );
        rethrow;
      } finally {
        if (mounted) {
          setState(() {
            _isFinalizingCheckout = false;
          });
        }
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
    HapticFeedback.heavyImpact();
    super.dispose();
    _scannerController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    var (body, footer) = _buildStepContent(_currentStep);
    return PopScope(
      canPop: _currentStep == 0,
      onPopInvokedWithResult: (didPop, result) => {_previousStep()},
      child: Padding(
        padding: MediaQuery.of(context).viewInsets,
        child: SizedBox(
          // Adjust height factor as needed (e.g., 0.7 for 70% of screen height)
          height: 400,
          child: Padding(
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
              AppLocalizations.of(context)!.addWork,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: titleController,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.title,
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return AppLocalizations.of(context)!.pleaseEnterTitle;
                }
                return null;
              },
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
              AppLocalizations.of(context)!.addPerson,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.name,
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return AppLocalizations.of(context)!.pleaseEnterName;
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'main.dart';
import 'l10n/app_localizations.dart';

class WorksView extends StatefulWidget {
  final WriteModel writeModel;

  const WorksView({super.key, required this.writeModel});

  @override
  State<WorksView> createState() => _WorksViewState();
}

class _WorksViewState extends State<WorksView> {
  List<Map<String, dynamic>> _works = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadWorks();
  }

  Future<void> _loadWorks() async {
    try {
      final works = await DatabaseHelper.instance.fetchAllWorks();
      if (mounted) {
        setState(() {
          _works = works;
          _isLoading = false;
          _error = null;
        });
      }
    } catch (e) {
      print("Error loading works: $e");
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = "failedToRefresh"; // Will be localized in build
        });
      }
    }
  }

  void _showAddWorkDialog() {
    final workIdController = TextEditingController();
    final titleController = TextEditingController();
    final composerController = TextEditingController();

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(AppLocalizations.of(context)!.addNewWork),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: workIdController,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.workId,
                    border: const OutlineInputBorder(),
                    helperText: AppLocalizations.of(context)!.workIdHelperMaxLength,
                  ),
                  maxLength: 15,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.titleOptional,
                    border: const OutlineInputBorder(),
                    helperText: AppLocalizations.of(context)!.titleHelper,
                  ),
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: composerController,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.composerOptional,
                    border: const OutlineInputBorder(),
                  ),
                  textCapitalization: TextCapitalization.words,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(AppLocalizations.of(context)!.cancel),
              ),
              FilledButton(
                onPressed: () async {
                  final workId = workIdController.text.trim();
                  if (workId.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(AppLocalizations.of(context)!.workIdRequired)),
                    );
                    return;
                  }

                  Navigator.of(context).pop();

                  try {
                    final title =
                        titleController.text.trim().isEmpty
                            ? workId
                            : titleController.text.trim();
                    final composer =
                        composerController.text.trim().isEmpty
                            ? null
                            : composerController.text.trim();

                    await DatabaseHelper.instance.createWork(
                      workId,
                      title,
                      composer,
                    );
                    await _loadWorks();

                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(AppLocalizations.of(context)!.workCreatedSuccess(workId)),
                        ),
                      );
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(AppLocalizations.of(context)!.failedToCreateWork(e.toString())),
                          backgroundColor: Theme.of(context).colorScheme.error,
                        ),
                      );
                    }
                  }
                },
                child: Text(AppLocalizations.of(context)!.addWorkButton),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return RefreshIndicator(
        onRefresh: _loadWorks,
        child: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: Text(
                  AppLocalizations.of(context)!.failedToRefresh,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadWorks,
      child: ListView.builder(
        itemCount: _works.length,
        itemBuilder: (context, index) {
          final work = _works[index];
          return WorkCard(work: work, onWorkUpdated: _loadWorks);
        },
      ),
    );
  }
}

class WorkCard extends StatelessWidget {
  final Map<String, dynamic> work;
  final VoidCallback onWorkUpdated;

  const WorkCard({super.key, required this.work, required this.onWorkUpdated});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final title = work['title']?.toString() ?? l10n.unknown;
    final composer = work['composer']?.toString();
    final workId = work['work_id']?.toString() ?? '';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          child: Icon(
            Icons.library_music,
            color: Theme.of(context).colorScheme.onPrimaryContainer,
          ),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.idLabel(workId)),
            if (composer != null && composer.isNotEmpty)
              Text(l10n.composerLabel(composer)),
          ],
        ),
        isThreeLine: composer != null && composer.isNotEmpty,
      ),
    );
  }

  void _showBarcodeDialog(BuildContext context, Map<String, dynamic> work) {
    final l10n = AppLocalizations.of(context)!;
    final workId = work['work_id']?.toString() ?? '';
    final title = work['title']?.toString() ?? l10n.unknown;

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(l10n.barcodeForTitle(title)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(l10n.workIdLabel(workId)),
                const SizedBox(height: 16),
                Text(
                  l10n.barcodeComingSoon,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(l10n.close),
              ),
            ],
          ),
    );
  }

  void _showDeleteConfirmation(
    BuildContext context,
    Map<String, dynamic> work,
    VoidCallback onWorkUpdated,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final title = work['title']?.toString() ?? l10n.unknown;

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(l10n.deleteWork),
            content: Text(l10n.confirmDeleteWork(title)),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(l10n.cancel),
              ),
              FilledButton(
                onPressed: () async {
                  Navigator.of(context).pop();

                  try {
                    // Note: You may want to add a deleteWork method to DatabaseHelper
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(l10n.workDeletionNotImplemented),
                      ),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(l10n.failedToDeleteWork(e.toString())),
                        backgroundColor: Theme.of(context).colorScheme.error,
                      ),
                    );
                  }
                },
                style: FilledButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.error,
                ),
                child: Text(l10n.delete),
              ),
            ],
          ),
    );
  }
}

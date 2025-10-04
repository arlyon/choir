import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'main.dart';

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
          _error = "Failed to refresh data. Check connection or logs.";
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
            title: const Text('Add New Work'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: workIdController,
                  decoration: const InputDecoration(
                    labelText: 'Work ID',
                    border: OutlineInputBorder(),
                    helperText: 'Unique identifier for the work',
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Title (optional)',
                    border: OutlineInputBorder(),
                    helperText: 'If empty, will use Work ID as title',
                  ),
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: composerController,
                  decoration: const InputDecoration(
                    labelText: 'Composer (optional)',
                    border: OutlineInputBorder(),
                  ),
                  textCapitalization: TextCapitalization.words,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () async {
                  final workId = workIdController.text.trim();
                  if (workId.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Work ID is required')),
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
                          content: Text('Work "$workId" created successfully'),
                        ),
                      );
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Failed to create work: $e'),
                          backgroundColor: Theme.of(context).colorScheme.error,
                        ),
                      );
                    }
                  }
                },
                child: const Text('Add Work'),
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
                  _error!,
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
    final title = work['title']?.toString() ?? 'Unknown';
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
            Text('ID: $workId'),
            if (composer != null && composer.isNotEmpty)
              Text('Composer: $composer'),
          ],
        ),
        isThreeLine: composer != null && composer.isNotEmpty,
      ),
    );
  }

  void _showBarcodeDialog(BuildContext context, Map<String, dynamic> work) {
    final workId = work['work_id']?.toString() ?? '';
    final title = work['title']?.toString() ?? 'Unknown';

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Barcode for "$title"'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Work ID: $workId'),
                const SizedBox(height: 16),
                Text(
                  'Barcode generation feature coming soon!',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
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
    final title = work['title']?.toString() ?? 'this work';

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Work'),
            content: Text('Are you sure you want to delete "$title"?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () async {
                  Navigator.of(context).pop();

                  try {
                    // Note: You may want to add a deleteWork method to DatabaseHelper
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Work deletion not implemented yet'),
                      ),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Failed to delete work: $e'),
                        backgroundColor: Theme.of(context).colorScheme.error,
                      ),
                    );
                  }
                },
                style: FilledButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.error,
                ),
                child: const Text('Delete'),
              ),
            ],
          ),
    );
  }
}

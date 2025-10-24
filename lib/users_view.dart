import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'main.dart';
import 'l10n/app_localizations.dart';

class UsersView extends StatefulWidget {
  final WriteModel writeModel;

  const UsersView({super.key, required this.writeModel});

  @override
  State<UsersView> createState() => _UsersViewState();
}

// Public interface to access UsersView state
abstract class UsersViewState extends State<UsersView> {
  List<Map<String, dynamic>> get selectedUsers;
  void clearSelection();
}

class _UsersViewState extends UsersViewState {
  List<Map<String, dynamic>> _users = [];
  bool _isLoading = true;
  String? _error;
  final Set<String> _selectedUserIds = {};

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  void _toggleUserSelection(String userId) {
    setState(() {
      if (_selectedUserIds.contains(userId)) {
        _selectedUserIds.remove(userId);
      } else {
        _selectedUserIds.add(userId);
      }
    });
  }

  @override
  void clearSelection() {
    setState(() {
      _selectedUserIds.clear();
    });
  }

  Future<void> _loadUsers() async {
    try {
      final users = await DatabaseHelper.instance.fetchAllUsers();
      if (mounted) {
        setState(() {
          _users = users;
          _isLoading = false;
          _error = null;
        });
      }
    } catch (e) {
      print("Error loading users: $e");
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = "failedToRefresh"; // Will be localized in build
        });
      }
    }
  }

  void _showAddUserDialog() {
    final userIdController = TextEditingController();
    final nameController = TextEditingController();
    final emailController = TextEditingController();

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(AppLocalizations.of(context)!.addNewUser),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: userIdController,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.userId,
                    border: const OutlineInputBorder(),
                    helperText: AppLocalizations.of(context)!.userIdHelperMaxLength,
                  ),
                  maxLength: 15,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.nameOptional,
                    border: const OutlineInputBorder(),
                    helperText: AppLocalizations.of(context)!.nameHelper,
                  ),
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.emailOptional,
                    border: const OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
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
                  final userId = userIdController.text.trim();
                  if (userId.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(AppLocalizations.of(context)!.userIdRequired)),
                    );
                    return;
                  }

                  Navigator.of(context).pop();

                  try {
                    final name =
                        nameController.text.trim().isEmpty
                            ? userId
                            : nameController.text.trim();
                    final email =
                        emailController.text.trim().isEmpty
                            ? null
                            : emailController.text.trim();

                    await DatabaseHelper.instance.createUser(
                      userId,
                      name,
                      email,
                    );
                    await _loadUsers();

                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(AppLocalizations.of(context)!.userCreatedSuccess(userId)),
                        ),
                      );
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(AppLocalizations.of(context)!.failedToCreateUser(e.toString())),
                          backgroundColor: Theme.of(context).colorScheme.error,
                        ),
                      );
                    }
                  }
                },
                child: Text(AppLocalizations.of(context)!.addUserButton),
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
        onRefresh: _loadUsers,
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
      onRefresh: _loadUsers,
      child: ListView.builder(
        itemCount: _users.length,
        itemBuilder: (context, index) {
          final user = _users[index];
          final userId = user['user_id']?.toString() ?? '';
          final isSelected = _selectedUserIds.contains(userId);
          return UserCard(
            user: user,
            onUserUpdated: _loadUsers,
            isSelected: isSelected,
            onLongPress: () => _toggleUserSelection(userId),
            onTap: _selectedUserIds.isNotEmpty ? () => _toggleUserSelection(userId) : null,
          );
        },
      ),
    );
  }

  @override
  List<Map<String, dynamic>> get selectedUsers {
    if (_selectedUserIds.isEmpty) {
      return _users;
    }
    return _users.where((user) => _selectedUserIds.contains(user['user_id'])).toList();
  }
}

class UserCard extends StatelessWidget {
  final Map<String, dynamic> user;
  final VoidCallback onUserUpdated;
  final bool isSelected;
  final VoidCallback onLongPress;
  final VoidCallback? onTap;

  const UserCard({
    super.key,
    required this.user,
    required this.onUserUpdated,
    required this.isSelected,
    required this.onLongPress,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final name = user['name']?.toString() ?? l10n.unknown;
    final email = user['email']?.toString();
    final userId = user['user_id']?.toString() ?? '';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        onTap: onTap,
        onLongPress: onLongPress,
        leading: CircleAvatar(
          backgroundColor: isSelected ? Theme.of(context).colorScheme.primary : null,
          child: isSelected
              ? Icon(Icons.check, color: Theme.of(context).colorScheme.onPrimary)
              : Text(
                  name.isNotEmpty ? name[0].toUpperCase() : '?',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
        ),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.w500)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.idLabel(userId)),
            if (email != null && email.isNotEmpty) Text(l10n.emailLabel(email)),
          ],
        ),
        isThreeLine: email != null && email.isNotEmpty,
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'delete') {
              _showDeleteConfirmation(context, user, onUserUpdated);
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem<String>(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, color: Theme.of(context).colorScheme.error),
                  const SizedBox(width: 8),
                  Text(l10n.delete),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showDeleteConfirmation(
    BuildContext context,
    Map<String, dynamic> user,
    VoidCallback onUserUpdated,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final name = user['name']?.toString() ?? l10n.unknown;
    final userId = user['user_id']?.toString() ?? '';
    final nameController = TextEditingController();

    // Check if user has any active checkouts
    final activeCheckouts = await DatabaseHelper.instance.query(
      'SELECT COUNT(*) as count FROM checkouts WHERE user_id = ? AND return_timestamp IS NULL',
      positional: [userId],
    );

    final hasActiveCheckouts = (activeCheckouts.first['count'] as int) > 0;

    if (!context.mounted) return;

    if (hasActiveCheckouts) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(l10n.deleteUser),
          content: Text(l10n.cannotDeleteUserWithCheckouts(name)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l10n.cancel),
            ),
          ],
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteUser),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.confirmDeleteUser(name)),
            const SizedBox(height: 16),
            Text(
              l10n.typeNameToConfirm(name),
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                hintText: name,
                border: const OutlineInputBorder(),
              ),
              autofocus: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () async {
              if (nameController.text.trim() != name) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(l10n.nameDoesNotMatch),
                    backgroundColor: Theme.of(context).colorScheme.error,
                  ),
                );
                return;
              }

              Navigator.of(context).pop();

              try {
                await DatabaseHelper.instance.execute(
                  'DELETE FROM users WHERE user_id = ?',
                  positional: [userId],
                );
                onUserUpdated();

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(l10n.userDeletedSuccess(name)),
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(l10n.failedToDeleteUser(e.toString())),
                      backgroundColor: Theme.of(context).colorScheme.error,
                    ),
                  );
                }
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

import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'main.dart';

class UsersView extends StatefulWidget {
  final WriteModel writeModel;

  const UsersView({super.key, required this.writeModel});

  @override
  State<UsersView> createState() => _UsersViewState();
}

class _UsersViewState extends State<UsersView> {
  List<Map<String, dynamic>> _users = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    try {
      final users = await DatabaseHelper.instance.fetchAllUsers();
      if (mounted) {
        setState(() {
          _users = users;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load users: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  void _showAddUserDialog() {
    final userIdController = TextEditingController();
    final nameController = TextEditingController();
    final emailController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New User'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: userIdController,
              decoration: const InputDecoration(
                labelText: 'User ID',
                border: OutlineInputBorder(),
                helperText: 'Unique identifier for the user',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Name (optional)',
                border: OutlineInputBorder(),
                helperText: 'If empty, will use User ID as name',
              ),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'Email (optional)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
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
              final userId = userIdController.text.trim();
              if (userId.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('User ID is required')),
                );
                return;
              }

              Navigator.of(context).pop();

              try {
                final name = nameController.text.trim().isEmpty
                    ? userId
                    : nameController.text.trim();
                final email = emailController.text.trim().isEmpty
                    ? null
                    : emailController.text.trim();

                await DatabaseHelper.instance.createUser(userId, name, email);
                await _loadUsers();

                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('User "$userId" created successfully')),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to create user: $e'),
                      backgroundColor: Theme.of(context).colorScheme.error,
                    ),
                  );
                }
              }
            },
            child: const Text('Add User'),
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

    return RefreshIndicator(
      onRefresh: _loadUsers,
      child: ListView.builder(
        itemCount: _users.length,
        itemBuilder: (context, index) {
          final user = _users[index];
          return UserCard(user: user, onUserUpdated: _loadUsers);
        },
      ),
    );
  }
}

class UserCard extends StatelessWidget {
  final Map<String, dynamic> user;
  final VoidCallback onUserUpdated;

  const UserCard({
    super.key,
    required this.user,
    required this.onUserUpdated,
  });

  @override
  Widget build(BuildContext context) {
    final name = user['name']?.toString() ?? 'Unknown';
    final email = user['email']?.toString();
    final userId = user['user_id']?.toString() ?? '';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          child: Text(
            name.isNotEmpty ? name[0].toUpperCase() : '?',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(
          name,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ID: $userId'),
            if (email != null && email.isNotEmpty)
              Text('Email: $email'),
          ],
        ),
        isThreeLine: email != null && email.isNotEmpty,
        trailing: PopupMenuButton<String>(
          onSelected: (value) async {
            if (value == 'delete') {
              _showDeleteConfirmation(context, user, onUserUpdated);
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete_outline),
                  SizedBox(width: 8),
                  Text('Delete'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(
    BuildContext context,
    Map<String, dynamic> user,
    VoidCallback onUserUpdated,
  ) {
    final name = user['name']?.toString() ?? 'this user';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete User'),
        content: Text('Are you sure you want to delete "$name"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.of(context).pop();

              try {
                // Note: You may want to add a deleteUser method to DatabaseHelper
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('User deletion not implemented yet')),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Failed to delete user: $e'),
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
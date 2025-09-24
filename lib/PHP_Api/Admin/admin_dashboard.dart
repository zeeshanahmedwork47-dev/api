import 'package:api_testing/PHP_Api/api_service.dart';
import 'package:api_testing/PHP_Api/login_user.dart';
import 'package:flutter/material.dart';
import '../../utils/php_styles.dart';


class AdminDashboardScreen extends StatefulWidget {
  final Map<String, dynamic> adminData;

  const AdminDashboardScreen({super.key, required this.adminData});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  List<dynamic> _users = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _filteredUsers = [];

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadUsers() async {
    setState(() {
      _isLoading = true;
    });

    final result = await ApiService.getAllUsers();

    if (mounted) {
      setState(() {
        _isLoading = false;
        if (result['success']) {
          _users = result['users'];
          _filteredUsers = _users;
        }
      });
    }
  }

  void _filterUsers(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredUsers = _users;
      } else {
        _filteredUsers = _users.where((user) {
          return user['name'].toLowerCase().contains(query.toLowerCase()) ||
              user['email'].toLowerCase().contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  Future<void> _updateUser(Map<String, dynamic> user) async {
    final result = await ApiService.updateUser(
      userId: user['id'],
      name: user['name'],
      email: user['email'],
      isActive: user['is_active'] == 1,
    );

    if (result['success']) {
      _showSuccessMessage('User updated successfully');
      _loadUsers();
    } else {
      _showErrorMessage(result['message']);
    }
  }

  Future<void> _deleteUser(int userId) async {
    final confirmed = await _showConfirmDialog(
      'Delete User',
      'Are you sure you want to delete this user? This action cannot be undone.',
    );

    if (confirmed) {
      final result = await ApiService.deleteUser(userId: userId);

      if (result['success']) {
        _showSuccessMessage('User deleted successfully');
        _loadUsers();
      } else {
        _showErrorMessage(result['message']);
      }
    }
  }

  Future<void> _toggleUserStatus(Map<String, dynamic> user) async {
    final newStatus = user['is_active'] == 1 ? 0 : 1;
    final action = newStatus == 1 ? 'activate' : 'deactivate';

    final confirmed = await _showConfirmDialog(
      'User Status',
      'Are you sure you want to $action this user?',
    );

    if (confirmed) {
      user['is_active'] = newStatus;
      await _updateUser(user);
    }
  }

  Future<bool> _showConfirmDialog(String title, String message) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );
    return result ?? false;
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppStyles.successColor,
      ),
    );
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppStyles.errorColor,
      ),
    );
  }

  void _logout() async {
    final confirmed = await _showConfirmDialog(
      'Logout',
      'Are you sure you want to logout from admin panel?',
    );

    if (confirmed) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
            (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppStyles.backgroundColor,
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: AppStyles.adminPrimaryColor,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: _loadUsers,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
          IconButton(
            onPressed: _logout,
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: Column(
        children: [
          // Admin Info Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppStyles.adminPrimaryColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome, ${widget.adminData['name']}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Total Users: ${_users.length}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),

          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              onChanged: _filterUsers,
              decoration: InputDecoration(
                hintText: 'Search users by name or email...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                  onPressed: () {
                    _searchController.clear();
                    _filterUsers('');
                  },
                  icon: const Icon(Icons.clear),
                )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),

          // Users List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredUsers.isEmpty
                ? const Center(
              child: Text(
                'No users found',
                style: AppStyles.subHeadingStyle,
              ),
            )
                : RefreshIndicator(
              onRefresh: _loadUsers,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _filteredUsers.length,
                itemBuilder: (context, index) {
                  final user = _filteredUsers[index];
                  return _buildUserCard(user);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserCard(Map<String, dynamic> user) {
    final isActive = user['is_active'] == 1;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // User Avatar
                CircleAvatar(
                  backgroundColor: isActive ? AppStyles.primaryColor : AppStyles.borderColor,
                  child: Text(
                    user['name'][0].toUpperCase(),
                    style: TextStyle(
                      color: isActive ? Colors.white : AppStyles.textSecondaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // User Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user['name'],
                        style: AppStyles.subHeadingStyle,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        user['email'],
                        style: AppStyles.captionStyle,
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: isActive ? AppStyles.successColor : AppStyles.errorColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          isActive ? 'Active' : 'Inactive',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Actions
                PopupMenuButton<String>(
                  onSelected: (value) {
                    switch (value) {
                      case 'toggle':
                        _toggleUserStatus(user);
                        break;
                      case 'delete':
                        _deleteUser(user['id']);
                        break;
                    }
                  },
                  itemBuilder: (BuildContext context) => [
                    PopupMenuItem<String>(
                      value: 'toggle',
                      child: Row(
                        children: [
                          Icon(isActive ? Icons.block : Icons.check_circle),
                          const SizedBox(width: 8),
                          Text(isActive ? 'Deactivate' : 'Activate'),
                        ],
                      ),
                    ),
                    const PopupMenuItem<String>(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, color: AppStyles.errorColor),
                          SizedBox(width: 8),
                          Text('Delete', style: TextStyle(color: AppStyles.errorColor)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 12),

            // User Details
            Row(
              children: [
                Icon(Icons.badge, size: 16, color: AppStyles.textSecondaryColor),
                const SizedBox(width: 4),
                Text(
                  'ID: ${user['id']}',
                  style: AppStyles.captionStyle,
                ),
                const Spacer(),
                Icon(Icons.access_time, size: 16, color: AppStyles.textSecondaryColor),
                const SizedBox(width: 4),
                Text(
                  'Joined: ${_formatDate(user['created_at'])}',
                  style: AppStyles.captionStyle,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'Unknown';
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return 'Unknown';
    }
  }
}
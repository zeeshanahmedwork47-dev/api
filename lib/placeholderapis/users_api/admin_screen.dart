import 'package:api_testing/placeholderapis/users_api/authservice.dart';
import 'package:flutter/material.dart';

import 'add_user.dart';

import 'edit_user.dart';


class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  List<Map<String, dynamic>> _users = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAllUsers();
  }

  Future<void> _loadAllUsers() async {
    final users = await AuthService.getAllUsers();
    if (mounted) {
      setState(() {
        _users = users;
        _isLoading = false;
      });
    }
  }

  void _goToAddUserScreen() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddUserScreen()),
    );
    _loadAllUsers();
  }

  Future<void> _deleteUser(Map<String, dynamic> user) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete User'),
        content: Text('Are you sure you want to delete ${user['name']}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final result = await AuthService.deleteUser(user['id']);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message']),
            backgroundColor: result['success'] ? Colors.green : Colors.red,
          ),
        );

        if (result['success']) {
          _loadAllUsers();
        }
      }
    }
  }

  void _showUserDetailsPopup(Map<String, dynamic> user) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.8,
              maxWidth: 400,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.teal.shade400, Colors.teal.shade600],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.white,
                        child: Text(
                          user['name'].toString().split(' ').map((word) => word[0]).join(),
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.teal.shade700,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        user['name'],
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        '@${user['username']}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),

                // Details
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildPopupSection('Contact', [
                          _buildPopupRow('Email', user['email'], Icons.email),
                          _buildPopupRow('Phone', user['phone'], Icons.phone),
                          _buildPopupRow('Website', user['website'], Icons.language),
                        ]),

                        const SizedBox(height: 16),

                        _buildPopupSection('Address', [
                          _buildPopupRow('Street', '${user['address']['street']}, ${user['address']['suite']}', Icons.home),
                          _buildPopupRow('City', user['address']['city'], Icons.location_city),
                          _buildPopupRow('Zipcode', user['address']['zipcode'], Icons.local_post_office),
                        ]),

                        const SizedBox(height: 16),

                        _buildPopupSection('Company', [
                          _buildPopupRow('Name', user['company']['name'], Icons.corporate_fare),
                          _buildPopupRow('Catchphrase', user['company']['catchPhrase'], Icons.format_quote),
                          _buildPopupRow('Business', user['company']['bs'], Icons.work),
                        ]),
                      ],
                    ),
                  ),
                ),

                // Action Buttons
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () async {
                                Navigator.of(context).pop(); // Close popup
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => EditUserScreen(
                                      user: user,
                                      isPatchMode: true, // PATCH mode
                                    ),
                                  ),
                                );
                                _loadAllUsers();
                              },
                              icon: const Icon(Icons.edit),
                              label: const Text('PATCH'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () async {
                                Navigator.of(context).pop(); // Close popup
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => EditUserScreen(
                                      user: user,
                                      isPatchMode: false, // PUT mode
                                    ),
                                  ),
                                );
                                _loadAllUsers();
                              },
                              icon: const Icon(Icons.update),
                              label: const Text('PUT'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.purple,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.of(context).pop(); // Close popup
                                _deleteUser(user);
                              },
                              icon: const Icon(Icons.delete),
                              label: const Text('DELETE'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text('Close'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPopupSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.teal.shade700,
          ),
        ),
        const SizedBox(height: 8),
        ...children,
      ],
    );
  }

  Widget _buildPopupRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: Colors.grey.shade600),
          const SizedBox(width: 8),
          SizedBox(
            width: 70,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 12,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 12),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal.shade50,
      appBar: AppBar(
        title: const Text('Admin Panel'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add),
            onPressed: _goToAddUserScreen,
            tooltip: 'Add New User',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.teal),
            SizedBox(height: 16),
            Text('Loading users...', style: TextStyle(color: Colors.teal)),
          ],
        ),
      )
          : SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'All Users (${_users.length})',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal.shade700,
                ),
              ),
            ),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: GridView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: MediaQuery.of(context).size.width > 600 ? 3 : 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.1,
                  ),
                  itemCount: _users.length,
                  itemBuilder: (context, index) {
                    final user = _users[index];
                    return Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: InkWell(
                        onTap: () => _showUserDetailsPopup(user),
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircleAvatar(
                                radius: 22,
                                backgroundColor: Colors.teal,
                                child: Text(
                                  user['name'].toString().split(' ').map((word) => word[0]).join(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'ID: ${user['id']}',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.teal.shade700,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Flexible(
                                child: Text(
                                  user['name'],
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '@${user['username']}',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey.shade600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
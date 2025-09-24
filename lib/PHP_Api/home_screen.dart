import 'package:api_testing/PHP_Api/login_user.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/php_styles.dart';

class HomeScreen extends StatefulWidget {
  final Map<String, dynamic> userData;

  const HomeScreen({super.key, required this.userData});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppStyles.backgroundColor,
      appBar: AppBar(
        title: const Text('Home'),
        backgroundColor: AppStyles.primaryColor,
        automaticallyImplyLeading: false,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'logout') {
                _logout();
              } else if (value == 'profile') {
                _showProfile();
              }
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem<String>(
                value: 'profile',
                child: Row(
                  children: [
                    Icon(Icons.person),
                    SizedBox(width: 8),
                    Text('Profile'),
                  ],
                ),
              ),
              const PopupMenuItem<String>(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout),
                    SizedBox(width: 8),
                    Text('Logout'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(
                  colors: [AppStyles.primaryColor, AppStyles.secondaryColor],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Welcome Back!',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Hello, ${widget.userData['name']}',
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'User ID: ${widget.userData['id']}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // User Info Section
            const Text(
              'Account Information',
              style: AppStyles.subHeadingStyle,
            ),
            const SizedBox(height: 16),

            Container(
              padding: const EdgeInsets.all(20),
              decoration: AppStyles.cardDecoration,
              child: Column(
                children: [
                  _buildInfoRow(Icons.person, 'Name', widget.userData['name']),
                  const Divider(),
                  _buildInfoRow(Icons.email, 'Email', widget.userData['email']),
                  const Divider(),
                  _buildInfoRow(
                      Icons.access_time,
                      'Member Since',
                      _formatDate(widget.userData['created_at'])
                  ),
                  const Divider(),
                  _buildInfoRow(
                    Icons.verified_user,
                    'Status',
                    widget.userData['is_active'] == 1 ? 'Active' : 'Inactive',
                    statusColor: widget.userData['is_active'] == 1
                        ? AppStyles.successColor
                        : AppStyles.errorColor,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // Quick Actions
            const Text(
              'Quick Actions',
              style: AppStyles.subHeadingStyle,
            ),
            const SizedBox(height: 16),

            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                _buildActionCard(
                  Icons.edit,
                  'Edit Profile',
                  'Update your information',
                  AppStyles.primaryColor,
                      () => _showComingSoon(),
                ),
                _buildActionCard(
                  Icons.security,
                  'Security',
                  'Change password',
                  AppStyles.warningColor,
                      () => _showComingSoon(),
                ),
                _buildActionCard(
                  Icons.settings,
                  'Settings',
                  'App preferences',
                  AppStyles.infoColor,
                      () => _showComingSoon(),
                ),
                _buildActionCard(
                  Icons.help,
                  'Help & Support',
                  'Get assistance',
                  AppStyles.successColor,
                      () => _showComingSoon(),
                ),
              ],
            ),

            const SizedBox(height: 30),

            // App Info
            Container(
              padding: const EdgeInsets.all(20),
              decoration: AppStyles.cardDecoration,
              child: const Column(
                children: [
                  Text(
                    'Flutter Authentication App',
                    style: AppStyles.subHeadingStyle,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Version 1.0.0',
                    style: AppStyles.captionStyle,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'This app demonstrates a complete authentication system with user registration, login, password reset, and admin panel features.',
                    style: AppStyles.bodyStyle,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, {Color? statusColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: AppStyles.primaryColor),
          const SizedBox(width: 16),
          Text(
            label,
            style: AppStyles.bodyStyle.copyWith(fontWeight: FontWeight.w600),
          ),
          const Spacer(),
          Text(
            value,
            style: AppStyles.bodyStyle.copyWith(
              color: statusColor ?? AppStyles.textSecondaryColor,
              fontWeight: statusColor != null ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(IconData icon, String title, String subtitle, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: AppStyles.cardDecoration,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 30, color: color),
            const SizedBox(height: 8),
            Text(
              title,
              style: AppStyles.bodyStyle.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: AppStyles.captionStyle,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return 'Unknown';
    try {
      DateTime date = DateTime.parse(dateStr);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return 'Unknown';
    }
  }

  void _showProfile() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: const Text('Profile'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Name: ${widget.userData['name']}'),
              Text('Email: ${widget.userData['email']}'),
              Text('ID: ${widget.userData['id']}'),
              Text('Status: ${widget.userData['is_active'] == 1 ? 'Active' : 'Inactive'}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _showComingSoon() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Feature coming soon!'),
        backgroundColor: AppStyles.infoColor,
      ),
    );
  }

  void _logout() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.remove('user_data');

                if (mounted) {
                  Navigator.of(context).pop();
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                        (route) => false,
                  );
                }
              },
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }
}
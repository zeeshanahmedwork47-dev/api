import 'package:api_testing/placeholderapis/users_api/authservice.dart';
import 'package:api_testing/placeholderapis/users_api/login.dart';
import 'package:flutter/material.dart';
import 'admin_screen.dart';

class DashboardScreen extends StatefulWidget {
  final Map<String, dynamic> user;

  const DashboardScreen({super.key, required this.user});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Map<String, dynamic>? _userDetails;
  bool _isLoading = true;
  bool _isLoggingOut = false;

  @override
  void initState() {
    super.initState();
    _loadUserDetails();
  }

  Future<void> _loadUserDetails() async {
    try {
      // Get fresh user details (checks local modifications)
      final userDetails = await AuthService.getUserById(widget.user['id']);

      if (mounted) {
        setState(() {
          _userDetails = userDetails ?? widget.user;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _userDetails = widget.user;
          _isLoading = false;
        });
      }
    }
  }
  Future<void> _logout() async {
    setState(() {
      _isLoggingOut = true;
    });

    await Future.delayed(const Duration(milliseconds: 500));

    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
            (route) => false,
      );
    }
  }

  Future<void> _refreshUserData() async {
    setState(() {
      _isLoading = true;
    });
    await _loadUserDetails();
  }



  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.teal.shade50,
        appBar: AppBar(
          title: const Text('Loading...'),
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: Colors.teal),
              SizedBox(height: 16),
              Text('Loading user details...', style: TextStyle(color: Colors.teal)),
            ],
          ),
        ),
      );
    }

    final user = _userDetails!;

    return Scaffold(
      backgroundColor: Colors.teal.shade50,
      appBar: AppBar(
        title: Text('Welcome, ${user['name'].toString().split(' ')[0]}'),
        automaticallyImplyLeading: false,
        actions: [
          // Admin Button

          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshUserData,
            tooltip: 'Refresh Data',
          ),
          IconButton(
            icon: _isLoggingOut
                ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            )
                : const Icon(Icons.logout),
            onPressed: _isLoggingOut ? null : _logout,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Profile Header Card
            Card(
              elevation: 4,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    colors: [Colors.teal.shade400, Colors.teal.shade600],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.white,
                      child: Text(
                        user['name'].toString().split(' ').map((word) => word[0]).join(),
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal.shade700,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      user['name'],
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '@${user['username']}',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        user['email'],
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Contact Information
            _buildInfoCard(
              'Contact Information',
              Icons.contact_phone,
              [
                _buildInfoRow('Email', user['email'], Icons.email),
                _buildInfoRow('Phone', user['phone'], Icons.phone),
                _buildInfoRow('Website', user['website'], Icons.language),
              ],
            ),

            const SizedBox(height: 16),

            // Address Information
            _buildInfoCard(
              'Address',
              Icons.location_on,
              [
                _buildInfoRow('Street', '${user['address']['street']}, ${user['address']['suite']}', Icons.home),
                _buildInfoRow('City', user['address']['city'], Icons.location_city),
                _buildInfoRow('Zipcode', user['address']['zipcode'], Icons.local_post_office),
                _buildInfoRow('Location', 'Lat: ${user['address']['geo']['lat']}, Lng: ${user['address']['geo']['lng']}', Icons.gps_fixed),
              ],
            ),

            const SizedBox(height: 16),

            // Company Information
            _buildInfoCard(
              'Company Details',
              Icons.business,
              [
                _buildInfoRow('Company', user['company']['name'], Icons.corporate_fare),
                _buildInfoRow('Catchphrase', user['company']['catchPhrase'], Icons.format_quote),
                _buildInfoRow('Business', user['company']['bs'], Icons.work),
              ],
            ),

            const SizedBox(height: 24),

            // Logout Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _isLoggingOut ? null : _logout,
                icon: _isLoggingOut
                    ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
                    : const Icon(Icons.logout),
                label: Text(_isLoggingOut ? 'Logging out...' : 'Logout'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade600,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, IconData titleIcon, List<Widget> children) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(titleIcon, color: Colors.teal, size: 24),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal.shade700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: Colors.grey.shade600),
          const SizedBox(width: 12),
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
import 'package:api_testing/placeholderapis/users_api/authservice.dart';
import 'package:api_testing/placeholderapis/users_api/dashboard.dart';
import 'package:flutter/material.dart';

import 'admin_screen.dart';


class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _isConnected = true;

  @override
  void initState() {
    super.initState();
    _testConnection();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _testConnection() async {
    final isConnected = await AuthService.testConnection();
    setState(() {
      _isConnected = isConnected;
    });

    if (!isConnected) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Unable to connect to server. Please check your internet connection.'),
          backgroundColor: Colors.orange,
          action: SnackBarAction(
            label: 'Retry',
            onPressed: _testConnection,
            textColor: Colors.white,
          ),
        ),
      );
    }
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      if (!_isConnected) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No internet connection. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      setState(() {
        _isLoading = true;
      });

      final result = await AuthService.login(
        _usernameController.text.trim(),
        _passwordController.text,
      );

      setState(() {
        _isLoading = false;
      });

      if (result['success']) {
        // Navigate to dashboard
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => DashboardScreen(user: result['user']),
          ),
        );
      } else {
        // Show error message with more details
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message']),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }
  void _goToAdminScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AdminScreen()),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal.shade50,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Connection Status Indicator
                if (!_isConnected)
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.red.shade100,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.shade300),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.wifi_off, color: Colors.red.shade700),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'No internet connection',
                            style: TextStyle(color: Colors.red.shade700),
                          ),
                        ),
                        TextButton(
                          onPressed: _testConnection,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),

                // Logo/Icon
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.teal,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.teal.withValues(alpha: 0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.person,
                    size: 60,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 40),

                // Title
                Text(
                  'Welcome Back',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal.shade700,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  'Sign in to your account',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade600,
                  ),
                ),

                const SizedBox(height: 48),

                // Login Form
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // Username/Email Field
                      TextFormField(
                        controller: _usernameController,
                        decoration: const InputDecoration(
                          labelText: 'Username or Email',
                          prefixIcon: Icon(Icons.person_outline),
                          //hintText: 'Try: Bret or Antonette',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter username or email';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 20),

                      // Password Field
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          prefixIcon: const Icon(Icons.lock_outline),
                          hintText: 'First 4 digits of phone number',
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword ? Icons.visibility : Icons.visibility_off,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter password';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 32),

                      // Login Button
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: (_isLoading || !_isConnected) ? null : _handleLogin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.teal,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 2,
                          ),
                          child: _isLoading
                              ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              strokeWidth: 2,
                            ),
                          )
                              : const Text(
                            'Sign In',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),
                ElevatedButton.icon(
                  icon: Icon(Icons.admin_panel_settings,color: Colors.black,size: 25,),
                    style: ButtonStyle(
                      backgroundColor: WidgetStatePropertyAll(Colors.red),
                    ),
                    onPressed: _goToAdminScreen, label: Text("Admin"),
                    ),


                // Demo credentials hint

              ],
            ),
          ),
        ),
      ),
    );
  }
}
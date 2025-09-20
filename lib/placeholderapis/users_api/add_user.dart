import 'package:api_testing/placeholderapis/users_api/authservice.dart';
import 'package:api_testing/placeholderapis/users_api/dashboard.dart';
import 'package:flutter/material.dart';

class AddUserScreen extends StatefulWidget {
  const AddUserScreen({super.key});

  @override
  State<AddUserScreen> createState() => _AddUserScreenState();
}

class _AddUserScreenState extends State<AddUserScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _websiteController = TextEditingController();
  final _streetController = TextEditingController();
  final _cityController = TextEditingController();
  final _zipcodeController = TextEditingController();
  final _companyController = TextEditingController();
  final _catchPhraseController = TextEditingController();

  bool _isCreating = false;

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _websiteController.dispose();
    _streetController.dispose();
    _cityController.dispose();
    _zipcodeController.dispose();
    _companyController.dispose();
    _catchPhraseController.dispose();
    super.dispose();
  }

  Future<void> _createUser() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isCreating = true;
      });

      final result = await AuthService.createUser(
        name: _nameController.text.trim(),
        username: _usernameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        website: _websiteController.text.trim(),
        street: _streetController.text.trim(),
        city: _cityController.text.trim(),
        zipcode: _zipcodeController.text.trim(),
        companyName: _companyController.text.trim(),
        catchPhrase: _catchPhraseController.text.trim(),
      );

      if (mounted) {
        setState(() {
          _isCreating = false;
        });

        if (result['success']) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message']),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 3),
            ),
          );

          // Show created user details
          _showUserCreatedDialog(result['user']);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message']),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 4),
            ),
          );
        }
      }
    }
  }

  void _showUserCreatedDialog(Map<String, dynamic> user) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green),
              const SizedBox(width: 8),
              const Text('User Created!'),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('New user has been created successfully:'),
                const SizedBox(height: 12),
                Text('ID: ${user['id']}', style: TextStyle(fontWeight: FontWeight.bold)),
                Text('Name: ${user['name']}'),
                Text('Username: ${user['username']}'),
                Text('Email: ${user['email']}'),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Login Password: ${AuthService.extractPasswordFromPhone(user['phone'])}',
                    style: TextStyle(
                      color: Colors.blue.shade700,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                Navigator.of(context).pop(); // Go back to admin
              },
              child: const Text('Close'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                Navigator.of(context).pop(); // Go back to admin
                // Navigate to dashboard with new user
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DashboardScreen(user: user),
                  ),
                );
              },
              child: const Text('View Profile'),
            ),
          ],

        );
      },
    );
  }

  void _clearForm() {
    _formKey.currentState?.reset();
    _nameController.clear();
    _usernameController.clear();
    _emailController.clear();
    _phoneController.clear();
    _websiteController.clear();
    _streetController.clear();
    _cityController.clear();
    _zipcodeController.clear();
    _companyController.clear();
    _catchPhraseController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal.shade50,
      appBar: AppBar(
        title: const Text('Add New User'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.clear_all),
            onPressed: _clearForm,
            tooltip: 'Clear Form',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Personal Information Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.person, color: Colors.teal),
                          const SizedBox(width: 8),
                          Text(
                            'Personal Information',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.teal.shade700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Full Name *',
                          prefixIcon: Icon(Icons.person_outline),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter full name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _usernameController,
                        decoration: const InputDecoration(
                          labelText: 'Username *',
                          prefixIcon: Icon(Icons.alternate_email),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter username';
                          }
                          if (value.contains(' ')) {
                            return 'Username cannot contain spaces';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: 'Email *',
                          prefixIcon: Icon(Icons.email_outlined),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter email';
                          }
                          if (!value.contains('@')) {
                            return 'Please enter valid email';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Contact Information Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.contact_phone, color: Colors.teal),
                          const SizedBox(width: 8),
                          Text(
                            'Contact Information',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.teal.shade700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          labelText: 'Phone Number *',
                          prefixIcon: Icon(Icons.phone),
                          hintText: '1-234-567-8900',
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter phone number';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _websiteController,
                        decoration: const InputDecoration(
                          labelText: 'Website',
                          prefixIcon: Icon(Icons.language),
                          hintText: 'example.com',
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Address Information Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.location_on, color: Colors.teal),
                          const SizedBox(width: 8),
                          Text(
                            'Address Information',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.teal.shade700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _streetController,
                        decoration: const InputDecoration(
                          labelText: 'Street Address *',
                          prefixIcon: Icon(Icons.home),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter street address';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: TextFormField(
                              controller: _cityController,
                              decoration: const InputDecoration(
                                labelText: 'City *',
                                prefixIcon: Icon(Icons.location_city),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Please enter city';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _zipcodeController,
                              decoration: const InputDecoration(
                                labelText: 'Zipcode *',
                                prefixIcon: Icon(Icons.local_post_office),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Please enter zipcode';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Company Information Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.business, color: Colors.teal),
                          const SizedBox(width: 8),
                          Text(
                            'Company Information',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.teal.shade700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _companyController,
                        decoration: const InputDecoration(
                          labelText: 'Company Name *',
                          prefixIcon: Icon(Icons.corporate_fare),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter company name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _catchPhraseController,
                        decoration: const InputDecoration(
                          labelText: 'Company Catchphrase',
                          prefixIcon: Icon(Icons.format_quote),
                          hintText: 'Your company motto or slogan',
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Create User Button
              SizedBox(
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _isCreating ? null : _createUser,
                  icon: _isCreating
                      ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                      : const Icon(Icons.person_add),
                  label: Text(_isCreating ? 'Creating User...' : 'Create User'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Info Card
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info, color: Colors.blue.shade700),
                        const SizedBox(width: 8),
                        Text(
                          'Note:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'The login password will be the first 4 digits of the phone number.',
                      style: TextStyle(color: Colors.blue.shade600),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
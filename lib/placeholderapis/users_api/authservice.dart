import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:io';

class AuthService {
  static const String baseUrl = 'https://jsonplaceholder.typicode.com';
  static const Duration timeoutDuration = Duration(seconds: 10);

  // Local storage for created users (will persist during app session)
  static List<Map<String, dynamic>> _localUsers = [];
  static List<Map<String, dynamic>> _modifiedUsers = [];

  // Existing login method...
  static Future<Map<String, dynamic>> login(String usernameOrEmail, String password) async {
    try {
      // First check local users
      for (var localUser in _localUsers) {
        if (localUser['username'].toLowerCase() == usernameOrEmail.toLowerCase() ||
            localUser['email'].toLowerCase() == usernameOrEmail.toLowerCase()) {
          String expectedPassword = extractPasswordFromPhone(localUser['phone']);
          if (password == expectedPassword) {
            return {
              'success': true,
              'message': 'Login successful',
              'user': localUser,
            };
          } else {
            return {
              'success': false,
              'message': 'Invalid password. Please try again.',
            };
          }
        }
      }

      // Then check API users
      final response = await http.get(
        Uri.parse('$baseUrl/users'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(timeoutDuration);

      if (response.statusCode == 200) {
        final List<dynamic> users = json.decode(response.body);

        final user = users.firstWhere(
              (user) =>
          user['username'].toLowerCase() == usernameOrEmail.toLowerCase() ||
              user['email'].toLowerCase() == usernameOrEmail.toLowerCase(),
          orElse: () => null,
        );

        if (user != null) {
          // Check if user has local modifications
          final modifiedUser = _modifiedUsers.firstWhere(
                (modUser) => modUser['id'] == user['id'],
            orElse: () => {},
          );

          final finalUser = modifiedUser.isNotEmpty ? {...user, ...modifiedUser} : user;

          String expectedPassword = extractPasswordFromPhone(finalUser['phone']);

          if (password == expectedPassword) {
            return {
              'success': true,
              'message': 'Login successful',
              'user': finalUser,
            };
          } else {
            return {
              'success': false,
              'message': 'Invalid password. Please try again.',
            };
          }
        } else {
          return {
            'success': false,
            'message': 'User not found. Please check your username or email.',
          };
        }
      } else {
        return {
          'success': false,
          'message': 'Server error: ${response.statusCode}. Please try again.',
        };
      }
    } on SocketException catch (e) {
      return {
        'success': false,
        'message': 'No internet connection. Please check your network.',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error. Please try again.',
      };
    }
  }
  // POST - Create new user
  static Future<Map<String, dynamic>> createUser({
    required String name,
    required String username,
    required String email,
    required String phone,
    required String website,
    required String street,
    required String city,
    required String zipcode,
    required String companyName,
    required String catchPhrase,
  }) async {
    try {
      final userData = {
        'name': name,
        'username': username,
        'email': email,
        'phone': phone,
        'website': website,
        'address': {
          'street': street,
          'suite': 'Apt. 1',
          'city': city,
          'zipcode': zipcode,
          'geo': {
            'lat': '-37.3159',
            'lng': '81.1496'
          }
        },
        'company': {
          'name': companyName,
          'catchPhrase': catchPhrase,
          'bs': 'harness real-time e-markets'
        }
      };

      final response = await http.post(
        Uri.parse('$baseUrl/users'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(userData),
      ).timeout(timeoutDuration);

      if (response.statusCode == 201) {
        final createdUser = json.decode(response.body);
        // Add to local storage
        _localUsers.add(createdUser);
        return {
          'success': true,
          'message': 'User created successfully!',
          'user': createdUser,
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to create user. Server error: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error creating user: ${e.toString()}',
      };
    }
  }

  // PUT - Update entire user (replace all data)
  // PUT - Update entire user (replace all data)
  static Future<Map<String, dynamic>> updateUserComplete({
    required int userId,
    required String name,
    required String username,
    required String email,
    required String phone,
    required String website,
    required String street,
    required String city,
    required String zipcode,
    required String companyName,
    required String catchPhrase,
  }) async {
    try {
      // For local users, update directly without API call
      int localIndex = _localUsers.indexWhere((user) => user['id'] == userId);
      if (localIndex != -1) {
        _localUsers[localIndex] = {
          'id': userId,
          'name': name,
          'username': username,
          'email': email,
          'phone': phone,
          'website': website,
          'address': {
            'street': street,
            'suite': 'Apt. 1',
            'city': city,
            'zipcode': zipcode,
            'geo': {'lat': '-37.3159', 'lng': '81.1496'}
          },
          'company': {
            'name': companyName,
            'catchPhrase': catchPhrase,
            'bs': 'harness real-time e-markets'
          }
        };

        return {
          'success': true,
          'message': 'User updated successfully (PUT - Local)!',
          'user': _localUsers[localIndex],
        };
      }

      // For API users (ID 1-10), create a complete user object
      final userData = {
        'id': userId,
        'name': name,
        'username': username,
        'email': email,
        'address': {
          'street': street,
          'suite': 'Apt. 1',
          'city': city,
          'zipcode': zipcode,
          'geo': {
            'lat': '-37.3159',
            'lng': '81.1496'
          }
        },
        'phone': phone,
        'website': website,
        'company': {
          'name': companyName,
          'catchPhrase': catchPhrase,
          'bs': 'harness real-time e-markets'
        }
      };

      final response = await http.put(
        Uri.parse('$baseUrl/users/$userId'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json',
        },
        body: json.encode(userData),
      ).timeout(timeoutDuration);

      print('PUT Response Status: ${response.statusCode}');
      print('PUT Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final updatedUser = json.decode(response.body);

        // Update local data completely
        _updateLocalUser(userId, {
          'name': name,
          'username': username,
          'email': email,
          'phone': phone,
          'website': website,
          'address': {
            'street': street,
            'suite': 'Apt. 1',
            'city': city,
            'zipcode': zipcode,
            'geo': {'lat': '-37.3159', 'lng': '81.1496'}
          },
          'company': {
            'name': companyName,
            'catchPhrase': catchPhrase,
            'bs': 'harness real-time e-markets'
          }
        });

        return {
          'success': true,
          'message': 'User updated successfully (PUT - API)!',
          'user': updatedUser,
        };
      } else {
        // If API fails, still update locally
        _updateLocalUser(userId, {
          'name': name,
          'username': username,
          'email': email,
          'phone': phone,
          'website': website,
          'address': {
            'street': street,
            'suite': 'Apt. 1',
            'city': city,
            'zipcode': zipcode,
            'geo': {'lat': '-37.3159', 'lng': '81.1496'}
          },
          'company': {
            'name': companyName,
            'catchPhrase': catchPhrase,
            'bs': 'harness real-time e-markets'
          }
        });

        return {
          'success': true,
          'message': 'User updated locally (API returned ${response.statusCode})!',
          'user': userData,
        };
      }
    } catch (e) {
      // If network fails, still update locally
      _updateLocalUser(userId, {
        'name': name,
        'username': username,
        'email': email,
        'phone': phone,
        'website': website,
        'address': {
          'street': street,
          'suite': 'Apt. 1',
          'city': city,
          'zipcode': zipcode,
          'geo': {'lat': '-37.3159', 'lng': '81.1496'}
        },
        'company': {
          'name': companyName,
          'catchPhrase': catchPhrase,
          'bs': 'harness real-time e-markets'
        }
      });

      return {
        'success': true,
        'message': 'User updated locally (Network error handled)!',
        'user': {
          'id': userId,
          'name': name,
          'username': username,
          'email': email,
          'phone': phone,
          'website': website,
        },
      };
    }
  }
  // PATCH - Update specific fields only
  static Future<Map<String, dynamic>> updateUserPartial({
    required int userId,
    String? name,
    String? email,
    String? phone,
    String? website,
  }) async {
    try {
      final Map<String, dynamic> updateData = {};
      if (name != null) updateData['name'] = name;
      if (email != null) updateData['email'] = email;
      if (phone != null) updateData['phone'] = phone;
      if (website != null) updateData['website'] = website;

      final response = await http.patch(
        Uri.parse('$baseUrl/users/$userId'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(updateData),
      ).timeout(timeoutDuration);

      if (response.statusCode == 200) {
        final updatedUser = json.decode(response.body);

        // Update local data
        _updateLocalUser(userId, {
          if (name != null) 'name': name,
          if (email != null) 'email': email,
          if (phone != null) 'phone': phone,
          if (website != null) 'website': website,
        });

        return {
          'success': true,
          'message': 'User updated successfully (PATCH)!',
          'user': updatedUser,
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to update user: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error updating user: ${e.toString()}',
      };
    }
  }

  // DELETE - Remove user
  static Future<Map<String, dynamic>> deleteUser(int userId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/users/$userId'),
        headers: {'Accept': 'application/json'},
      ).timeout(timeoutDuration);

      if (response.statusCode == 200) {
        // Also remove from local storage if it exists
        _localUsers.removeWhere((user) => user['id'] == userId);
        _modifiedUsers.removeWhere((user) => user['id'] == userId);

        return {
          'success': true,
          'message': 'User deleted successfully!',
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to delete user: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error deleting user: ${e.toString()}',
      };
    }
  }

  // Helper method to update local user data
  static void _updateLocalUser(int userId, Map<String, dynamic> updates) {
    // Remove old modified version if exists
    _modifiedUsers.removeWhere((user) => user['id'] == userId);

    // Check if user exists in local created users
    int localIndex = _localUsers.indexWhere((user) => user['id'] == userId);
    if (localIndex != -1) {
      // Update local user directly
      _localUsers[localIndex] = {..._localUsers[localIndex], ...updates};
    } else {
      // Create modified version for API users
      _modifiedUsers.add({'id': userId, ...updates});
    }
  }

  // Extract password from phone number
  static String extractPasswordFromPhone(String phone) {
    String digits = phone.replaceAll(RegExp(r'[^\d]'), '');
    return digits.length >= 4 ? digits.substring(0, 4) : '1234';
  }

  // Get all users (API + local users + modifications)
  static Future<List<Map<String, dynamic>>> getAllUsers() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/users'),
        headers: {'Accept': 'application/json'},
      ).timeout(timeoutDuration);

      if (response.statusCode == 200) {
        final List<dynamic> apiUsers = json.decode(response.body);
        List<Map<String, dynamic>> finalUsers = [];

        // Process each API user
        for (var apiUser in apiUsers) {
          // Check if this user has been modified locally
          final modifiedUser = _modifiedUsers.firstWhere(
                (modUser) => modUser['id'] == apiUser['id'],
            orElse: () => {},
          );

          if (modifiedUser.isNotEmpty) {
            // Merge original with modifications
            finalUsers.add({...apiUser, ...modifiedUser});
          } else {
            finalUsers.add(apiUser);
          }
        }

        // Add locally created users
        finalUsers.addAll(_localUsers);

        return finalUsers;
      }
      return [..._localUsers, ..._modifiedUsers];
    } catch (e) {
      return [..._localUsers, ..._modifiedUsers];
    }
  }

  // Test API connectivity
  static Future<bool> testConnection() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/users/1'),
        headers: {'Accept': 'application/json'},
      ).timeout(timeoutDuration);

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // Get user details by ID
  static Future<Map<String, dynamic>?> getUserById(int userId) async {
    try {
      // First check local users
      final localUser = _localUsers.firstWhere(
            (user) => user['id'] == userId,
        orElse: () => {},
      );
      if (localUser.isNotEmpty) return localUser;

      // Check modified users
      final modifiedUser = _modifiedUsers.firstWhere(
            (user) => user['id'] == userId,
        orElse: () => {},
      );

      // Get from API
      final response = await http.get(
        Uri.parse('$baseUrl/users/$userId'),
        headers: {'Accept': 'application/json'},
      ).timeout(timeoutDuration);

      if (response.statusCode == 200) {
        final apiUser = json.decode(response.body);
        // Merge with modifications if they exist
        if (modifiedUser.isNotEmpty) {
          return {...apiUser, ...modifiedUser};
        }
        return apiUser;
      }

      // Return modified user if API fails
      return modifiedUser.isNotEmpty ? modifiedUser : null;
    } catch (e) {
      return null;
    }
  }
}
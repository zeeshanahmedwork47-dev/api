import 'dart:convert';
import 'package:api_testing/Login_Api/user_model.dart';
import 'package:http/http.dart' as http;

class AuthService {
  static const String _baseUrl = 'https://dummyjson.com';

  // In-memory storage (will reset when app restarts)
  static String? _cachedToken;
  static User? _cachedUser;

  // Login method
  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'password': password,
          'expiresInMins': 30, // Optional, defaults to 60
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final user = User.fromJson(data);

        // Save user data and token to memory
        _cachedToken = user.token;
        _cachedUser = user;

        return {
          'success': true,
          'user': user,
          'message': 'Login successful'
        };
      } else {
        final errorData = jsonDecode(response.body);
        return {
          'success': false,
          'message': errorData['message'] ?? 'Login failed'
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}'
      };
    }
  }

  // Get current user method
  Future<Map<String, dynamic>> getCurrentUser() async {
    try {
      final token = getToken();
      if (token == null) {
        return {'success': false, 'message': 'No token found'};
      }

      final response = await http.get(
        Uri.parse('$_baseUrl/auth/me'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final user = User.fromJson(data);
        _cachedUser = user;
        return {
          'success': true,
          'user': user,
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to get user data'
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}'
      };
    }
  }

  // Refresh token method
  Future<Map<String, dynamic>> refreshToken() async {
    try {
      if (_cachedUser == null) {
        return {'success': false, 'message': 'No user data found'};
      }

      final response = await http.post(
        Uri.parse('$_baseUrl/auth/refresh'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'refreshToken': _cachedUser!.refreshToken,
          'expiresInMins': 30,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final updatedUser = User.fromJson(data);
        _cachedToken = updatedUser.token;
        _cachedUser = updatedUser;

        return {
          'success': true,
          'user': updatedUser,
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to refresh token'
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}'
      };
    }
  }

  // Get stored token
  String? getToken() {
    return _cachedToken;
  }

  // Get stored user data
  User? getStoredUser() {
    return _cachedUser;
  }

  // Check if user is logged in
  bool isLoggedIn() {
    return _cachedToken != null;
  }

  // Logout method
  void logout() {
    _cachedToken = null;
    _cachedUser = null;
  }
}
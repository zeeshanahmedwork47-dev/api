import 'package:api_testing/Login_Api/user_model.dart';
import 'package:flutter/material.dart';
import 'login_services.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();

  User? _user;
  bool _isLoading = false;
  bool _isLoggedIn = false;
  String _errorMessage = '';

  // Getters
  User? get user => _user;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _isLoggedIn;
  String get errorMessage => _errorMessage;

  // Initialize auth state
  Future<void> init() async {
    _isLoading = true;
    notifyListeners();

    _isLoggedIn = await _authService.isLoggedIn();
    if (_isLoggedIn) {
      _user = await _authService.getStoredUser();
    }

    _isLoading = false;
    notifyListeners();
  }

  // Login method
  Future<bool> login(String username, String password) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    final result = await _authService.login(username, password);

    if (result['success']) {
      _user = result['user'];
      _isLoggedIn = true;
      _isLoading = false;
      notifyListeners();
      return true;
    } else {
      _errorMessage = result['message'];
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Logout method
  Future<void> logout() async {
    _authService.logout();
    _user = null;
    _isLoggedIn = false;
    _errorMessage = '';
    notifyListeners();
  }

  // Refresh token method
  Future<bool> refreshToken() async {
    final result = await _authService.refreshToken();

    if (result['success']) {
      _user = result['user'];
      notifyListeners();
      return true;
    }
    return false;
  }

  // Clear error message
  void clearError() {
    _errorMessage = '';
    notifyListeners();
  }
}
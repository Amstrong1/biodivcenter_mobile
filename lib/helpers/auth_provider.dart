import 'package:flutter/material.dart';
import 'auth_service.dart';

class AuthProvider with ChangeNotifier {
  bool _isAuthenticated = false;
  final AuthService _authService = AuthService();

  bool get isAuthenticated => _isAuthenticated;

  Future<void> login(String email, String password) async {
    bool success = await _authService.login(email, password);
    if (success) {
      _isAuthenticated = true;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    _isAuthenticated = false;
    notifyListeners();
  }

  Future<void> checkAuthStatus() async {
    final userData = await _authService.getUserData();
    if (userData != null) {
      _isAuthenticated = true;
    } else {
      _isAuthenticated = false;
    }
    notifyListeners();
  }
}

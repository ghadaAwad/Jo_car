import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthController with ChangeNotifier {
  final AuthService _authService = AuthService();
  UserModel? _user;

  UserModel? get user => _user;
  bool get isLoggedIn => _user != null;

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'Email is required';
    if (!value.contains('@')) return 'Invalid email format';
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < 6) return 'Password must be at least 6 characters';
    return null;
  }

  String? validateField(String? value, String fieldName) {
    if (value == null || value.isEmpty) return '$fieldName is required';
    return null;
  }

  bool login(String email, String password) {
    final success = _authService.login(email, password);
    if (success) {
      _user = _authService.currentUser;
      notifyListeners();
    }
    return success;
  }

  bool register(UserModel user) {
    final success = _authService.register(user);
    if (success) {
      _user = user;
      notifyListeners();
    }
    return success;
  }

  void logout() {
    _authService.logout();
    _user = null;
    notifyListeners();
  }
}

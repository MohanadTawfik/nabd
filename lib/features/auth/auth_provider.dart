import 'package:flutter/material.dart';
import 'package:nabd/services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  AuthStatus get status => _authService.status;
  bool get isAuthenticated => _authService.isAuthenticated;
  get currentUser => _authService.currentUser;

  Future<void> initialize() async {
    await _authService.initialize();
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    final result = await _authService.login(email, password);
    notifyListeners();
    return result;
  }

  Future<bool> register(String name, String email, String password) async {
    final result = await _authService.register(name, email, password);
    notifyListeners();
    return result;
  }

  Future<void> logout() async {
    await _authService.logout();
    notifyListeners();
  }

  Future<bool> updateProfile(String name, String? photoUrl) async {
    final result = await _authService.updateProfile(name, photoUrl);
    notifyListeners();
    return result;
  }

  Future<bool> changePassword(String currentPassword, String newPassword) async {
    final result = await _authService.changePassword(currentPassword, newPassword);
    notifyListeners();
    return result;
  }

  // TODO: Connect API for real authentication
}

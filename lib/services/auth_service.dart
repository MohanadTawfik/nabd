import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:nabd/models/user_model.dart';
import 'package:nabd/services/api_service.dart';
import 'package:nabd/services/service_locator.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AuthStatus { initial, authenticated, unauthenticated }

class AuthService with ChangeNotifier {
  // Singleton pattern
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  // Services
  ApiService? _apiService;

  // State
  AuthStatus _status = AuthStatus.initial;
  User? _currentUser;
  String? _token;

  // Getters
  AuthStatus get status => _status;
  User? get currentUser => _currentUser;
  bool get isAuthenticated => _status == AuthStatus.authenticated;

  // Initialize auth state from storage
  Future<void> initialize() async {
    // Always set API service instance
    _apiService = serviceLocator.apiService;

    try {
      // Handle potential platform channel errors when getting SharedPreferences instance
      SharedPreferences? prefs;
      try {
        prefs = await SharedPreferences.getInstance();
      } catch (e) {
        debugPrint('Failed to get SharedPreferences instance: $e');
        prefs = null;
      }

      if (prefs == null) {
        _status = AuthStatus.unauthenticated;
        return;
      }
      final userJson = prefs.getString('user');
      final token = prefs.getString('token');

      if (userJson != null && token != null) {
        _currentUser = User.fromMap(json.decode(userJson));
        _token = token;
        _apiService?.setAuthToken(token);
        _status = AuthStatus.authenticated;
      } else {
        _status = AuthStatus.unauthenticated;
      }
    } catch (e) {
      _status = AuthStatus.unauthenticated;
    }

    notifyListeners();
  }

  // Register a new user
  Future<bool> register(String name, String email, String password) async {
    try {
      if (_apiService == null) return false;
      final response = await _apiService!.register(name, email, password);

      if (response.success) {
        // Auto-login after registration
        return await login(email, password);
      }
      return false;
    } catch (e) {
      debugPrint('Registration error: [${e.toString()}');
      return false;
    }
  }

  // Login user
  Future<bool> login(String email, String password) async {
    try {
      if (_apiService == null) return false;
      final response = await _apiService!.login(email, password);

      if (response.success && response.data != null) {
        final userData = response.data!['user'];
        final token = response.data!['token'];

        _currentUser = userData != null
            ? User.fromMap(userData as Map<String, dynamic>)
            : null;
        _token = token;
        if (token != null) _apiService!.setAuthToken(token);
        _status = AuthStatus.authenticated;

        // Save to local storage
        final prefs = await SharedPreferences.getInstance();
        if (userData != null)
          await prefs.setString('user', json.encode(userData));
        if (token != null) await prefs.setString('token', token);

        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Login error: ${e.toString()}');
      return false;
    }
  }

  // Logout user
  Future<void> logout() async {
    _currentUser = null;
    _token = null;
    _status = AuthStatus.unauthenticated;
    if (_apiService != null) {
      _apiService!.setAuthToken('');
    }

    // Clear from local storage
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user');
    await prefs.remove('token');

    notifyListeners();
  }

  // Update user profile
  Future<bool> updateProfile(String name, String? photoUrl) async {
    try {
      if (_currentUser == null || _apiService == null) return false;

      // Use a more specific API endpoint method if available, or use the generic post method
      final response = await _apiService!.post('/user/update', {
        'name': name,
        'photoUrl': photoUrl,
      });

      if (response.success) {
        final updatedUser = _currentUser!.copyWith(
          name: name,
          photoUrl: photoUrl,
        );

        _currentUser = updatedUser;

        // Update in local storage
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user', json.encode(updatedUser.toMap()));

        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Update profile error: ${e.toString()}');
      return false;
    }
  }

  // Change user password
  Future<bool> changePassword(
      String currentPassword, String newPassword) async {
    try {
      if (_apiService == null) return false;
      final response =
          await _apiService!.changePassword(currentPassword, newPassword);

      return response.success;
    } catch (e) {
      debugPrint('Change password error: ${e.toString()}');
      return false;
    }
  }
}

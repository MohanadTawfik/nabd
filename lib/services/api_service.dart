import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:nabd/models/api_response.dart';

/// Service for handling API requests to the backend
class ApiService {
  // TODO: Replace with actual API base URL
  static const String _baseUrl = 'https://api.example.com';
  
  // Singleton pattern
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  // TODO: Replace with actual API key or token handling
  String? _authToken;
  
  /// Sets the authentication token for API requests
  void setAuthToken(String token) {
    _authToken = token;
  }

  /// Creates headers for API requests
  Map<String, String> _getHeaders() {
    final headers = {
      'Content-Type': 'application/json',
    };
    
    if (_authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
    }
    
    return headers;
  }

  /// Generic GET request
  Future<ApiResponse<Map<String, dynamic>>> get(String endpoint) async {
    if (kDebugMode) {
      print('GET request to: $_baseUrl$endpoint');
    }
    
    try {
      // For development/testing, simulate network delay
      if (kDebugMode) {
        await Future.delayed(const Duration(milliseconds: 800));
        // Return mock data during development
        return ApiResponse.success({'mockData': true});
      }
      
      // Real implementation for production
      final response = await http.get(
        Uri.parse('$_baseUrl$endpoint'),
        headers: _getHeaders(),
      ).timeout(const Duration(seconds: 15));
      
      return _processResponse(response);
    } on SocketException {
      return ApiResponse.error('No Internet connection');
    } on TimeoutException {
      return ApiResponse.error('Request timeout');
    } catch (e) {
      return ApiResponse.error('An unexpected error occurred: ${e.toString()}');
    }
  }

  /// Generic POST request
  Future<ApiResponse<Map<String, dynamic>>> post(String endpoint, Map<String, dynamic> data) async {
    if (kDebugMode) {
      print('POST request to: $_baseUrl$endpoint');
      print('Data: ${jsonEncode(data)}');
    }
    
    try {
      // For development/testing, simulate network delay
      if (kDebugMode) {
        await Future.delayed(const Duration(milliseconds: 1000));
        // Return mock data during development
        return ApiResponse.success({'mockData': true});
      }
      
      // Real implementation for production
      final response = await http.post(
        Uri.parse('$_baseUrl$endpoint'),
        headers: _getHeaders(),
        body: jsonEncode(data),
      ).timeout(const Duration(seconds: 15));
      
      return _processResponse(response);
    } on SocketException {
      return ApiResponse.error('No Internet connection');
    } on TimeoutException {
      return ApiResponse.error('Request timeout');
    } catch (e) {
      return ApiResponse.error('An unexpected error occurred: ${e.toString()}');
    }
  }

  /// Generic PUT request
  Future<ApiResponse<Map<String, dynamic>>> put(String endpoint, Map<String, dynamic> data) async {
    if (kDebugMode) {
      print('PUT request to: $_baseUrl$endpoint');
      print('Data: ${jsonEncode(data)}');
    }
    
    try {
      // For development/testing, simulate network delay
      if (kDebugMode) {
        await Future.delayed(const Duration(milliseconds: 1000));
        // Return mock data during development
        return ApiResponse.success({'mockData': true});
      }
      
      // Real implementation for production
      final response = await http.put(
        Uri.parse('$_baseUrl$endpoint'),
        headers: _getHeaders(),
        body: jsonEncode(data),
      ).timeout(const Duration(seconds: 15));
      
      return _processResponse(response);
    } on SocketException {
      return ApiResponse.error('No Internet connection');
    } on TimeoutException {
      return ApiResponse.error('Request timeout');
    } catch (e) {
      return ApiResponse.error('An unexpected error occurred: ${e.toString()}');
    }
  }

  /// Generic DELETE request
  Future<ApiResponse<Map<String, dynamic>>> delete(String endpoint) async {
    if (kDebugMode) {
      print('DELETE request to: $_baseUrl$endpoint');
    }
    
    try {
      // For development/testing, simulate network delay
      if (kDebugMode) {
        await Future.delayed(const Duration(milliseconds: 800));
        // Return mock data during development
        return ApiResponse.success({'deleted': true});
      }
      
      // Real implementation for production
      final response = await http.delete(
        Uri.parse('$_baseUrl$endpoint'),
        headers: _getHeaders(),
      ).timeout(const Duration(seconds: 15));
      
      return _processResponse(response);
    } on SocketException {
      return ApiResponse.error('No Internet connection');
    } on TimeoutException {
      return ApiResponse.error('Request timeout');
    } catch (e) {
      return ApiResponse.error('An unexpected error occurred: ${e.toString()}');
    }
  }

  /// Process HTTP response and convert to ApiResponse
  ApiResponse<Map<String, dynamic>> _processResponse(http.Response response) {
    try {
      final responseData = json.decode(response.body) as Map<String, dynamic>;
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return ApiResponse.success(
          responseData['data'] ?? {},
          message: responseData['message'],
          statusCode: response.statusCode,
        );
      } else {
        return ApiResponse.error(
          responseData['error'] ?? 'Unknown error occurred',
          statusCode: response.statusCode,
          message: responseData['message'],
        );
      }
    } catch (e) {
      return ApiResponse.error(
        'Failed to process response: ${e.toString()}',
        statusCode: response.statusCode,
      );
    }
  }
  
  // ===== Specific API endpoints =====

  /// Get user profile
  Future<ApiResponse<Map<String, dynamic>>> getUserProfile() async {
    return get('/user/profile');
  }
  
  /// Register a new user
  Future<ApiResponse<Map<String, dynamic>>> register(String name, String email, String password) async {
    return post('/auth/register', {
      'name': name,
      'email': email,
      'password': password,
    });
  }
  
  /// Login a user
  Future<ApiResponse<Map<String, dynamic>>> login(String email, String password) async {
    return post('/auth/login', {
      'email': email,
      'password': password,
    });
  }
  
  /// Change user password
  Future<ApiResponse<Map<String, dynamic>>> changePassword(String currentPassword, String newPassword) async {
    return post('/auth/change-password', {
      'currentPassword': currentPassword,
      'newPassword': newPassword,
    });
  }

  /// Get transactions
  Future<ApiResponse<Map<String, dynamic>>> getTransactions() async {
    return get('/transactions');
  }

  /// Add transaction
  Future<ApiResponse<Map<String, dynamic>>> addTransaction(Map<String, dynamic> transaction) async {
    return post('/transactions', transaction);
  }

  /// Update transaction
  Future<ApiResponse<Map<String, dynamic>>> updateTransaction(String id, Map<String, dynamic> transaction) async {
    return put('/transactions/$id', transaction);
  }

  /// Delete transaction
  Future<ApiResponse<Map<String, dynamic>>> deleteTransaction(String id) async {
    return delete('/transactions/$id');
  }

  /// Get categories
  Future<ApiResponse<Map<String, dynamic>>> getCategories() async {
    return get('/categories');
  }

  /// Get budgets
  Future<ApiResponse<Map<String, dynamic>>> getBudgets() async {
    return get('/budgets');
  }

  /// Add budget
  Future<ApiResponse<Map<String, dynamic>>> addBudget(Map<String, dynamic> budget) async {
    return post('/budgets', budget);
  }

  /// Update budget
  Future<ApiResponse<Map<String, dynamic>>> updateBudget(String id, Map<String, dynamic> budget) async {
    return put('/budgets/$id', budget);
  }

  /// Delete budget
  Future<ApiResponse<Map<String, dynamic>>> deleteBudget(String id) async {
    return delete('/budgets/$id');
  }

  /// Get goals
  Future<ApiResponse<Map<String, dynamic>>> getGoals() async {
    return get('/goals');
  }

  /// Add goal
  Future<ApiResponse<Map<String, dynamic>>> addGoal(Map<String, dynamic> goal) async {
    return post('/goals', goal);
  }

  /// Update goal
  Future<ApiResponse<Map<String, dynamic>>> updateGoal(String id, Map<String, dynamic> goal) async {
    return put('/goals/$id', goal);
  }

  /// Delete goal
  Future<ApiResponse<Map<String, dynamic>>> deleteGoal(String id) async {
    return delete('/goals/$id');
  }
}
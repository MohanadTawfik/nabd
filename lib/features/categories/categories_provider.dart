import 'dart:async';

import 'package:flutter/material.dart';
import 'package:nabd/features/categories/models/category_model.dart';
import 'package:nabd/features/transactions/models/transaction_model.dart';
import 'package:nabd/services/database_service.dart';

class CategoriesProvider extends ChangeNotifier {
  final List<Category> _categories = [];
  bool _isLoading = false;
  String? _error;

  // Cache for filtered categories
  final Map<TransactionType, List<Category>> _cachedFilteredCategories = {};

  /// Returns an unmodifiable list of all categories
  List<Category> get categories => List.unmodifiable(_categories);

  /// Returns categories filtered by type (expense/income)
  List<Category> getCategoriesByType(TransactionType type) {
    // Return cached result if available
    if (_cachedFilteredCategories.containsKey(type)) {
      return _cachedFilteredCategories[type]!;
    }

    final filtered = _categories.where((c) => c.type == type).toList();
    _cachedFilteredCategories[type] = filtered;
    return filtered;
  }

  /// Returns a category by its ID, or null if not found
  Category? getCategoryById(String id) {
    try {
      return _categories.firstWhere((category) => category.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Returns the total number of categories
  int get categoryCount => _categories.length;

  /// Loading state
  bool get isLoading => _isLoading;

  /// Error message, if any
  String? get error => _error;

  final DatabaseService _dbService;
  bool _isInitialized = false;

  CategoriesProvider() : _dbService = DatabaseService() {
    // Initialize data when the provider is created
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      await loadCategories();
      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      _setError('Failed to initialize categories: ${e.toString()}');
    }
  }

  // Method to check if the provider is initialized
  bool get isInitialized => _isInitialized;

  /// Loads all categories from the database
  Future<void> loadCategories() async {
    if (_isLoading) return;

    _setLoading(true);
    _cachedFilteredCategories.clear(); // Clear cache on reload

    try {
      final dbCategories = await _dbService.getCategories();
      _categories
        ..clear()
        ..addAll(dbCategories);
      _setError(null);
    } catch (e) {
      _setError('Failed to load categories: ${e.toString()}');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  /// Adds a new category
  Future<void> addCategory(Category category) async {
    try {
      await _dbService.insertCategory(category);
      await loadCategories();
    } catch (e) {
      _setError('Failed to add category: ${e.toString()}');
      rethrow;
    }
  }

  /// Updates an existing category
  Future<void> updateCategory(Category category) async {
    try {
      await _dbService.updateCategory(category);
      _cachedFilteredCategories.clear(); // Clear cache on update
      await loadCategories();
    } catch (e) {
      _setError('Failed to update category: ${e.toString()}');
      rethrow;
    }
  }

  /// Deletes a category by ID
  /// Returns true if successful, false otherwise
  Future<bool> deleteCategory(String categoryId) async {
    try {
      await _dbService.deleteCategory(categoryId);
      _cachedFilteredCategories.clear(); // Clear cache on delete
      await loadCategories();
      return true;
    } catch (e) {
      _setError('Failed to delete category: ${e.toString()}');
      return false;
    }
  }

  /// Deletes a category by Category object
  /// Returns true if successful, false otherwise
  Future<bool> deleteCategoryObject(Category category) async {
    return deleteCategory(category.id);
  }

  /// Clear any error message
  void clearError() {
    _setError(null);
  }

  /// Clear the categories list (useful for logout)
  void clear() {
    _categories.clear();
    _cachedFilteredCategories.clear();
    _setError(null);
    notifyListeners();
  }

  // Private methods
  void _setLoading(bool loading) {
    if (_isLoading != loading) {
      _isLoading = loading;
      notifyListeners();
    }
  }

  void _setError(String? error) {
    if (_error != error) {
      _error = error;
      notifyListeners();
    }
  }
}

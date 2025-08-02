import 'package:flutter/material.dart';
import 'package:nabd/features/budgets/models/budget_model.dart';
import 'package:nabd/services/database_service.dart';
import 'package:nabd/features/categories/models/category_model.dart';

class BudgetsProvider extends ChangeNotifier {
  final DatabaseService _dbService;
  List<Budget> _budgets = [];
  List<Category> _categories = [];
  bool _isLoading = false;
  String? _error;
  bool _isInitialized = false;

  BudgetsProvider() : _dbService = DatabaseService() {
    _initialize();
  }

  // Public getters
  List<Budget> get budgets => List.unmodifiable(_budgets);
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isInitialized => _isInitialized;

  Future<void> _initialize() async {
    try {
      await loadBudgets();
      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      _setError('Failed to initialize budgets: $e');
    }
  }

  Future<void> loadBudgets() async {
    if (_isLoading) return;
    _setLoading(true);
    try {
      final rawBudgets = await _dbService.getBudgets();
      _budgets = rawBudgets.map((b) {
        if (b.categoryId == null) {
          return b.copyWith(category: null);
        }
        
        // Find the category, or use null if not found
        final category = _categories.cast<Category?>().firstWhere(
          (c) => c?.id == b.categoryId,
          orElse: () => null,
        );
        
        return b.copyWith(category: category);
      }).toList();
      _setError(null);
    } catch (e) {
      _setError('Failed to load budgets: $e');
      rethrow; // Re-throw to allow callers to handle the error if needed
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> addBudget(Budget budget) async {
    try {
      await _dbService.insertBudget(budget);
      await loadBudgets();
      return true;
    } catch (e) {
      _setError('Failed to add budget: $e');
      return false;
    }
  }

  Future<bool> updateBudget(Budget budget) async {
    try {
      await _dbService.updateBudget(budget);
      await loadBudgets();
      return true;
    } catch (e) {
      _setError('Failed to update budget: $e');
      return false;
    }
  }

  Future<bool> deleteBudget(String id) async {
    try {
      await _dbService.deleteBudget(id);
      await loadBudgets();
      return true;
    } catch (e) {
      _setError('Failed to delete budget: $e');
      return false;
    }
  }

  void clear() {
    _budgets.clear();
    _setError(null);
    notifyListeners();
  }

  void _setLoading(bool loading) {
    if (_isLoading != loading) {
      _isLoading = loading;
      // Schedule the notification for the next frame
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    }
  }

  void _setError(String? error) {
    if (_error != error) {
      _error = error;
      // Schedule the notification for the next frame
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    }
  }
}

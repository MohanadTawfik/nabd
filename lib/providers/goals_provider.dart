import 'package:flutter/material.dart';
import 'package:nabd/features/goals/models/goal_model.dart';
import 'package:nabd/services/database_service.dart';

class GoalsProvider extends ChangeNotifier {
  final DatabaseService _dbService = DatabaseService();

  List<Goal> _goals = [];
  bool _isLoading = false;
  String? _error;

  List<Goal> get goals => List.unmodifiable(_goals);
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Initialize provider: load goals from database
  Future<void> initialize() async {
    _setLoading(true);
    try {
      await _loadGoals();
      _setLoading(false);
    } catch (e) {
      _setError('Failed to initialize goals: $e');
    }
  }

  /// Refresh goals from database
  Future<void> refresh() async {
    await _loadGoals();
  }

  /// Load goals from database
  Future<void> _loadGoals() async {
    try {
      _goals = await _dbService.getGoals();
      notifyListeners();
    } catch (e) {
      _setError('Failed to load goals: $e');
    }
  }

  /// Add a new goal
  Future<bool> addGoal(Goal goal) async {
    _setLoading(true);
    try {
      await _dbService.insertGoal(goal);
      await _loadGoals();
      _setLoading(false);
      return true;
    } catch (e) {
      _setError('Failed to add goal: $e');
      return false;
    }
  }

  /// Update an existing goal
  Future<bool> updateGoal(Goal goal) async {
    _setLoading(true);
    try {
      await _dbService.updateGoal(goal);
      await _loadGoals();
      _setLoading(false);
      return true;
    } catch (e) {
      _setError('Failed to update goal: $e');
      return false;
    }
  }

  /// Delete a goal by ID
  Future<bool> deleteGoal(String id) async {
    _setLoading(true);
    try {
      await _dbService.deleteGoal(id);
      await _loadGoals();
      _setLoading(false);
      return true;
    } catch (e) {
      _setError('Failed to delete goal: $e');
      return false;
    }
  }

  /// Set loading state and notify listeners
  void _setLoading(bool loading) {
    _isLoading = loading;
    if (loading) _error = null;
    notifyListeners();
  }

  /// Set error state and notify listeners
  void _setError(String error) {
    _error = error;
    _isLoading = false;
    notifyListeners();
  }
}

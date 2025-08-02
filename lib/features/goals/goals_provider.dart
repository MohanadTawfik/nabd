import 'package:flutter/material.dart';
import 'package:nabd/features/goals/models/goal_model.dart';
import 'package:nabd/services/database_service.dart';

class GoalsProvider extends ChangeNotifier {
  final DatabaseService _dbService;
  List<Goal> _goals = [];
  bool _isLoading = false;
  String? _error;
  bool _isInitialized = false;

  GoalsProvider() : _dbService = DatabaseService() {
    _initialize();
  }

  List<Goal> get goals => List.unmodifiable(_goals);
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isInitialized => _isInitialized;

  Future<void> _initialize() async {
    try {
      await loadGoals();
      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      _setError('Failed to initialize goals: $e');
    }
  }

  Future<void> loadGoals() async {
    if (_isLoading) return;
    _setLoading(true);
    try {
      _goals = await _dbService.getGoals();
      _setError(null);
    } catch (e) {
      _setError('Failed to load goals: $e');
    } finally {
      _setLoading(false);
    }
    notifyListeners();
  }

  Future<bool> addGoal(Goal goal) async {
    try {
      await _dbService.insertGoal(goal);
      await loadGoals();
      return true;
    } catch (e) {
      _setError('Failed to add goal: $e');
      return false;
    }
  }

  Future<bool> updateGoal(Goal goal) async {
    try {
      await _dbService.updateGoal(goal);
      await loadGoals();
      return true;
    } catch (e) {
      _setError('Failed to update goal: $e');
      return false;
    }
  }

  Future<bool> deleteGoal(String id) async {
    try {
      await _dbService.deleteGoal(id);
      await loadGoals();
      return true;
    } catch (e) {
      _setError('Failed to delete goal: $e');
      return false;
    }
  }

  void clear() {
    _goals.clear();
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

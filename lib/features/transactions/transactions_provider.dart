import 'package:flutter/material.dart';
import 'package:nabd/services/database_service.dart';
import 'package:nabd/features/transactions/models/transaction_model.dart';
import 'package:nabd/features/categories/models/category_model.dart';
import 'package:nabd/models/api_response.dart';

class TransactionsProvider extends ChangeNotifier {
  final DatabaseService _dbService;
  List<Transaction> _transactions = [];
  List<Category> _categories = [];
  bool _isLoading = false;
  String? _error;
  bool _isInitialized = false;

  TransactionsProvider() : _dbService = DatabaseService() {
    _initialize();
  }

  List<Transaction> get transactions => List.unmodifiable(_transactions);
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isInitialized => _isInitialized;

  Future<void> _initialize() async {
    try {
      await loadTransactions();
      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      _setError('Failed to initialize transactions: $e');
    }
  }

  Future<void> loadTransactions() async {
    if (_isLoading) return;
    _setLoading(true);
    try {
      final txnMaps = await _dbService.getTransactions();
      _transactions = txnMaps.map((txn) {
        final cat = _categories.firstWhere(
          (c) => c.id == txn.category.id,
          orElse: () => txn.category,
        );
        return Transaction(
          id: txn.id,
          category: cat,
          amount: txn.amount,
          type: txn.type,
          date: txn.date,
          notes: txn.notes,
          source: txn.source,
        );
      }).toList();
      _setError(null);
    } catch (e) {
      _setError('Failed to load transactions: $e');
    } finally {
      _setLoading(false);
    }
    notifyListeners();
  }

  Future<bool> addTransaction(Transaction transaction) async {
    try {
      await _dbService.insertTransaction(transaction);
      await loadTransactions();
      return true;
    } catch (e) {
      _setError('Failed to add transaction: $e');
      return false;
    }
  }

  Future<bool> updateTransaction(Transaction transaction) async {
    try {
      await _dbService.updateTransaction(transaction);
      await loadTransactions();
      return true;
    } catch (e) {
      _setError('Failed to update transaction: $e');
      return false;
    }
  }

  Future<bool> deleteTransaction(String id) async {
    try {
      await _dbService.deleteTransaction(id);
      await loadTransactions();
      return true;
    } catch (e) {
      _setError('Failed to delete transaction: $e');
      return false;
    }
  }

  void clear() {
    _transactions.clear();
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

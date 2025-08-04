import 'package:flutter/material.dart';
import 'package:nabd/features/categories/categories_provider.dart';
import 'package:nabd/services/database_service.dart';
import 'package:nabd/features/transactions/models/transaction_model.dart';
import 'package:nabd/features/categories/models/category_model.dart';
import 'package:provider/provider.dart';

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

  Future<void> loadTransactions({BuildContext? context, CategoriesProvider? categoriesProvider}) async {
    if (_isLoading) return;
    _setLoading(true);
    try {
      final txnMaps = await _dbService.getTransactions();

      // If categoriesProvider wasn't passed, try to get it from context
      categoriesProvider ??= context != null 
          ? Provider.of<CategoriesProvider>(
              context,
              listen: false,
            )
          : null;

      if (categoriesProvider == null) {
        debugPrint('Warning: No CategoriesProvider available when loading transactions');
      }

      _transactions = txnMaps.map((txn) {
        return Transaction.fromMap(
          txn.toMap(),
          categoriesProvider: categoriesProvider,
        );
      }).toList();

      _setError(null);
    } catch (e) {
      _setError('Failed to load transactions: $e');
      rethrow;
    } finally {
      _setLoading(false);
      notifyListeners();
    }
  }

  Future<bool> addTransaction(Transaction transaction, {BuildContext? context, CategoriesProvider? categoriesProvider}) async {
    try {
      await _dbService.insertTransaction(transaction);
      await loadTransactions(
        context: context,
        categoriesProvider: categoriesProvider,
      );
      return true;
    } catch (e) {
      _setError('Failed to add transaction: $e');
      return false;
    }
  }

  Future<bool> updateTransaction(Transaction transaction, {BuildContext? context, CategoriesProvider? categoriesProvider}) async {
    try {
      await _dbService.updateTransaction(transaction);
      await loadTransactions(
        context: context,
        categoriesProvider: categoriesProvider,
      );
      return true;
    } catch (e) {
      _setError('Failed to update transaction: $e');
      return false;
    }
  }

  Future<bool> deleteTransaction(String id, {BuildContext? context, CategoriesProvider? categoriesProvider}) async {
    try {
      await _dbService.deleteTransaction(id);
      await loadTransactions(
        context: context,
        categoriesProvider: categoriesProvider,
      );
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

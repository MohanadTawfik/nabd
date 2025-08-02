import 'package:flutter/material.dart';
import 'package:nabd/features/reports/models/report_model.dart';
import 'package:nabd/services/database_service.dart';
import 'package:nabd/features/transactions/models/transaction_model.dart';
import 'package:nabd/features/budgets/models/budget_model.dart';
import 'package:nabd/features/goals/models/goal_model.dart';

class ReportsProvider extends ChangeNotifier {
  final DatabaseService _dbService;
  List<Report> _reports = [];
  bool _isLoading = false;
  String? _error;
  bool _isInitialized = false;

  ReportsProvider() : _dbService = DatabaseService() {
    _initialize();
  }

  List<Report> get reports => List.unmodifiable(_reports);
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isInitialized => _isInitialized;

  Future<void> _initialize() async {
    try {
      await loadReports();
      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      _setError('فشل في تهيئة التقارير: $e');
    }
  }

  Future<void> loadReports() async {
    if (_isLoading) return;
    _setLoading(true);
    try {
      final now = DateTime.now();
      final monthly = await getMonthlyReport(DateTime(now.year, now.month));
      final categoryReports = await getCategoryReports();
      _reports = [if (monthly != null) monthly, ...categoryReports];
      _setError(null);
    } catch (e) {
      _setError('فشل في توليد التقارير: $e');
    } finally {
      _setLoading(false);
    }
    notifyListeners();
  }

  Future<Report?> getMonthlyReport(DateTime month) async {
    try {
      final txns = await _dbService.getTransactions();
      final start = DateTime(month.year, month.month, 1);
      final end = DateTime(month.year, month.month + 1, 0);
      final filtered = txns
          .where((t) =>
              t.date.isAfter(start.subtract(const Duration(days: 1))) &&
              t.date.isBefore(end.add(const Duration(days: 1))))
          .toList();
      final total = filtered.fold<double>(
          0,
          (sum, t) =>
              sum + t.amount * (t.type == TransactionType.expense ? -1 : 1));
      return Report(
        id: 'monthly-${month.year}-${month.month}',
        title: 'تقرير الشهر (${month.year}/${month.month})',
        date: start,
        category: 'all',
        content: 'إجمالي الدخل/المصروف: ${total.toStringAsFixed(2)}',
      );
    } catch (e) {
      _setError('فشل في الحصول على تقرير الشهر: $e');
      return null;
    }
  }

  Future<List<Report>> getCategoryReports() async {
    try {
      final txns = await _dbService.getTransactions();
      final Map<String, double> categoryTotals = {};
      for (final t in txns) {
        final key = t.category.name;
        categoryTotals[key] = (categoryTotals[key] ?? 0) +
            (t.type == TransactionType.expense ? -t.amount : t.amount);
      }
      return categoryTotals.entries
          .map((e) => Report(
                id: 'cat-${e.key}',
                title: 'تقرير الفئة: ${e.key}',
                date: DateTime.now(),
                category: e.key,
                content: 'إجمالي: ${e.value.toStringAsFixed(2)}',
              ))
          .toList();
    } catch (e) {
      _setError('فشل في الحصول على تقارير الفئات: $e');
      return [];
    }
  }

  void clear() {
    _reports.clear();
    _setError(null);
    notifyListeners();
  }

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

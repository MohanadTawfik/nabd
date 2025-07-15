import 'package:flutter/material.dart';
import 'package:nabd/features/budgets/models/budget_model.dart';
import 'package:nabd/features/goals/models/goal_model.dart';
import 'package:nabd/features/transactions/models/transaction_model.dart';

class AppData extends ChangeNotifier {
  // 1. إضافة متغير جديد لحفظ حالة المظهر
  ThemeMode _themeMode = ThemeMode.dark;
  ThemeMode get themeMode => _themeMode;

  // 2. دالة لتغيير المظهر وإخبار المستمعين
  void changeTheme(ThemeMode themeMode) {
    _themeMode = themeMode;
    notifyListeners();
  }

  final List<Transaction> _transactions = [
    Transaction(
        id: 't1',
        category: 'راتب',
        icon: Icons.wallet,
        amount: 400000,
        type: TransactionType.income,
        date: DateTime.now().subtract(const Duration(days: 5))),
    Transaction(
        id: 't2',
        category: 'طعام',
        icon: Icons.fastfood,
        amount: 15000,
        type: TransactionType.expense,
        date: DateTime.now().subtract(const Duration(days: 2))),
    Transaction(
        id: 't3',
        category: 'مواصلات',
        icon: Icons.directions_bus,
        amount: 5000,
        type: TransactionType.expense,
        date: DateTime.now().subtract(const Duration(days: 1))),
  ];
  
  final List<Goal> _goals = [
    Goal(
        name: 'سيارة أحلامي',
        icon: Icons.directions_car,
        savedAmount: 750000.0,
        totalAmount: 1000000.0,
        color: Colors.blue.shade300),
  ];

  final List<Budget> _budgets = [
    Budget(categoryName: 'طعام', icon: Icons.fastfood, totalAmount: 50000),
    Budget(categoryName: 'تسوق', icon: Icons.shopping_bag, totalAmount: 40000),
  ];

  List<Transaction> get transactions => _transactions;
  List<Goal> get goals => _goals;
  List<Budget> get budgets => _budgets;
  double get totalIncome => _transactions
      .where((t) => t.type == TransactionType.income)
      .fold(0.0, (sum, item) => sum + item.amount);
  double get totalExpense => _transactions
      .where((t) => t.type == TransactionType.expense)
      .fold(0.0, (sum, item) => sum + item.amount);
  double get currentBalance => totalIncome - totalExpense;
 

  // 1. دالة ذكية لتوليد نصيحة اليوم
  String get dailyInsight {
    if (_transactions.where((t) => t.type == TransactionType.expense).isEmpty) {
      return 'بداية رائعة! ابدأ بتسجيل أول مصروف لك لترى السحر.';
    }

    // إيجاد الفئة الأعلى إنفاقاً
    final expenseMap = <String, double>{};
    for (var t
        in _transactions.where((t) => t.type == TransactionType.expense)) {
      expenseMap.update(t.category, (value) => value + t.amount,
          ifAbsent: () => t.amount);
    }

    // ترتيب الفئات من الأعلى للأقل
    final sortedExpenses = expenseMap.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final highestSpendingCategory = sortedExpenses.first;

    // توليد نصيحة بناءً على الفئة الأعلى
    return 'يبدو أن معظم إنفاقك هذا الشهر يذهب إلى فئة "${highestSpendingCategory.key}". ما رأيك في مراجعة هذه الفئة؟';
  }

 
  void addTransaction(Transaction transaction) {
    _transactions.add(transaction);
    _updateBudgets();
    notifyListeners();
  }

  void addGoal(Goal goal) {
    _goals.add(goal);
    notifyListeners();
  }

  void addBudget(Budget budget) {
    _budgets.add(budget);
    _updateBudgets();
    notifyListeners();
  }

  void addSavingsToGoal(Goal goal, double amount) {
    final goalIndex = _goals.indexOf(goal);
    if (goalIndex != -1) {
      _goals[goalIndex].savedAmount += amount;
      notifyListeners();
    }
  }

  // 1. دالة جديدة لحذف معاملة
  void deleteTransaction(Transaction transaction) {
    _transactions.remove(transaction);
    _updateBudgets();
    notifyListeners();
  }

  void _updateBudgets() {
    for (var budget in _budgets) {
      final spent = _transactions
          .where((t) =>
              t.type == TransactionType.expense &&
              t.category == budget.categoryName)
          .fold(0.0, (sum, item) => sum + item.amount);
      budget.spentAmount = spent;
    }
  }

  AppData() {
    _updateBudgets();
  }
}

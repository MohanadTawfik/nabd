import 'package:flutter/material.dart';
import 'package:nabd/features/goals/models/goal_model.dart';
import 'package:nabd/features/transactions/models/transaction_model.dart';

class AppData extends ChangeNotifier {
  // 1. إضافة بيانات أولية للدخل لتكون التجربة أفضل عند أول تشغيل
  final List<Transaction> _transactions = [
    Transaction(
        category: 'راتب',
        icon: Icons.wallet,
        amount: 400000,
        type: TransactionType.income,
        date: DateTime.now().subtract(const Duration(days: 5))),
    Transaction(
        category: 'طعام',
        icon: Icons.fastfood,
        amount: 15000,
        type: TransactionType.expense,
        date: DateTime.now().subtract(const Duration(days: 2))),
    Transaction(
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

  List<Transaction> get transactions => _transactions;
  List<Goal> get goals => _goals;

  double get totalIncome => _transactions
      .where((t) => t.type == TransactionType.income)
      .fold(0.0, (sum, item) => sum + item.amount);
  double get totalExpense => _transactions
      .where((t) => t.type == TransactionType.expense)
      .fold(0.0, (sum, item) => sum + item.amount);
  // 2. الرصيد الآن سيعكس الدخل والمصروف بشكل صحيح
  double get currentBalance => totalIncome - totalExpense;

  void addTransaction(Transaction transaction) {
    _transactions.add(transaction);
    notifyListeners();
  }

  void addGoal(Goal goal) {
    _goals.add(goal);
    notifyListeners();
  }
}

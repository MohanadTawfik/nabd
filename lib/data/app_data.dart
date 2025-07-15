import 'package:flutter/material.dart';
import 'package:nabd/features/goals/models/goal_model.dart';
import 'package:nabd/features/transactions/models/transaction_model.dart';

class AppData extends ChangeNotifier {
  // قائمة المعاملات
  final List<Transaction> _transactions = [];
  // قائمة الأهداف
  final List<Goal> _goals = [
    Goal(
        name: 'سيارة أحلامي',
        icon: Icons.directions_car,
        savedAmount: 750000.0,
        totalAmount: 1000000.0,
        color: Colors.blue.shade300),
  ];

  // طرق للوصول إلى البيانات (للقراءة فقط)
  List<Transaction> get transactions => _transactions;
  List<Goal> get goals => _goals;

  // حسابات سريعة
  double get totalIncome => _transactions
      .where((t) => t.type == TransactionType.income)
      .fold(0.0, (sum, item) => sum + item.amount);
  double get totalExpense => _transactions
      .where((t) => t.type == TransactionType.expense)
      .fold(0.0, (sum, item) => sum + item.amount);
  double get currentBalance => totalIncome - totalExpense;

  // دالة لإضافة معاملة جديدة
  void addTransaction(Transaction transaction) {
    _transactions.add(transaction);
    // إخبار كل من "يستمع" أن البيانات قد تغيرت
    notifyListeners();
  }

  // دالة لإضافة هدف جديد
  void addGoal(Goal goal) {
    _goals.add(goal);
    notifyListeners();
  }
}

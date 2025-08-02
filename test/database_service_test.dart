import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:nabd/services/database_service.dart';
import 'package:nabd/features/transactions/models/transaction_model.dart'
    as nabd_txn;
import 'package:nabd/features/categories/models/category_model.dart';
import 'package:nabd/features/budgets/models/budget_model.dart';
import 'package:nabd/features/goals/models/goal_model.dart';

void main() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
  group('DatabaseService', () {
    late DatabaseService db;

    setUp(() {
      db = DatabaseService(dbPathOverride: ':memory:');
    });

    test('Insert and fetch category', () async {
      final category = Category(
        id: 'testcat',
        name: 'Test Category',
        icon: const IconData(0xe3af, fontFamily: 'MaterialIcons'),
        color: const Color(0xFF123456),
        type: nabd_txn.TransactionType.expense,
      );
      await db.insertCategory(category);
      final categories = await db.getCategories();
      expect(categories.any((c) => c.id == 'testcat'), true);
    });

    test('Insert and fetch transaction', () async {
      final category = Category(
        id: 'testcat2',
        name: 'TestCat2',
        icon: const IconData(0xe3af, fontFamily: 'MaterialIcons'),
        color: const Color(0xFF654321),
        type: nabd_txn.TransactionType.income,
      );
      await db.insertCategory(category);
      final txn = nabd_txn.Transaction(
        id: 'txntest',
        category: category,
        amount: 100.0,
        type: nabd_txn.TransactionType.income,
        date: DateTime.now(),
        notes: 'Test',
        source: 'UnitTest',
      );
      await db.insertTransaction(txn);
      final txns = await db.getTransactions();
      expect(txns.any((t) => t.id == 'txntest'), true);
    });

    test('Insert and fetch budget', () async {
      final category = Category(
        id: 'testcat3',
        name: 'TestCat3',
        icon: const IconData(0xe3af, fontFamily: 'MaterialIcons'),
        color: const Color(0xFFabcdef),
        type: nabd_txn.TransactionType.expense,
      );
      await db.insertCategory(category);
      final budget = Budget(
        id: 'budgettest',
        category: category,
        totalAmount: 500.0,
        startDate: DateTime.now(),
        endDate: DateTime.now().add(const Duration(days: 30)),
        period: BudgetPeriod.monthly,
      );
      await db.insertBudget(budget);
      final budgets = await db.getBudgets();
      expect(budgets.any((b) => b.id == 'budgettest'), true);
    });

    test('Insert and fetch goal', () async {
      final goal = Goal(
        id: 'goaltest',
        name: 'Test Goal',
        icon: const IconData(0xe3af, fontFamily: 'MaterialIcons'),
        color: const Color(0xFFfedcba),
        totalAmount: 1000.0,
        savedAmount: 100.0,
      );
      await db.insertGoal(goal);
      final goals = await db.getGoals();
      expect(goals.any((g) => g.id == 'goaltest'), true);
    });
  });
}

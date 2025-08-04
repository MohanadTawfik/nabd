import 'dart:async';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart' hide Transaction;
import 'package:nabd/features/transactions/models/transaction_model.dart';
import 'package:nabd/features/categories/models/category_model.dart';
import 'package:nabd/features/budgets/models/budget_model.dart';
import 'package:nabd/features/goals/models/goal_model.dart';

class DatabaseService {
  final String? dbPathOverride;

  DatabaseService({this.dbPathOverride});

  Database? _database;
  final Completer<Database> _databaseCompleter = Completer<Database>();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDb();
    return _database!;
  }

  Future<Database> _initDb() async {
    if (_database != null) return _database!;

    String path;
    if (dbPathOverride != null) {
      path = dbPathOverride!;
    } else {
      final defaultDbPath = await getDatabasesPath();
      path = join(defaultDbPath, 'nabd_finance.db');
    }

    // Increment version when changing the schema
    const int currentDbVersion = 2;

    final db = await openDatabase(
      path,
      version: currentDbVersion,
      onCreate: (db, version) async {
        // First create all tables
        await _onCreate(db, version);
        // Then insert default categories
        await _insertDefaultCategories(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          // Migration to version 2: Add indexes for better performance
          await db.execute(
              'CREATE INDEX IF NOT EXISTS idx_transactions_date ON transactions(date)');
          await db.execute(
              'CREATE INDEX IF NOT EXISTS idx_transactions_type ON transactions(type)');
          await db.execute(
              'CREATE INDEX IF NOT EXISTS idx_budgets_category ON budgets(categoryId)');
          await db.execute(
              'CREATE INDEX IF NOT EXISTS idx_budgets_period ON budgets(period)');
          await db.execute(
              'CREATE INDEX IF NOT EXISTS idx_goals_created ON goals(createdAt)');
        }
        // Add more migrations here as needed when incrementing the version
      },
    );

    // Check if categories table is empty and insert defaults if needed
    try {
      final categoriesCount = Sqflite.firstIntValue(
              await db.rawQuery('SELECT COUNT(*) FROM categories')) ??
          0;

      if (categoriesCount == 0) {
        await _insertDefaultCategories(db);
      }
    } catch (e) {
      // If the categories table doesn't exist yet, it will be created by _onCreate
      debugPrint('Error checking categories table: $e');
    }

    return db;
  }

  Future<void> _onCreate(Database db, int version) async {
    // Create categories table
    await db.execute('''
      CREATE TABLE categories (
        id TEXT PRIMARY KEY,
        name TEXT,
        type TEXT,
        color INTEGER,
        icon INTEGER
      )
    ''');

    // Create transactions table
    await db.execute('''
      CREATE TABLE transactions (
        id TEXT PRIMARY KEY,
        categoryId TEXT,
        amount REAL,
        type TEXT,
        date TEXT,
        notes TEXT,
        source TEXT,
        FOREIGN KEY(categoryId) REFERENCES categories(id)
      )
    ''');

    // Create budgets table
    await db.execute('''
      CREATE TABLE budgets (
        id TEXT PRIMARY KEY,
        categoryId TEXT,
        totalAmount REAL,
        startDate TEXT,
        endDate TEXT,
        period TEXT,
        receiveNotifications INTEGER,
        notificationThreshold REAL,
        spentAmount REAL,
        FOREIGN KEY(categoryId) REFERENCES categories(id)
      )
    ''');

    // Create goals table
    await db.execute('''
      CREATE TABLE goals (
        id TEXT PRIMARY KEY,
        name TEXT,
        iconCodePoint INTEGER,
        colorValue INTEGER,
        savedAmount REAL,
        totalAmount REAL,
        createdAt TEXT,
        targetDate TEXT
      )
    ''');

    // Add indexes for better query performance
    await db
        .execute('CREATE INDEX idx_transactions_date ON transactions(date)');
    await db
        .execute('CREATE INDEX idx_transactions_type ON transactions(type)');
    await db
        .execute('CREATE INDEX idx_budgets_category ON budgets(categoryId)');
    await db.execute('CREATE INDEX idx_budgets_period ON budgets(period)');
    await db.execute('CREATE INDEX idx_goals_created ON goals(createdAt)');
  }

  // Category CRUD

  Future<void> _insertDefaultCategories(Database db) async {
    try {
      // Check if categories already exist
      final existing = await db.query('categories');
      if (existing.isNotEmpty) return;

      final List<Category> defaultCategories = [
        // الدخل (Income)
        Category(
          id: 'salary',
          name: 'الراتب والأجور',
          icon: Icons.attach_money,
          color: const Color(0xFF4CAF50),
          type: TransactionType.income,
        ),
        Category(
          id: 'other_income',
          name: 'دخل آخر',
          icon: Icons.monetization_on,
          color: const Color(0xFF81C784),
          type: TransactionType.income,
        ),

        // النفقات (Expenses)
        Category(
          id: 'housing',
          name: 'السكن والفواتير',
          icon: Icons.home_outlined,
          color: const Color(0xFF2196F3),
          type: TransactionType.expense,
        ),
        Category(
          id: 'food',
          name: 'الطعام والشراب',
          icon: Icons.restaurant,
          color: const Color(0xFFFF9800),
          type: TransactionType.expense,
        ),
        Category(
          id: 'transport',
          name: 'المواصلات والنقل',
          icon: Icons.directions_bus,
          color: const Color(0xFF607D8B),
          type: TransactionType.expense,
        ),
        Category(
          id: 'shopping',
          name: 'التسوق والمستلزمات',
          icon: Icons.shopping_bag,
          color: const Color(0xFF9C27B0),
          type: TransactionType.expense,
        ),
        Category(
          id: 'health',
          name: 'الصحة',
          icon: Icons.local_hospital,
          color: const Color(0xFFE91E63),
          type: TransactionType.expense,
        ),
        Category(
          id: 'education',
          name: 'التعليم',
          icon: Icons.school,
          color: const Color(0xFF3F51B5),
          type: TransactionType.expense,
        ),
        Category(
          id: 'entertainment',
          name: 'الترفيه',
          icon: Icons.sports_esports,
          color: const Color(0xFFFFC107),
          type: TransactionType.expense,
        ),
        Category(
          id: 'commitments',
          name: 'التزامات مالية',
          icon: Icons.assignment,
          color: const Color(0xFF795548),
          type: TransactionType.expense,
        ),
        Category(
          id: 'other_expense',
          name: 'مصاريف أخرى',
          icon: Icons.more_horiz,
          color: const Color(0xFFBDBDBD),
          type: TransactionType.expense,
        ),

        // التحويلات (Transfers)
        Category(
          id: 'transfers',
          name: 'تحويلات',
          icon: Icons.swap_horiz,
          color: const Color(0xFF00BCD4),
          type: TransactionType.transfer,
        ),
      ];

      // Default budgets for expense categories (in SAR)
      final Map<String, double> defaultBudgets = {
        'housing': 0,     // Rent and utilities
        'food': 0,       // Food and groceries
        'transport': 0,   // Transportation
        'shopping': 0,   // Shopping and supplies
        'health': 0,     // Health expenses
        'education': 0,  // Education
        'entertainment': 0, // Entertainment
        'commitments': 0, // Financial commitments
        'other_expense': 0, // Other expenses
      };

      // Insert all default categories in a transaction
      final batch = db.batch();
      
      // First, insert all categories
      for (final category in defaultCategories) {
        batch.insert('categories', category.toMap(),
            conflictAlgorithm: ConflictAlgorithm.replace);
      }

      // Then, insert default budgets for expense categories
      final now = DateTime.now();
      final firstDayOfMonth = DateTime(now.year, now.month, 1);
      final lastDayOfMonth = DateTime(now.year, now.month + 1, 0);
      
      for (final category in defaultCategories.where((c) => c.type == TransactionType.expense)) {
        if (defaultBudgets.containsKey(category.id)) {
          final budget = Budget(
            id: '${category.id}_budget_${now.millisecondsSinceEpoch}',
            categoryId: category.id,
            totalAmount: defaultBudgets[category.id]!,
            startDate: firstDayOfMonth,
            endDate: lastDayOfMonth,
            period: BudgetPeriod.monthly,
            receiveNotifications: true,
            notificationThreshold: 80.0,
            spentAmount: 0.0,
          );
          
          batch.insert('budgets', budget.toMap(),
              conflictAlgorithm: ConflictAlgorithm.replace);
        }
      }

      await batch.commit(noResult: true);
      debugPrint('Inserted ${defaultCategories.length} default categories and ${defaultBudgets.length} default budgets');
    } catch (e) {
      debugPrint('Error inserting default categories and budgets: $e');
      rethrow;
    }
  }

  Future<void> insertCategory(Category category) async {
    final db = await database;
    await db.insert('categories', category.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Category>> getCategories() async {
    final db = await database;
    final maps = await db.query('categories');
    return maps.map((m) => Category.fromMap(m)).toList();
  }

  Future<void> updateCategory(Category category) async {
    final db = await database;
    await db.update(
      'categories',
      category.toMap(),
      where: 'id = ?',
      whereArgs: [category.id],
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> deleteCategory(String id) async {
    final db = await database;
    await db.delete(
      'categories',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Transaction CRUD
  Future<void> insertTransaction(Transaction txn) async {
    final db = await database;
    await db.insert('transactions', txn.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Transaction>> getTransactions() async {
    final db = await database;
    final maps = await db.query('transactions', orderBy: 'date DESC');
    return maps.map((m) => Transaction.fromMap(m)).toList();
  }

  Future<void> updateTransaction(Transaction txn) async {
    final db = await database;
    await db.update('transactions', txn.toMap(),
        where: 'id = ?', whereArgs: [txn.id]);
  }

  Future<void> deleteTransaction(String id) async {
    final db = await database;
    await db.delete('transactions', where: 'id = ?', whereArgs: [id]);
  }

  // Budget CRUD
  Future<void> insertBudget(Budget budget) async {
    final db = await database;
    await db.insert('budgets', budget.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Budget>> getBudgets() async {
    final db = await database;
    final maps = await db.query('budgets');
    return maps.map((m) => Budget.fromMap(m)).toList();
  }

  Future<void> updateBudget(Budget budget) async {
    final db = await database;
    await db.update('budgets', budget.toMap(),
        where: 'id = ?', whereArgs: [budget.id]);
  }

  Future<void> deleteBudget(String id) async {
    final db = await database;
    await db.delete('budgets', where: 'id = ?', whereArgs: [id]);
  }

  // Goal CRUD
  Future<void> insertGoal(Goal goal) async {
    final db = await database;
    await db.insert('goals', goal.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Goal>> getGoals() async {
    final db = await database;
    final maps = await db.query('goals');
    return maps.map((m) => Goal.fromMap(m)).toList();
  }

  Future<void> updateGoal(Goal goal) async {
    final db = await database;
    await db
        .update('goals', goal.toMap(), where: 'id = ?', whereArgs: [goal.id]);
  }

  Future<void> deleteGoal(String id) async {
    final db = await database;
    await db.delete('goals', where: 'id = ?', whereArgs: [id]);
  }
}

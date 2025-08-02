import 'package:flutter/material.dart';
import 'package:nabd/features/categories/models/category_model.dart';
import 'package:nabd/features/transactions/models/transaction_model.dart';
import 'package:nabd/features/budgets/models/budget_model.dart';
import 'package:nabd/features/goals/models/goal_model.dart';
import 'package:nabd/features/journey/models/timeline_item_model.dart';
import 'package:uuid/uuid.dart';

final _uuid = const Uuid();

// قائمة الفئات التجريبية
final List<Category> defaultCategories = [
  Category(
    id: 'food',
    name: 'طعام',
    icon: Icons.restaurant,
    color: const Color(0xFFFF6B6B),
    type: TransactionType.expense,
  ),
  Category(
    id: 'transport',
    name: 'مواصلات',
    icon: Icons.directions_car,
    color: const Color(0xFF4ECDC4),
    type: TransactionType.expense,
  ),
  Category(
    id: 'shopping',
    name: 'تسوق',
    icon: Icons.shopping_bag,
    color: const Color(0xFFF8A5C2),
    type: TransactionType.expense,
  ),
  Category(
    id: 'bills',
    name: 'فواتير',
    icon: Icons.receipt,
    color: const Color(0xFF4DB6AC),
    type: TransactionType.expense,
  ),
  Category(
    id: 'entertainment',
    name: 'ترفيه',
    icon: Icons.movie,
    color: const Color(0xFFFFD54F),
    type: TransactionType.expense,
  ),
  Category(
    id: 'health',
    name: 'صحة',
    icon: Icons.medical_services,
    color: const Color(0xFFFF5252),
    type: TransactionType.expense,
  ),
  Category(
    id: 'education',
    name: 'تعليم',
    icon: Icons.school,
    color: const Color(0xFF7986CB),
    type: TransactionType.expense,
  ),
  Category(
    id: 'qat',
    name: 'القات',
    icon: Icons.local_florist,
    color: const Color(0xFF8BC34A),
    type: TransactionType.expense,
  ),
  Category(
    id: 'salary',
    name: 'راتب',
    icon: Icons.account_balance_wallet,
    color: const Color(0xFF66BB6A),
    type: TransactionType.income,
  ),
  Category(
    id: 'freelance',
    name: 'عمل حر',
    icon: Icons.laptop,
    color: const Color(0xFF42A5F5),
    type: TransactionType.income,
  ),
  Category(
    id: 'gifts',
    name: 'هدايا',
    icon: Icons.card_giftcard,
    color: const Color(0xFFEC407A),
    type: TransactionType.income,
  ),
  Category(
    id: 'investments',
    name: 'استثمارات',
    icon: Icons.trending_up,
    color: const Color(0xFF7E57C2),
    type: TransactionType.income,
  ),
];

// قائمة المعاملات التجريبية
final List<Transaction> dummyTransactions = [
  Transaction(
    id: _uuid.v4(),
    category: defaultCategories.firstWhere((c) => c.id == 'salary'),
    amount: 15000,
    type: TransactionType.income,
    date: DateTime.now().subtract(const Duration(days: 15)),
    notes: 'راتب الشهر',
  ),
  Transaction(
    id: _uuid.v4(),
    category: defaultCategories.firstWhere((c) => c.id == 'freelance'),
    amount: 2500,
    type: TransactionType.income,
    date: DateTime.now().subtract(const Duration(days: 10)),
    notes: 'مشروع تصميم موقع',
  ),
  Transaction(
    id: _uuid.v4(),
    category: defaultCategories.firstWhere((c) => c.id == 'food'),
    amount: 850,
    type: TransactionType.expense,
    date: DateTime.now().subtract(const Duration(days: 2)),
    notes: 'عشاء مع الأصدقاء',
  ),
  Transaction(
    id: _uuid.v4(),
    category: defaultCategories.firstWhere((c) => c.id == 'qat'),
    amount: 1500,
    type: TransactionType.expense,
    date: DateTime.now().subtract(const Duration(days: 1)),
    notes: 'شراء القات الأسبوعي',
  ),
  Transaction(
    id: _uuid.v4(),
    category: defaultCategories.firstWhere((c) => c.id == 'transport'),
    amount: 300,
    type: TransactionType.expense,
    date: DateTime.now().subtract(const Duration(days: 3)),
    notes: 'تعبئة وقود',
  ),
  Transaction(
    id: _uuid.v4(),
    category: defaultCategories.firstWhere((c) => c.id == 'shopping'),
    amount: 1200,
    type: TransactionType.expense,
    date: DateTime.now().subtract(const Duration(days: 5)),
    notes: 'ملابس جديدة',
  ),
];

// قائمة الميزانيات التجريبية
final List<Budget> mockBudgets = [
  Budget(
    id: _uuid.v4(),
    category: defaultCategories.firstWhere((c) => c.id == 'food'),
    totalAmount: 5000,
    startDate: DateTime(DateTime.now().year, DateTime.now().month, 1),
    endDate: DateTime(DateTime.now().year, DateTime.now().month + 1, 0),
    period: BudgetPeriod.monthly,
  ),
  Budget(
    id: _uuid.v4(),
    category: defaultCategories.firstWhere((c) => c.id == 'shopping'),
    totalAmount: 3000,
    startDate: DateTime(DateTime.now().year, DateTime.now().month, 1),
    endDate: DateTime(DateTime.now().year, DateTime.now().month + 1, 0),
    period: BudgetPeriod.monthly,
  ),
];

// قائمة الأهداف التجريبية
final List<Goal> mockGoals = [
  Goal(
    id: _uuid.v4(),
    name: 'سيارة جديدة',
    icon: Icons.directions_car,
    totalAmount: 50000,
    color: Colors.blue.shade300,
    savedAmount: 15000,
  ),
  Goal(
    id: _uuid.v4(),
    name: 'رحلة سياحية',
    icon: Icons.airplanemode_active,
    totalAmount: 20000,
    color: Colors.teal.shade300,
    savedAmount: 8000,
  ),
];

// قائمة أحداث الرحلة المالية التجريبية
final List<TimelineItem> mockTimelineItems = [
  TimelineItem(
    id: _uuid.v4(),
    title: 'بداية رحلتك المالية',
    description:
        'بدأت استخدام تطبيق مصروفي لتتبع نفقاتك وتحقيق أهدافك المالية.',
    date: DateTime.now().subtract(const Duration(days: 30)),
    icon: Icons.play_circle_outline,
    color: Colors.green,
    type: TimelineItemType.milestone,
  ),
  TimelineItem(
    id: _uuid.v4(),
    title: 'تجاوزت ميزانية الطعام',
    description: 'تجاوزت ميزانية الطعام لهذا الشهر بنسبة 10%.',
    date: DateTime.now().subtract(const Duration(days: 5)),
    icon: Icons.warning_amber,
    color: Colors.red,
    type: TimelineItemType.alert,
  ),
];

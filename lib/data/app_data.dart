import 'package:flutter/material.dart';
import 'package:nabd/features/budgets/models/budget_model.dart';
import 'package:nabd/features/categories/models/category_model.dart';
import 'package:nabd/features/goals/models/goal_model.dart';
import 'package:nabd/features/journey/models/timeline_item_model.dart';
import 'package:nabd/features/transactions/models/transaction_model.dart';

class AppData with ChangeNotifier {
  // 1. إضافة متغير جديد لحفظ حالة المظهر
  ThemeMode _themeMode = ThemeMode.dark;
  ThemeMode get themeMode => _themeMode;

  // 1. تحديث البيانات الأولية لتستخدم كائنات الفئات
  late final List<Transaction> _transactions;
  // 1. قائمة جديدة لتخزين المعاملات المصفاة
  List<Transaction> _filteredTransactions = [];
  bool _isFilterActive = false;

  // 2. قائمة الفئات الآن هي المصدر الحقيقي
  final List<Category> _categories = [
    Category(
      id: 'qat',
      name: 'القات',
      icon: Icons.local_florist,
      color: Color(0xFF8BC34A),
      type: TransactionType.expense,
    ),
    Category(
      id: 'food',
      name: 'طعام',
      icon: Icons.restaurant,
      color: Color(0xFFFF6B6B),
      type: TransactionType.expense,
    ),
    Category(
      id: 'transport',
      name: 'مواصلات',
      icon: Icons.directions_car,
      color: Color(0xFF4ECDC4),
      type: TransactionType.expense,
    ),
    Category(
      id: 'shopping',
      name: 'تسوق',
      icon: Icons.shopping_cart,
      color: Color(0xFF45B7D1),
      type: TransactionType.expense,
    ),
    Category(
      id: 'bills',
      name: 'فواتير',
      icon: Icons.receipt_long,
      color: Color(0xFF96CEB4),
      type: TransactionType.expense,
    ),
    Category(
      id: 'entertainment',
      name: 'ترفيه',
      icon: Icons.movie,
      color: Color(0xFFFFEEAD),
      type: TransactionType.expense,
    ),
    Category(
      id: 'health',
      name: 'صحة',
      icon: Icons.medical_services,
      color: Color(0xFFD4A5A5),
      type: TransactionType.expense,
    ),
    Category(
      id: 'education',
      name: 'تعليم',
      icon: Icons.school,
      color: Color(0xFF9B5DE5),
      type: TransactionType.expense,
    ),
    Category(
      id: 'other',
      name: 'أخرى',
      icon: Icons.category,
      color: Color(0xFF6C757D),
      type: TransactionType.expense,
    ),
    Category(
      id: 'salary',
      name: 'راتب',
      icon: Icons.work,
      color: Color(0xFF45B7D1),
      type: TransactionType.income,
    ),
    Category(
      id: 'bonus',
      name: 'مكافئة',
      icon: Icons.card_giftcard,
      color: Color(0xFF8BC34A),
      type: TransactionType.income,
    ),
    Category(
      id: 'other',
      name: 'أخرى',
      icon: Icons.category,
      color: Color(0xFF6C757D),
      type: TransactionType.income,
    ),
    // Category(
    //   id: 'debt_installments',
    //   name: 'دفع ديون واقساط',
    //   icon: Icons.payments,
    //   color: Color(0xFF9B5DE5),
    //   type: TransactionType.debt,
    // ),
    // Category(
    //   id: 'debt_settlement',
    //   name: 'تسديد ديون واقساط',
    //   icon: Icons.check_circle,
    //   color: Color(0xFF45B7D1),
    //   type: TransactionType.debt,
    // ),
  ];

  final List<Goal> _goals = [
    Goal(
        name: 'سيارة أحلامي',
        icon: Icons.directions_car,
        savedAmount: 750000.0,
        totalAmount: 1000000.0,
        color: Colors.blue.shade300),
    Goal(
        name: 'السفر إلى سقطرى',
        icon: Icons.airplanemode_active,
        savedAmount: 200000.0,
        totalAmount: 500000.0,
        color: Colors.teal.shade300),
  ];

  final List<Budget> _budgets = [
    Budget(categoryName: 'طعام', icon: Icons.fastfood, totalAmount: 50000),
    Budget(categoryName: 'تسوق', icon: Icons.shopping_bag, totalAmount: 40000),
    Budget(categoryName: 'قات', icon: Icons.local_florist, totalAmount: 30000),
    Budget(
        categoryName: 'مواصلات',
        icon: Icons.directions_car,
        totalAmount: 50000),
    Budget(
        categoryName: 'فواتير', icon: Icons.receipt_long, totalAmount: 100000),
    Budget(categoryName: 'ترفيه', icon: Icons.movie, totalAmount: 20000),
    Budget(
        categoryName: 'صحة', icon: Icons.medical_services, totalAmount: 30000),
    Budget(categoryName: 'تعليم', icon: Icons.school, totalAmount: 15000),
    Budget(categoryName: 'أخرى', icon: Icons.category, totalAmount: 20000),
    Budget(categoryName: 'راتب', icon: Icons.work, totalAmount: 20000),
    Budget(
        categoryName: 'مكافئة', icon: Icons.card_giftcard, totalAmount: 20000),
  ];

  // 1. قائمة جديدة للأحداث (مثل تحقيق هدف)
  final List<TimelineItem> _events = [];

  // 2. getter جديد يدمج المعاملات والأحداث ويرتبها بالتاريخ
  List<TimelineItem> get timelineItems {
    final List<TimelineItem> allItems = [];

    // إضافة المعاملات
    for (var t in _transactions) {
      allItems.add(TimelineItem(date: t.date, event: t));
    }
    // إضافة الأحداث
    allItems.addAll(_events);

    // ترتيب الكل من الأحدث للأقدم
    allItems.sort((a, b) => b.date.compareTo(a.date));
    return allItems;
  }

  // 1. هذا هو الإصلاح: إضافة getter عام للمتغير الخاص
  bool get isFilterActive => _isFilterActive;

  List<Category> get expenseCategories =>
      _categories.where((c) => c.type == TransactionType.expense).toList();
  List<Category> get incomeCategories =>
      _categories.where((c) => c.type == TransactionType.income).toList();

  List<Category> get categories => _categories;
  List<Transaction> get transactions {
    // إذا كان الفلتر فعالاً، نعرض القائمة المصفاة، وإلا نعرض القائمة الكاملة
    return _isFilterActive ? _filteredTransactions : _transactions;
  }

  List<Goal> get goals => _goals;
  List<Budget> get budgets => _budgets;
  double get totalIncome => _transactions
      .where((t) => t.type == TransactionType.income)
      .fold(0.0, (sum, item) => sum + item.amount);
  double get totalExpense => _transactions
      .where((t) => t.type == TransactionType.expense)
      .fold(0.0, (sum, item) => sum + item.amount);
  double get currentBalance => totalIncome - totalExpense;

  // 3. دالة جديدة لتسجيل تحقيق الهدف كحدث
  void achieveGoal(Goal goal) {
    // إضافة حدث جديد
    _events.add(TimelineItem(date: DateTime.now(), event: goal));
    // حذف الهدف من القائمة النشطة
    _goals.remove(goal);
    notifyListeners();
  }

  // 1. إعادة كتابة دالة "نصيحة اليوم" بالكامل لتكون ذكية
  String get dailyInsight {
    // قائمة من الدوال التي تولد النصائح
    final insightGenerators = <String? Function()>[
      _generateBudgetInsight,
      _generateHighSpendingInsight,
      _generateGoalInsight,
    ];

    // خلط القائمة للحصول على نصيحة مختلفة في كل مرة
    insightGenerators.shuffle();

    for (var generator in insightGenerators) {
      final insight = generator();
      if (insight != null) {
        return insight; // إرجاع أول نصيحة صالحة
      }
    }

    // نصيحة افتراضية إذا لم يتم توليد أي نصيحة أخرى
    return 'عمل رائع! استمر في تتبع نفقاتك لتحقيق أهدافك المالية.';
  }

  // دالة لتوليد نصيحة عن الميزانية
  String? _generateBudgetInsight() {
    for (var budget in _budgets) {
      final progress = budget.spentAmount / budget.totalAmount;
      if (progress >= 0.8 && progress < 1.0) {
        return 'انتبه! لقد اقتربت من الوصول إلى حد ميزانية "${budget.categoryName}".';
      }
    }
    return null;
  }

  // دالة لتوليد نصيحة عن الإنفاق العالي
  String? _generateHighSpendingInsight() {
    if (_transactions.where((t) => t.type == TransactionType.expense).length <
        5) return null;

    final expenseMap = <String, double>{};
    for (var t
        in _transactions.where((t) => t.type == TransactionType.expense)) {
      expenseMap.update(t.category.name, (value) => value + t.amount,
          ifAbsent: () => t.amount);
    }

    final sortedExpenses = expenseMap.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final highestSpendingCategory = sortedExpenses.first;

    if (highestSpendingCategory.value > (totalExpense * 0.4)) {
      // إذا كانت الفئة الأعلى تمثل أكثر من 40% من المصروفات
      return 'يبدو أن معظم إنفاقك يذهب إلى فئة "${highestSpendingCategory.key}". ما رأيك في مراجعتها؟';
    }
    return null;
  }

  // دالة لتوليد نصيحة عن الأهداف
  String? _generateGoalInsight() {
    if (_goals.isEmpty) return null;
    final goal = _goals.first; // كمثال، نأخذ أول هدف
    final progress = goal.savedAmount / goal.totalAmount;
    if (progress > 0.5 && progress < 0.9) {
      return 'أنت في منتصف الطريق نحو تحقيق هدفك "${goal.name}"! عمل رائع، استمر بذلك! 🎉';
    }
    return null;
  }

  // 2. دالة لتغيير المظهر وإخبار المستمعين
  void changeTheme(ThemeMode themeMode) {
    _themeMode = themeMode;
    notifyListeners();
  }

  // 2. دالة جديدة لتطبيق الفلتر
  void filterTransactions(
      {DateTime? startDate, DateTime? endDate, List<Category>? categories}) {
    // نبدأ بالقائمة الكاملة
    List<Transaction> results = _transactions;

    // تصفية حسب التاريخ
    if (startDate != null && endDate != null) {
      // تعديل بسيط هنا ليكون التاريخ شاملاً
      final inclusiveEndDate = endDate.add(const Duration(days: 1));
      results = results
          .where((t) =>
              !t.date.isBefore(startDate) && t.date.isBefore(inclusiveEndDate))
          .toList();
    }

    // تصفية حسب الفئات
    if (categories != null && categories.isNotEmpty) {
      final categoryIds = categories.map((c) => c.id).toSet();
      results =
          results.where((t) => categoryIds.contains(t.category.id)).toList();
    }

    _filteredTransactions = results;
    _isFilterActive = true;
    notifyListeners();
  }

  // 3. دالة لإلغاء الفلتر
  void clearFilter() {
    _isFilterActive = false;
    notifyListeners();
  }

  // 3. دوال جديدة لإدارة الفئات
  void addCategory(Category category) {
    _categories.add(category);
    notifyListeners();
  }

  void updateCategory(Category updatedCategory) {
    final index = _categories.indexWhere((c) => c.id == updatedCategory.id);
    if (index != -1) {
      _categories[index] = updatedCategory;
      notifyListeners();
    }
  }

  void deleteCategory(Category category) {
    _categories.remove(category);
    // يمكنك إضافة منطق لحذف المعاملات المرتبطة بهذه الفئة هنا
    notifyListeners();
  }

  void addTransaction(Transaction transaction) {
    _transactions.add(transaction);
    _updateBudgets();
    notifyListeners();
  }

  // 1. دالة جديدة لتحديث معاملة موجودة
  void updateTransaction(Transaction updatedTransaction) {
    // البحث عن مؤشر المعاملة القديمة باستخدام الـ ID الفريد
    final index =
        _transactions.indexWhere((t) => t.id == updatedTransaction.id);
    if (index != -1) {
      _transactions[index] = updatedTransaction;
      _updateBudgets();
      notifyListeners();
    }
  }

  void deleteTransaction(Transaction transaction) {
    _transactions.remove(transaction);
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

  // 1. دالة جديدة لحذف هدف
  void deleteGoal(Goal goal) {
    _goals.remove(goal);
    notifyListeners();
  }

  // 1. دالة ذكية لحساب مؤشر الصحة المالية (من 0.0 إلى 1.0)
  double get financialHealthScore {
    double score = 0;

    // معيار 1: نسبة التوفير (تصل إلى 50 نقطة)
    if (totalIncome > 0) {
      double savingsRatio = (totalIncome - totalExpense) / totalIncome;
      score += (savingsRatio.clamp(0.0, 1.0) * 50);
    }

    // معيار 2: الالتزام بالميزانية (تصل إلى 30 نقطة)
    if (_budgets.isNotEmpty) {
      double totalBudgetCompliance = 0;
      for (var budget in _budgets) {
        if (budget.spentAmount <= budget.totalAmount) {
          totalBudgetCompliance += 1;
        }
      }
      score += (totalBudgetCompliance / _budgets.length) * 30;
    }

    // معيار 3: التقدم في الأهداف (تصل إلى 20 نقطة)
    if (_goals.isNotEmpty) {
      double totalGoalProgress = 0;
      for (var goal in _goals) {
        totalGoalProgress +=
            (goal.savedAmount / goal.totalAmount).clamp(0.0, 1.0);
      }
      score += (totalGoalProgress / _goals.length) * 20;
    }

    // إرجاع النتيجة كنسبة مئوية (0.0 إلى 1.0)
    return (score / 100).clamp(0.0, 1.0);
  }

  // دالة لتحديد اسم المستوى بناءً على النتيجة
  String get financialLevelName {
    final score = financialHealthScore;
    if (score < 0.3) return 'البذرة';
    if (score < 0.7) return 'النبتة المتنامية';
    return 'الشجرة المزدهرة';
  }

  // 2. تحديث دالة تحديث الميزانيات
  void _updateBudgets() {
    for (var budget in _budgets) {
      final spent = _transactions
          .where((t) =>
              t.type == TransactionType.expense &&
              t.category.name == budget.categoryName)
          .fold(0.0, (sum, item) => sum + item.amount);
      budget.spentAmount = spent;
    }
  }

  AppData() {
    _transactions = [
      Transaction(
          id: 't1',
          category: _categories.firstWhere((c) => c.id == 'salary'),
          amount: 400000,
          type: TransactionType.income,
          date: DateTime.now().subtract(const Duration(days: 5))),
      Transaction(
          id: 't2',
          category: _categories[0],
          amount: 15000,
          type: TransactionType.expense,
          date: DateTime.now().subtract(const Duration(days: 2))),
      Transaction(
          id: 't3',
          category: _categories[1],
          amount: 5000,
          type: TransactionType.expense,
          date: DateTime.now().subtract(const Duration(days: 1))),
      Transaction(
          id: 't4',
          category: _categories[4],
          amount: 10000,
          type: TransactionType.expense,
          date: DateTime.now().subtract(const Duration(days: 1))),
      Transaction(
          id: 't5',
          category: _categories[5],
          amount: 10000,
          type: TransactionType.expense,
          date: DateTime.now().subtract(const Duration(days: 1))),
      Transaction(
          id: 't6',
          category: _categories[6],
          amount: 10000,
          type: TransactionType.expense,
          date: DateTime.now().subtract(const Duration(days: 1))),
      Transaction(
          id: 't7',
          category: _categories[7],
          amount: 10000,
          type: TransactionType.expense,
          date: DateTime.now().subtract(const Duration(days: 1))),
      Transaction(
          id: 't8',
          category: _categories[8],
          amount: 10000,
          type: TransactionType.expense,
          date: DateTime.now().subtract(const Duration(days: 0))),
      Transaction(
          id: 't9',
          category: _categories[9],
          amount: 10000,
          type: TransactionType.expense,
          date: DateTime.now().subtract(const Duration(days: 0))),
      Transaction(
          id: 't10',
          category: _categories[10],
          amount: 10000,
          type: TransactionType.expense,
          date: DateTime.now().subtract(const Duration(days: 0))),
    ];
    _updateBudgets();
  }
}

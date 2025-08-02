import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:nabd/features/dashboard/widgets/animated_balance_card.dart';
import 'package:nabd/features/dashboard/widgets/daily_tips_widget.dart';
import 'package:nabd/features/dashboard/widgets/expense_summary_chart.dart';
import 'package:nabd/features/dashboard/widgets/recent_transactions_widget.dart';
import 'package:nabd/features/dashboard/widgets/quick_stats_widget.dart';
import 'package:nabd/features/dashboard/widgets/transaction_filter_sheet.dart';
import 'package:nabd/features/transactions/transactions_provider.dart';
import 'package:nabd/features/budgets/budgets_provider.dart';
import 'package:nabd/features/goals/goals_provider.dart';
import 'package:nabd/features/transactions/models/transaction_model.dart';
import 'package:nabd/widgets/glass_background.dart';
import 'package:nabd/widgets/glass_card.dart';
import 'package:nabd/theme/app_colors.dart';
import 'package:provider/provider.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with WidgetsBindingObserver {
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeData();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _refreshData();
    }
  }

  Future<void> _initializeData() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Load all necessary data
      await Future.wait([
        context.read<TransactionsProvider>().loadTransactions(),
        context.read<BudgetsProvider>().loadBudgets(),
        context.read<GoalsProvider>().loadGoals(),
      ]);

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = 'Failed to load dashboard data';
        });
      }
    }
  }

  Future<void> _refreshData() async {
    await _initializeData();
  }

  void _handleQuickAction(int index) {
    switch (index) {
      case 0: // Add Transaction
        Navigator.of(context).pushNamed('/add_transaction');
        break;
      case 1: // Add Budget
        Navigator.of(context).pushNamed('/add_budget');
        break;
      case 2: // Add Goal
        Navigator.of(context).pushNamed('/add_goal');
        break;
      case 3: // Reports
        Navigator.of(context).pushNamed('/insights');
        break;
    }
  }

  void _showFilterSheet() {
    TransactionFilterSheet.show(context);
  }

  void _handleInsightTap(int index) {
    switch (index) {
      case 0: // Monthly Expenses
        Navigator.of(context)
            .pushNamed('/insights', arguments: {'initialTab': 0});
        break;
      case 1: // Monthly Income
        Navigator.of(context)
            .pushNamed('/insights', arguments: {'initialTab': 1});
        break;
      case 2: // Active Budgets
        Navigator.of(context).pushNamed('/budgets');
        break;
    }
  }

  Widget _buildQuickActionCard(int index, ThemeData theme) {
    final List<Map<String, dynamic>> actions = [
      {
        'icon': Icons.add_rounded,
        'label': 'إضافة معاملة',
        'color': AppColors.primaryColor,
      },
      {
        'icon': Icons.account_balance_wallet_outlined,
        'label': 'إضافة ميزانية',
        'color': AppColors.accentColor,
      },
      {
        'icon': Icons.flag_outlined,
        'label': 'إضافة هدف',
        'color': AppColors.successColor,
      },
      {
        'icon': Icons.insights_outlined,
        'label': 'التقارير',
        'color': AppColors.warningColor,
      },
    ];

    final action = actions[index];

    return Padding(
      padding: const EdgeInsets.only(left: 12.0, right: 4.0),
      child: InkWell(
        onTap: () => _handleQuickAction(index),
        borderRadius: BorderRadius.circular(16),
        child: GlassCard(
          borderRadius: 16,
          blurStrength: 5,
          child: Container(
            width: 100,
            height: 100, // Fixed height to prevent overflow
            padding: const EdgeInsets.all(12.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min, // Prevent overflow
              children: [
                Container(
                  padding: const EdgeInsets.all(10.0),
                  decoration: BoxDecoration(
                    color: action['color'].withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    action['icon'],
                    color: action['color'],
                    size: 24,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  action['label'],
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInsightCard(
      int index,
      ThemeData theme,
      TransactionsProvider transactionsProvider,
      BudgetsProvider budgetsProvider) {
    // Calculate monthly expenses and income
    final now = DateTime.now();
    final monthlyTransactions = transactionsProvider.transactions
        .where((t) => t.date.month == now.month && t.date.year == now.year)
        .toList();

    final monthlyExpenses = monthlyTransactions
        .where((t) => t.type == TransactionType.expense)
        .fold<double>(0, (sum, t) => sum + t.amount);

    final monthlyIncome = monthlyTransactions
        .where((t) => t.type == TransactionType.income)
        .fold<double>(0, (sum, t) => sum + t.amount);

    final activeBudgets = budgetsProvider.budgets
        .where((b) => b.endDate.isAfter(now) || b.endDate.isAtSameMomentAs(now))
        .length;

    final List<Map<String, dynamic>> insights = [
      {
        'title': 'المصروفات الشهرية',
        'value': monthlyExpenses.toStringAsFixed(0),
        'icon': Icons.trending_down_rounded,
        'color': AppColors.expenseColor,
        'change': '', // TODO: Calculate percentage change from previous month
        'isPositive': null,
        'subtitle': 'إجمالي مصروفات هذا الشهر',
        'currency': 'ريال',
      },
      {
        'title': 'الدخل الشهري',
        'value': monthlyIncome.toStringAsFixed(0),
        'icon': Icons.trending_up_rounded,
        'color': AppColors.incomeColor,
        'change': '', // TODO: Calculate percentage change from previous month
        'isPositive': null,
        'subtitle': 'إجمالي دخل هذا الشهر',
        'currency': 'ريال',
      },
      {
        'title': 'الميزانيات النشطة',
        'value': activeBudgets.toString(),
        'icon': Icons.pie_chart_rounded,
        'color': AppColors.accentColor,
        'change': '',
        'isPositive': null,
        'subtitle': 'إجمالي الميزانيات النشطة',
        'currency': '',
      },
    ];

    final insight = insights[index];

    return Padding(
      padding: const EdgeInsets.only(left: 12.0),
      child: InkWell(
          onTap: () => _handleInsightTap(index),
          borderRadius: BorderRadius.circular(24),
          child: GlassCard(
            borderRadius: 24,
            blurStrength: 10,
            child: Container(
              width: 180,
              height: 160, // Increased height for Android compatibility
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min, // Prevent overflow
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: insight['color'].withOpacity(0.15),
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: insight['color'].withOpacity(0.1),
                              blurRadius: 8,
                              spreadRadius: 1,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          insight['icon'],
                          color: insight['color'],
                          size: 20,
                        ),
                      ),
                      if (insight['isPositive'] != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: insight['isPositive']
                                ? AppColors.successColor.withOpacity(0.15)
                                : AppColors.errorColor.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: (insight['isPositive']
                                        ? AppColors.successColor
                                        : AppColors.errorColor)
                                    .withOpacity(0.1),
                                blurRadius: 4,
                                spreadRadius: 0,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                          child: Text(
                            insight['change'],
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: insight['isPositive']
                                  ? AppColors.successColor
                                  : AppColors.errorColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 9,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        insight['value'],
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (insight['currency'].isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 2, right: 4),
                          child: Text(
                            insight['currency'],
                            style: theme.textTheme.bodySmall?.copyWith(
                              color:
                                  theme.colorScheme.onSurface.withOpacity(0.7),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    insight['title'],
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    insight['subtitle'],
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                      fontSize: 9,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          )),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final transactionsProvider =
        Provider.of<TransactionsProvider>(context, listen: false);
    final budgetsProvider =
        Provider.of<BudgetsProvider>(context, listen: false);
    final goalsProvider = Provider.of<GoalsProvider>(context, listen: false);

    // Show loading indicator while data is being loaded
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Show error message if there was an error loading data
    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Dashboard')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 60),
              const SizedBox(height: 16),
              Text('Error: $_error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _refreshData,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: GlassBackground(
        child: SafeArea(
          child: MultiProvider(
            providers: [
              ChangeNotifierProvider<TransactionsProvider>.value(
                value: transactionsProvider,
              ),
              ChangeNotifierProvider<BudgetsProvider>.value(
                value: budgetsProvider,
              ),
              ChangeNotifierProvider<GoalsProvider>.value(
                value: goalsProvider,
              ),
            ],
            child:
                Consumer3<TransactionsProvider, BudgetsProvider, GoalsProvider>(
              builder: (context, transactionsProvider, budgetsProvider,
                  goalsProvider, child) {
                return CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    // Enhanced App Bar with Greeting
                    SliverAppBar(
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                      floating: true,
                      pinned: true,
                      expandedHeight: 80,
                      title: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.waving_hand_rounded,
                              color: theme.colorScheme.primary,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'مرحباً بعودتك!',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                      actions: [
                        IconButton(
                          icon: const Icon(Icons.filter_list_rounded),
                          onPressed: _showFilterSheet,
                          tooltip: 'تصفية وترتيب',
                          style: IconButton.styleFrom(
                            backgroundColor:
                                theme.colorScheme.surface.withOpacity(0.5),
                            foregroundColor: theme.colorScheme.primary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.search_rounded),
                          onPressed: () {},
                          tooltip: 'بحث',
                          style: IconButton.styleFrom(
                            backgroundColor:
                                theme.colorScheme.surface.withOpacity(0.5),
                            foregroundColor: theme.colorScheme.primary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: Stack(
                            children: [
                              const Icon(Icons.notifications_outlined),
                              Positioned(
                                right: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(1.5),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.error,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  constraints: const BoxConstraints(
                                    minWidth: 12,
                                    minHeight: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          onPressed: () {},
                          tooltip: 'الإشعارات',
                        ),
                      ],
                    ),

                    // Main Content
                    SliverPadding(
                      padding: const EdgeInsets.all(16.0),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate([
                          // Balance Card
                          AnimatedBalanceCard(
                            balance: transactionsProvider.transactions
                                .fold<double>(0, (sum, t) {
                              return t.type == TransactionType.income
                                  ? sum + t.amount
                                  : sum - t.amount;
                            }),
                          ),
                          const SizedBox(height: 18),

                          // Quick Stats Section
                          const QuickStatsWidget(),
                          const SizedBox(height: 18),

                          // Daily Tips
                          const DailyTipsWidget(),
                          const SizedBox(height: 24),

                          // Quick Actions Section
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(
                                    right: 4.0, bottom: 12.0),
                                child: Text(
                                  'الإجراءات السريعة',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 130,
                                child: ListView(
                                  key: const Key('quick_actions_list'),
                                  scrollDirection: Axis.horizontal,
                                  physics: const BouncingScrollPhysics(),
                                  children: List.generate(
                                    4,
                                    (index) =>
                                        _buildQuickActionCard(index, theme),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // Financial Insights Section
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(
                                    right: 4.0, bottom: 12.0),
                                child: Text(
                                  'نظرة مالية سريعة',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 170,
                                child: ListView(
                                  scrollDirection: Axis.horizontal,
                                  physics: const BouncingScrollPhysics(),
                                  children: List.generate(
                                    3,
                                    (index) => _buildInsightCard(index, theme,
                                        transactionsProvider, budgetsProvider),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // Expense Summary Chart
                          ExpenseSummaryChart(
                              transactions: transactionsProvider.transactions),
                          const SizedBox(height: 24),

                          // Recent Transactions
                          RecentTransactionsWidget(),
                          const SizedBox(height: 24),

                          SizedBox(
                              height:
                                  MediaQuery.of(context).padding.bottom + 16),
                        ]),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

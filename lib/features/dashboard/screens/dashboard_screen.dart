import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:nabd/data/app_data.dart';
import 'package:nabd/features/dashboard/widgets/animated_balance_card.dart';
import 'package:nabd/features/dashboard/widgets/daily_tips_widget.dart';
import 'package:nabd/features/dashboard/widgets/recent_transactions_widget.dart';
import 'package:nabd/features/transactions/screens/add_transaction_screen.dart';
import 'package:nabd/features/budgets/screens/add_budget_screen.dart';
import 'package:nabd/features/goals/screens/add_goal_screen.dart';
import 'package:nabd/features/insights/screens/insights_hub_screen.dart';
import 'package:nabd/widgets/glass_background.dart';
import 'package:nabd/widgets/glass_card.dart';
import 'package:nabd/theme/app_colors.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  
  void _handleQuickAction(int index) {
    switch (index) {
      case 0: // Add Transaction
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => const AddTransactionScreen(),
        );
        break;
      case 1: // Add Budget
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => const AddBudgetScreen()),
        );
        break;
      case 2: // Add Goal
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => const AddGoalScreen()),
        );
        break;
      case 3: // Reports
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => const InsightsHubScreen()),
        );
        break;
    }
  }

  void _handleInsightTap(int index) {
    switch (index) {
      case 0: // Monthly Expenses
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const InsightsHubScreen(initialTab: 0),
          ),
        );
        break;
      case 1: // Monthly Income
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const InsightsHubScreen(initialTab: 1),
          ),
        );
        break;
      case 2: // Active Budgets
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => const AddBudgetScreen()),
        );
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

  Widget _buildInsightCard(int index, ThemeData theme, AppData appData) {
    final List<Map<String, dynamic>> insights = [
      {
        'title': 'المصروفات الشهرية',
        'value': appData.getMonthlyExpenses().toStringAsFixed(0),
        'icon': Icons.trending_down_rounded,
        'color': AppColors.expenseColor,
        'change': '-12%',
        'isPositive': false,
        'subtitle': 'مقارنة بالشهر الماضي',
        'currency': 'ر.س',
      },
      {
        'title': 'الدخل الشهري',
        'value': appData.getMonthlyIncome().toStringAsFixed(0),
        'icon': Icons.trending_up_rounded,
        'color': AppColors.incomeColor,
        'change': '+8%',
        'isPositive': true,
        'subtitle': 'مقارنة بالشهر الماضي',
        'currency': 'ر.س',
      },
      {
        'title': 'الميزانيات النشطة',
        'value': appData.activeBudgets.length.toString(),
        'icon': Icons.pie_chart_rounded,
        'color': AppColors.accentColor,
        'change': '3 متبقية',
        'isPositive': null,
        'subtitle': 'ميزانيات هذا الشهر',
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
                      Shimmer.fromColors(
                        baseColor: theme.colorScheme.primary,
                        highlightColor: insight['color'],
                        period: const Duration(seconds: 3),
                        child: Text(
                          insight['value'],
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
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
  late final AnimationController _animationController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeInOut),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutQuart,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      extendBodyBehindAppBar: true, // Allow content to extend behind app bar
      body: GlassBackground(
        child: SafeArea(
          child: Consumer<AppData>(
            builder: (context, appData, child) {
              return CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  // Enhanced App Bar with Greeting
                  SliverAppBar(
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    floating: true,
                    pinned: true,
                    expandedHeight:
                        80, // Taller app bar for better visual hierarchy
                    title: FadeTransition(
                      opacity: _fadeAnimation,
                      child: Row(
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
                    ),
                    actions: [
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
                        AnimatedBuilder(
                          animation: _slideAnimation,
                          builder: (context, child) {
                            return Transform.translate(
                              offset: _slideAnimation.value * 30,
                              child: child,
                            );
                          },
                          child: FadeTransition(
                            opacity: _fadeAnimation,
                            child: AnimatedBalanceCard(
                                balance: appData.currentBalance),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Level Indicator
                        AnimatedBuilder(
                          animation: _slideAnimation,
                          builder: (context, child) {
                            return Transform.translate(
                              offset: _slideAnimation.value * 20,
                              child: child,
                            );
                          },
                          child: // Daily Tips
                              FadeTransition(
                            opacity: _fadeAnimation,
                            child: const DailyTipsWidget(),
                          ),
                        ),
                        const SizedBox(height: 24),
                        
                        // Quick Actions Section
                        FadeTransition(
                          opacity: _fadeAnimation,
                          child: Column(
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
                                height:
                                    130, // Increased height to accommodate cards
                                child: AnimationLimiter(
                                  child: ListView(
                                    scrollDirection: Axis.horizontal,
                                    physics: const BouncingScrollPhysics(),
                                    children: List.generate(
                                      4,
                                      (index) =>
                                          AnimationConfiguration.staggeredList(
                                        position: index,
                                        duration:
                                            const Duration(milliseconds: 375),
                                        child: SlideAnimation(
                                          horizontalOffset: 50.0,
                                          child: FadeInAnimation(
                                            child: _buildQuickActionCard(
                                                index, theme),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Financial Insights Section
                        FadeTransition(
                          opacity: _fadeAnimation,
                          child: Column(
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
                                height:
                                    170, // Further increased height for Android compatibility
                                child: AnimationLimiter(
                                  child: ListView(
                                    scrollDirection: Axis.horizontal,
                                    physics: const BouncingScrollPhysics(),
                                    children: List.generate(
                                      3,
                                      (index) =>
                                          AnimationConfiguration.staggeredList(
                                        position: index,
                                        duration:
                                            const Duration(milliseconds: 375),
                                        child: SlideAnimation(
                                          horizontalOffset: 50.0,
                                          child: FadeInAnimation(
                                            child: _buildInsightCard(
                                                index, theme, appData),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        
                        // Recent Transactions
                        FadeTransition(
                          opacity: _fadeAnimation,
                          child: const RecentTransactionsWidget(),
                        ),
                        const SizedBox(height: 24),

                        SizedBox(
                            height: MediaQuery.of(context).padding.bottom + 16),
                      ]),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

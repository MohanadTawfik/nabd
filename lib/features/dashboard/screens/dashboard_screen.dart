import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nabd/theme/app_paddings.dart';
import 'package:nabd/theme/app_text_styles.dart';
import 'package:nabd/features/dashboard/widgets/animated_balance_card.dart';
import 'package:nabd/features/dashboard/widgets/quick_actions_widget.dart';
import 'package:nabd/features/dashboard/widgets/daily_tips_widget.dart';
import 'package:nabd/features/dashboard/widgets/budgets_card.dart';
import 'package:nabd/features/dashboard/widgets/level_indicator_widget.dart';
import 'package:nabd/features/dashboard/widgets/recent_transactions_widget.dart';
import 'package:nabd/data/app_data.dart';
import 'package:nabd/widgets/glass_background.dart';
import '../widgets/goals_section.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
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
      extendBodyBehindAppBar: false,
      body: GlassBackground(
        child: SafeArea(
          child: Consumer<AppData>(
            builder: (context, appData, child) {
              return CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  // App Bar with Greeting
                  SliverAppBar(
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    floating: true,
                    pinned: true,
                    title: FadeTransition(
                      opacity: _fadeAnimation,
                      child: Text(
                        'مرحباً بعودتك!',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ),
                    actions: [
                      IconButton(
                        icon: const Icon(Icons.search_rounded),
                        onPressed: () {},
                        tooltip: 'بحث',
                      ),
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
                        // Level Indicator
                        AnimatedBuilder(
                          animation: _slideAnimation,
                          builder: (context, child) {
                            return Transform.translate(
                              offset: _slideAnimation.value * 20,
                              child: child,
                            );
                          },
                          child: FadeTransition(
                            opacity: _fadeAnimation,
                            child: const LevelIndicatorWidget(),
                          ),
                        ),
                        const SizedBox(height: 24),

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

                        // Quick Actions
                        FadeTransition(
                          opacity: _fadeAnimation,
                          child: const QuickActionsWidget(),
                        ),
                        const SizedBox(height: 24),

                        // Goals Section
                        FadeTransition(
                          opacity: _fadeAnimation,
                          child: const GoalsSection(),
                        ),
                        const SizedBox(height: 24),

                        // Budgets Card
                        FadeTransition(
                          opacity: _fadeAnimation,
                          child: const BudgetsCard(),
                        ),
                        const SizedBox(height: 24),

                        // Recent Transactions
                        FadeTransition(
                          opacity: _fadeAnimation,
                          child: const RecentTransactionsWidget(),
                        ),
                        const SizedBox(height: 24),

                        // Daily Tips
                        FadeTransition(
                          opacity: _fadeAnimation,
                          child: const DailyTipsWidget(),
                        ),
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

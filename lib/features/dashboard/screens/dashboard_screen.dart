import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:nabd/theme/app_paddings.dart';
import 'package:nabd/theme/app_text_styles.dart';
import 'package:nabd/features/dashboard/widgets/animated_balance_card.dart';
import 'package:nabd/features/dashboard/widgets/quick_actions_widget.dart';
import 'package:nabd/features/dashboard/widgets/daily_tips_widget.dart';
import 'package:nabd/features/dashboard/widgets/budgets_card.dart';
import 'package:nabd/features/dashboard/widgets/level_indicator_widget.dart';
import 'package:nabd/features/dashboard/widgets/recent_transactions_widget.dart';
import 'package:provider/provider.dart';
import 'package:nabd/data/app_data.dart';
import '../widgets/goals_section.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: false,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'مرحباً بعودتك!',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            shadows: [
              const Shadow(
                color: Colors.black26,
                offset: Offset(0, 1),
                blurRadius: 2,
              ),
            ],
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: Consumer<AppData>(
        builder: (context, appData, child) {
          return ListView(
            padding: AppPaddings.allMedium.copyWith(
              bottom: MediaQuery.of(context).padding.bottom + 16,
            ),
            children: [
              LevelIndicatorWidget(),
              AppPaddings.largeHeight,
              AnimatedBalanceCard(balance: appData.currentBalance),
              AppPaddings.largeHeight,
              GoalsSection(),
              AppPaddings.largeHeight,
              QuickActionsWidget(),
              AppPaddings.largeHeight,
              DailyTipsWidget(),
              AppPaddings.largeHeight,
              RecentTransactionsWidget(),
              AppPaddings.largeHeight,
              BudgetsCard(),
            ],
          );
        },
      ),

      // body: SingleChildScrollView(
      //   padding: const EdgeInsets.all(16.0),
      //   child: Column(
      //     crossAxisAlignment: CrossAxisAlignment.start,
      //     children: const [
      //       // 2. إضافة مؤشر المستوى الجديد
      //       LevelIndicatorWidget(),
      //       SizedBox(height: 16),
      //       FinancialPulseWidget(),
      //       SizedBox(height: 24),
      //       InsightCard(),
      //       SizedBox(height: 24),
      //       // 2. إضافة بطاقة الميزانيات الجديدة إلى لوحة التحكم
      //       BudgetsCard(),
      //       SizedBox(height: 24),
      //       GoalsSection(),
      //       SizedBox(height: 24),
      //       ExpensesSection(),
      //     ],
      //   ),
      // ),
    );
  }
}

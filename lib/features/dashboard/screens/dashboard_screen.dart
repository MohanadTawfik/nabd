import 'package:flutter/material.dart';
import 'package:nabd/features/dashboard/widgets/balance_card_widget.dart';
import 'package:nabd/features/dashboard/widgets/budgets_card.dart';
import 'package:nabd/features/dashboard/widgets/expenses_section.dart';
import 'package:nabd/features/dashboard/widgets/level_indicator_widget.dart';
import 'package:nabd/features/dashboard/widgets/recent_transactions_widget.dart';
import '../widgets/financial_pulse_widget.dart';
import '../widgets/insight_card.dart';
import '../widgets/goals_section.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('مرحباً مهند!'),
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
      body: ListView(
        // استخدام ListView لضمان التمرير السلس
        padding: const EdgeInsets.all(16.0),
        children: const [
          BalanceCardWidget(),
          SizedBox(height: 24),
          RecentTransactionsWidget(),
        ],
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

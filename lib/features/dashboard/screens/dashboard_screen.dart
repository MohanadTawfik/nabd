import 'package:flutter/material.dart';
import 'package:nabd/features/dashboard/widgets/budgets_card.dart';
import 'package:nabd/features/dashboard/widgets/expenses_section.dart';
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
            icon: const Icon(Icons.notifications_none,
                size: 28, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            FinancialPulseWidget(),
            SizedBox(height: 24),
            InsightCard(),
            SizedBox(height: 24),
            // 2. إضافة بطاقة الميزانيات الجديدة إلى لوحة التحكم
            BudgetsCard(),
            SizedBox(height: 24),
            GoalsSection(),
            SizedBox(height: 24),
            ExpensesSection(),
          ],
        ),
      ),
    );
  }
}

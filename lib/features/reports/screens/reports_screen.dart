import 'package:flutter/material.dart';
import '../widgets/monthly_summary_card.dart';
import '../widgets/expenses_by_category_card.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('التقارير'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: const [
            MonthlySummaryCard(),
            SizedBox(height: 24),
            ExpensesByCategoryCard(),
          ],
        ),
      ),
    );
  }
}

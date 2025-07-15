import 'package:flutter/material.dart';
import 'package:nabd/data/app_data.dart';
import 'package:nabd/features/budgets/screens/add_budget_screen.dart';
import 'package:provider/provider.dart';

class BudgetsScreen extends StatelessWidget {
  const BudgetsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة الميزانيات'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            // 2. تفعيل الزر للانتقال لشاشة الإضافة
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const AddBudgetScreen()),
              );
            },
          ),
        ],
      ),
      body: Consumer<AppData>(
        builder: (context, appData, child) {
          final budgets = appData.budgets;
          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: budgets.length,
            itemBuilder: (context, index) {
              final budget = budgets[index];
              final progress = budget.totalAmount > 0
                  ? (budget.spentAmount / budget.totalAmount).clamp(0.0, 1.0)
                  : 0.0;
              final color = progress < 0.5
                  ? Colors.green
                  : (progress < 0.9 ? Colors.orange : Colors.red);

              return Card(
                color: const Color(0xff161b22),
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(budget.icon, color: color, size: 28),
                          const SizedBox(width: 12),
                          Text(budget.categoryName,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      LinearProgressIndicator(
                        value: progress,
                        backgroundColor: color.withOpacity(0.2),
                        valueColor: AlwaysStoppedAnimation<Color>(color),
                        minHeight: 12,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                              'تم صرف: ${budget.spentAmount.toStringAsFixed(0)}',
                              style: const TextStyle(color: Colors.white70)),
                          Text(
                              'المتبقي: ${(budget.totalAmount - budget.spentAmount).toStringAsFixed(0)}',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold)),
                        ],
                      )
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

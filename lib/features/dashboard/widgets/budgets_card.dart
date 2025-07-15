import 'package:flutter/material.dart';
import 'package:nabd/data/app_data.dart';
import 'package:nabd/features/budgets/screens/budgets_screen.dart';
import 'package:provider/provider.dart'; // سيتم إنشاؤه لاحقاً

class BudgetsCard extends StatelessWidget {
  const BudgetsCard({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. استخدام Consumer للاستماع للبيانات الحية
    return Consumer<AppData>(
      builder: (context, appData, child) {
        // عرض أول ميزانيتين فقط في لوحة التحكم
        final budgetsToShow = appData.budgets.take(2).toList();

        if (budgetsToShow.isEmpty) {
          return const SizedBox
              .shrink(); // لا تعرض شيئاً إذا لم تكن هناك ميزانيات
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('درع الميزانية',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold)),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const BudgetsScreen()),
                    );
                  },
                  child: const Text('إدارة',
                      style: TextStyle(color: Color(0xff8952ff))),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Card(
              color: const Color(0xff161b22),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: budgetsToShow.map((budget) {
                    final progress = budget.totalAmount > 0
                        ? (budget.spentAmount / budget.totalAmount)
                            .clamp(0.0, 1.0)
                        : 0.0;
                    return _buildBudgetIndicator(
                      context: context,
                      name: budget.categoryName,
                      progress: progress,
                      spent: budget.spentAmount,
                      total: budget.totalAmount,
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildBudgetIndicator({
    required BuildContext context,
    required String name,
    required double progress,
    required double spent,
    required double total,
  }) {
    final color = progress < 0.5
        ? Colors.green
        : (progress < 0.9 ? Colors.orange : Colors.red);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(name,
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
              Text('${spent.toStringAsFixed(0)} / ${total.toStringAsFixed(0)}',
                  style: const TextStyle(color: Colors.white70)),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: color.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 10,
            borderRadius: BorderRadius.circular(5),
          ),
        ],
      ),
    );
  }
}

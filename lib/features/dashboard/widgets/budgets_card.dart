import 'package:flutter/material.dart';
import 'package:nabd/features/categories/models/category_model.dart';
import 'package:nabd/theme/app_paddings.dart';
import 'package:nabd/theme/app_text_styles.dart';
import 'package:nabd/theme/app_colors.dart';
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
                Text('درع الميزانية',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface)),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const BudgetsScreen()),
                    );
                  },
                  child: Text('إدارة',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: Theme.of(context).colorScheme.primary)),
                ),
              ],
            ),
            AppPaddings.smallHeight,
            Card(
              elevation: 4,
              shadowColor:
                  Theme.of(context).colorScheme.shadow.withOpacity(0.1),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              color: Theme.of(context).colorScheme.surface,
              child: Padding(
                padding: AppPaddings.allMedium,
                child: Column(
                  children: budgetsToShow.map((budget) {
                    final progress = budget.totalAmount > 0
                        ? (budget.spentAmount / budget.totalAmount)
                            .clamp(0.0, 1.0)
                        : 0.0;
                    return _buildBudgetIndicator(
                      context: context,
                      name: budget.category?.name ?? 'اليزانية العامة',
                      progress: progress,
                      spent: budget.spentAmount,
                      total: budget.totalAmount,
                      category: budget.category,
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
    Category? category,
  }) {
    final color = progress < 0.5
        ? Colors.green
        : (progress < 0.9 ? Colors.orange : Colors.red);
    return Padding(
      padding: AppPaddings.verticalSmall,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface)),
              Text('${spent.toStringAsFixed(0)} / ${total.toStringAsFixed(0)}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant)),
            ],
          ),
          AppPaddings.smallHeight,
          LinearProgressIndicator(
            value: progress,
            backgroundColor:
                Theme.of(context).colorScheme.primary.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).colorScheme.primary),
            minHeight: 10,
            borderRadius: BorderRadius.circular(5),
          ),
        ],
      ),
    );
  }
}

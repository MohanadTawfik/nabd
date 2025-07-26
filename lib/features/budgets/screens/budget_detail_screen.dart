import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nabd/data/app_data.dart';
import 'package:nabd/features/budgets/models/budget_model.dart';
import 'package:nabd/features/budgets/screens/add_budget_screen.dart';
import 'package:provider/provider.dart';

class BudgetDetailScreen extends StatelessWidget {
  final Budget budget;
  
  const BudgetDetailScreen({
    super.key,
    required this.budget,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final progress = budget.totalAmount > 0 ? budget.spentAmount / budget.totalAmount : 0.0;
    final remaining = budget.totalAmount - budget.spentAmount;
    final remainingDays = budget.endDate.difference(DateTime.now()).inDays;
    
    final color = progress < 0.5
        ? Colors.green
        : (progress < 0.9 ? Colors.orange : Colors.red);

    return Scaffold(
      appBar: AppBar(
        title: const Text('تفاصيل الميزانية'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Budget Header
            Card(
              color: isDark ? const Color(0xff1e293b) : Colors.white,
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(budget.category.icon, color: color, size: 32),
                        const SizedBox(width: 16),
                        Text(
                          budget.category.name,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
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
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${(progress * 100).toStringAsFixed(1)}%',
                          style: theme.textTheme.bodySmall,
                        ),
                        Text(
                          '${budget.spentAmount.toStringAsFixed(0)} / ${budget.totalAmount.toStringAsFixed(0)}',
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Budget Details
            Text(
              'تفاصيل الميزانية',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildDetailItem(
              context: context,
              title: 'الميزانية الكلية',
              value: '${budget.totalAmount.toStringAsFixed(0)} ريال',
              icon: Icons.account_balance_wallet_outlined,
            ),
            _buildDetailItem(
              context: context,
              title: 'المصروف',
              value: '${budget.spentAmount.toStringAsFixed(0)} ريال',
              icon: Icons.shopping_cart_outlined,
            ),
            _buildDetailItem(
              context: context,
              title: 'المتبقي',
              value: '${remaining.toStringAsFixed(0)} ريال',
              icon: Icons.account_balance_wallet,
              isAmount: true,
              amountColor: remaining >= 0 ? Colors.green : Colors.red,
            ),
            _buildDetailItem(
              context: context,
              title: 'الفترة',
              value: _getPeriodText(budget.period),
              icon: Icons.calendar_today_outlined,
            ),
            _buildDetailItem(
              context: context,
              title: 'تاريخ البداية',
              value: DateFormat('yyyy/MM/dd').format(budget.startDate),
              icon: Icons.date_range_outlined,
            ),
            _buildDetailItem(
              context: context,
              title: 'تاريخ النهاية',
              value: DateFormat('yyyy/MM/dd').format(budget.endDate),
              icon: Icons.date_range,
            ),
            if (remainingDays >= 0) ...[
              _buildDetailItem(
                context: context,
                title: 'الأيام المتبقية',
                value: '$remainingDays يوم',
                icon: Icons.timer_outlined,
              ),
            ],
            
            const SizedBox(height: 32),
            
            // Actions
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  // TODO: Implement edit budget
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AddBudgetScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.edit),
                label: const Text('تعديل الميزانية'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  _showDeleteConfirmation(context);
                },
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                label: const Text(
                  'حذف الميزانية',
                  style: TextStyle(color: Colors.red),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  side: const BorderSide(color: Colors.red),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildDetailItem({
    required BuildContext context,
    required String title,
    required String value,
    required IconData icon,
    bool isAmount = false,
    Color? amountColor,
  }) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: theme.hintColor),
          const SizedBox(width: 16),
          Text(
            title,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.hintColor,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: isAmount ? FontWeight.bold : FontWeight.normal,
              color: amountColor ?? theme.textTheme.bodyLarge?.color,
            ),
          ),
        ],
      ),
    );
  }
  
  String _getPeriodText(BudgetPeriod period) {
    switch (period) {
      case BudgetPeriod.weekly:
        return 'أسبوعي';
      case BudgetPeriod.monthly:
        return 'شهري';
      case BudgetPeriod.yearly:
        return 'سنوي';
      case BudgetPeriod.custom:
        return 'مخصص';
    }
  }
  
  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف الميزانية'),
        content: const Text('هل أنت متأكد من رغبتك في حذف هذه الميزانية؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              final appData = Provider.of<AppData>(context, listen: false);
              appData.deleteBudget(budget);
              Navigator.popUntil(context, (route) => route.isFirst);
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }
}

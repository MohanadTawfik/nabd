import 'package:nabd/features/budgets/budgets_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nabd/features/budgets/models/budget_model.dart';
import 'package:nabd/features/budgets/screens/add_budget_screen.dart';
import 'package:nabd/widgets/glass_background.dart';
import 'package:nabd/widgets/glass_card.dart';
import 'package:provider/provider.dart';

class BudgetDetailScreen extends StatelessWidget {
  final String budgetId;

  const BudgetDetailScreen({
    super.key,
    required this.budgetId,
  });

  // --- دوال مساعدة ---

  // دالة تنسيق العملة
  String _formatCurrency(num amount) {
    return NumberFormat.currency(
      locale: 'ar',
      symbol: '﷼',
      decimalDigits: 0,
    ).format(amount);
  }

  // دالة تحديد حالة الميزانية
  (String, Color) _getBudgetStatus(
      Budget budget, double progress, ThemeData theme) {
    final now = DateTime.now();
    final startDate = budget.startDate;
    final endDate = budget.endDate;
    if (now.isBefore(startDate)) {
      return ('لم تبدأ بعد', Colors.blueGrey);
    }
    if (progress > 1) {
      return ('تم التجاوز', theme.colorScheme.error);
    }
    if (now.isAfter(endDate)) {
      return ('منتهية', Colors.grey.shade700);
    }
    int totalDuration = endDate.difference(startDate).inDays;
    if (totalDuration == 0) totalDuration = 1;
    int daysPassed = now.difference(startDate).inDays;
    double idealProgress = daysPassed / totalDuration;
    if (progress > (idealProgress * 1.25)) {
      return ('تحت الضغط', Colors.orange.shade700);
    }
    return ('على المسار', Colors.green.shade600);
  }

  // --- دوال عرض مربعات الحوار ---

  void _showDeleteConfirmation(BuildContext context, Budget budget) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('حذف الميزانية'),
        content: const Text('هل أنت متأكد؟ لا يمكن التراجع عن هذا الإجراء.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () async {
              final budgetsProvider =
                  Provider.of<BudgetsProvider>(context, listen: false);
              await budgetsProvider.deleteBudget(budget.id);
              Navigator.of(dialogCtx).pop(); // إغلاق مربع الحوار
              Navigator.of(context).pop(); // العودة من شاشة التفاصيل
            },
            style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.error),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }

  void _navigateToEditScreen(BuildContext context, Budget budget) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddBudgetScreen(budget: budget),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final budgetsProvider = Provider.of<BudgetsProvider>(context);
    final budget = budgetsProvider.budgets.firstWhere(
      (b) => b.id == budgetId,
      orElse: () => Budget(id: budgetId, totalAmount: 0, spentAmount: 0),
    );

    final progress =
        budget.totalAmount > 0 ? budget.spentAmount / budget.totalAmount : 0.0;
    final remaining = budget.totalAmount - budget.spentAmount;
    final (statusText, statusColor) = _getBudgetStatus(budget, progress, theme);
    final categoryColor = budget.category?.color ?? statusColor;

    int remainingDays = 0;
    if (DateTime.now().isBefore(budget.endDate)) {
      remainingDays = budget.endDate.difference(DateTime.now()).inDays + 1;
    }
    final dailyAvg =
        (remaining > 0 && remainingDays > 0) ? remaining / remainingDays : 0.0;

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('تفاصيل الميزانية'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => _navigateToEditScreen(context, budget),
            tooltip: 'تعديل',
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _showDeleteConfirmation(context, budget),
            tooltip: 'حذف',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: GlassBackground(
        child: Column(
          children: [
            // Spacer for AppBar under GlassBackground.SafeArea
            SizedBox(
              height: AppBar().preferredSize.height *
                      0.5 + // مثلاً 50% من ارتفاع AppBar
                  MediaQuery.of(context).padding.top *
                      0.5, // مثلاً 70% من padding الأعلى
            ),
            // --- بطاقة العرض الرئيسية ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: GlassCard(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 100,
                        height: 100,
                        child: Stack(
                          fit: StackFit.expand,
                          alignment: Alignment.center,
                          children: [
                            CircularProgressIndicator(
                                value: 1,
                                strokeWidth: 9,
                                color: categoryColor.withOpacity(0.2)),
                            CircularProgressIndicator(
                                value: progress,
                                strokeWidth: 9,
                                color: categoryColor,
                                strokeCap: StrokeCap.round),
                            Center(
                              child: Icon(budget.category?.icon ?? Icons.wallet,
                                  color: categoryColor, size: 40),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(budget.displayName,
                                style: theme.textTheme.headlineSmall
                                    ?.copyWith(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            Text('المتبقي: ${_formatCurrency(remaining)}',
                                style: theme.textTheme.titleMedium),
                            Text(
                                'المصروف: ${_formatCurrency(budget.spentAmount)}',
                                style: theme.textTheme.bodyMedium),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // --- قائمة التفاصيل ---
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  children: [
                    _buildDetailRow(
                        theme, Icons.info_outline, budget.displayName, 'الحالة',
                        valueWidget: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                              color: statusColor,
                              borderRadius: BorderRadius.circular(8)),
                          child: Text(statusText,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold)),
                        )),
                    _buildDetailRow(
                        theme,
                        Icons.account_balance_wallet_outlined,
                        'مبلغ الميزانية',
                        _formatCurrency(budget.totalAmount)),
                    _buildDetailRow(
                        theme,
                        Icons.show_chart_rounded,
                        'نسبة الصرف',
                        '${(progress * 100).toStringAsFixed(1)}%'),
                    if (dailyAvg > 0)
                      _buildDetailRow(theme, Icons.commit_rounded,
                          'متوسط الصرف اليومي', _formatCurrency(dailyAvg)),
                    _buildDetailRow(
                        theme,
                        Icons.date_range_outlined,
                        'تاريخ البداية',
                        DateFormat('d MMMM yyyy', 'ar')
                            .format(budget.startDate)),
                    _buildDetailRow(theme, Icons.flag_outlined, 'تاريخ النهاية',
                        DateFormat('d MMMM yyyy', 'ar').format(budget.endDate)),
                    if (remainingDays > 0)
                      _buildDetailRow(theme, Icons.hourglass_bottom_rounded,
                          'الأيام المتبقية', '$remainingDays يوم'),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  // دالة مساعدة لبناء صف التفاصيل بشكل أنيق
  Widget _buildDetailRow(
      ThemeData theme, IconData icon, String label, String? value,
      {Widget? valueWidget}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        children: [
          Icon(icon,
              size: 22, color: theme.colorScheme.onSurface.withOpacity(0.6)),
          const SizedBox(width: 16),
          Text(label, style: theme.textTheme.bodyLarge),
          const Spacer(),
          if (valueWidget != null)
            valueWidget
          else
            Text(value ?? '',
                style: theme.textTheme.bodyLarge
                    ?.copyWith(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nabd/widgets/glass_background.dart';
import 'package:provider/provider.dart';
import 'package:nabd/data/app_data.dart';
import 'package:nabd/features/transactions/models/transaction_model.dart';
import 'package:nabd/features/transactions/screens/add_transaction_screen.dart';
import 'package:nabd/theme/app_colors.dart';
import 'package:nabd/widgets/glass_card.dart';

class TransactionDetailScreen extends StatelessWidget {
  final Transaction transaction;
  const TransactionDetailScreen({
    super.key,
    required this.transaction,
  });

  @override
  Widget build(BuildContext context) {
    final isExpense = transaction.type == TransactionType.expense;
    // استخدام AppColors المحددة للدخل والمصروفات
    final transactionColor =
        isExpense ? AppColors.expenseColor : AppColors.incomeColor;
    final amountFormat = NumberFormat('#,##0', 'en_US');
    final dateFormat = DateFormat('EEEE, d MMMM yyyy', 'ar');
    final timeFormat = DateFormat('hh:mm a', 'ar');
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(
          'تفاصيل ${transaction.type == TransactionType.expense ? 'المصروف' : 'الدخل'}',
          style: theme.textTheme.displaySmall?.copyWith(
            // استخدام displaySmall
            color: theme.colorScheme.onSurface, // لون يتناسق مع الثيم
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: Icon(Icons.arrow_back,
              color: theme.colorScheme.onSurface), // لون متناسق
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.edit,
                color: theme.colorScheme.primary), // لون primary
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      AddTransactionScreen(transactionToEdit: transaction),
                ),
              );
            },
            tooltip: 'تعديل',
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: Icon(Icons.delete_outline,
                color: theme.colorScheme.error), // لون error
            onPressed: () => _showDeleteConfirmation(context),
            tooltip: 'حذف',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: GlassBackground(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Spacer for AppBar under GlassBackground.SafeArea
            SizedBox(
              height: AppBar().preferredSize.height *
                      0.5 + // مثلاً 50% من ارتفاع AppBar
                  MediaQuery.of(context).padding.top *
                      0.5, // مثلاً 70% من padding الأعلى
            ),

            // Amount card
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16.0, vertical: 8), // Padding لهذا الجزء
              child: GlassCard(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      Text(
                        isExpense ? 'مصروف' : 'دخل',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          // استخدام bodyLarge
                          color: theme.textTheme.bodyMedium?.color
                              ?.withOpacity(0.7),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        ' ${amountFormat.format(transaction.amount)}',
                        style: theme.textTheme.displayLarge?.copyWith(
                          // استخدام displayLarge
                          color: transactionColor, // لون المعاملة
                          fontWeight: FontWeight.bold,
                          // fontSize: 40, (تم إزالة الحجم الثابت والاعتماد على displayLarge)
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '﷼',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.textTheme.bodyMedium?.color
                              ?.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // const SizedBox(height: 24),

            // Transaction details card
            Expanded(
              // هذا هو المفتاح: Expanded يجعل هذا الجزء يأخذ المساحة المتبقية
              child: SingleChildScrollView(
                // لضمان التمرير إذا كانت التفاصيل كثيرة
                padding: const EdgeInsets.symmetric(
                    horizontal: 16.0, vertical: 8), // Padding لهذا الجزء
                child: Container(
                  // وضع تفاصيل المعاملة داخل GlassCard خاصة بها
                  padding: EdgeInsets.zero, // لتجنب تكرار المسافة الداخلية
                  child: Column(
                    // Column التي تحتوي على تفاصيل المعاملة
                    children: [
                      _buildDetailRow(
                        context,
                        icon: Icons.category,
                        title: 'الفئة',
                        value: transaction.category.name,
                        iconColor: transactionColor,
                        iconBackground: transactionColor.withOpacity(0.15),
                      ),
                      _buildDivider(context),
                      _buildDetailRow(
                        context,
                        icon: Icons.calendar_today,
                        title: 'التاريخ',
                        value: dateFormat.format(transaction.date),
                      ),
                      _buildDivider(context),
                      _buildDetailRow(
                        context,
                        icon: Icons.access_time,
                        title: 'الوقت',
                        value: timeFormat.format(transaction.date),
                      ),
                      if (transaction.notes?.isNotEmpty ?? false) ...[
                        _buildDivider(context),
                        _buildDetailRow(
                          context,
                          icon: Icons.notes,
                          title: 'ملاحظات',
                          value: transaction.notes!,
                          maxLines: 3,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            // إذا كان هناك زر حذف في الأسفل، يمكن وضعه هنا خارج الـ Expanded
            // const SizedBox(height: 16), // مسافة قبل الزر
            // ElevatedButton.icon(...) // زر الحذف هنا
          ],
        ),
      ),
    );
  }
  // const SizedBox(height: 24),

  // // Delete button
  // ElevatedButton.icon(
  //   onPressed: () => _showDeleteConfirmation(context),
  //   style: ElevatedButton.styleFrom(
  //     backgroundColor:
  //         theme.colorScheme.error.withValues(alpha: 0.1),
  //     foregroundColor: theme.colorScheme.error,
  //     elevation: 0,
  //     padding: const EdgeInsets.symmetric(vertical: 16),
  //     shape: RoundedRectangleBorder(
  //       borderRadius: BorderRadius.circular(12),
  //     ),
  //   ),
  //   icon: const Icon(Icons.delete_outline),
  //   label: const Text('حذف المعاملة',
  //       style: TextStyle(fontWeight: FontWeight.bold)),
  // ),

  // Widget _buildDivider() {
  //   return const Divider(height: 1, thickness: 1, indent: 16, endIndent: 16);
  // }

  Widget _buildDivider(BuildContext context) {
    // استلام context
    final theme = Theme.of(context);
    return Divider(
      height: 1,
      thickness: 0.5, // تخفيض سمك الخط
      indent: 16,
      endIndent: 16,
      color: theme.dividerColor, // استخدام لون الـ Divider من الثيم
    );
  }

  Widget _buildDetailRow(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
    Color? iconColor,
    Color? iconBackground,
    int maxLines = 1,
  }) {
    final theme = Theme.of(context);
    final defaultIconColor = theme.iconTheme.color;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: iconBackground ??
                  defaultIconColor?.withOpacity(0.1) ??
                  Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor ?? defaultIconColor, size: 25),
          ),

          const SizedBox(width: 16),

          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    // استخدام bodyLarge
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface
                        .withOpacity(0.8), // لون أوضح
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    // استخدام bodyMedium
                    fontWeight:
                        FontWeight.normal, // ليكون أقل بروزاً من العنوان
                    color: theme.colorScheme.onSurface
                        .withOpacity(0.7), // لون ثانوي
                  ),
                  maxLines: maxLines,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    final transaction = this.transaction;
    final theme = Theme.of(context); // الحصول على الثيم هنا
    showDialog(
      context: context,
      builder: (dialogCtx) {
        return AlertDialog(
          // ضبط ألوان وحجم الخطوط في AlertDialog
          backgroundColor: theme.colorScheme.surface, // خلفية من الثيم
          surfaceTintColor: Colors.transparent, // لمنع التأثيرات الإضافية
          title: Text('حذف المعاملة',
              style: theme.textTheme.headlineSmall
                  ?.copyWith(fontWeight: FontWeight.bold)),
          content: Text(
            'هل أنت متأكد من حذف هذه المعاملة؟ لا يمكن التراجع عن هذا الإجراء.',
            textAlign: TextAlign.right,
            style: theme.textTheme.bodyMedium
                ?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.8)),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogCtx).pop(),
              child: Text('إلغاء',
                  style: theme.textTheme.labelLarge?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7))),
            ),
            TextButton(
              onPressed: () {
                Provider.of<AppData>(context, listen: false)
                    .deleteTransaction(transaction);
                Navigator.of(dialogCtx).pop();
                Navigator.of(context).pop();
              },
              style: TextButton.styleFrom(
                foregroundColor: theme.colorScheme.error,
              ),
              child: Text('حذف',
                  style: theme.textTheme.labelLarge
                      ?.copyWith(fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }
}

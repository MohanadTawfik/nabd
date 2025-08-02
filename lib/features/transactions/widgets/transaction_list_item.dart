// transaction_list_item.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nabd/features/transactions/transactions_provider.dart';
import 'package:nabd/features/transactions/models/transaction_model.dart';
import 'package:nabd/widgets/confirmation_dialog.dart';
import 'package:nabd/widgets/glass_card.dart';
import 'package:provider/provider.dart';
import 'package:nabd/theme/app_colors.dart'; // إضافة استيراد AppColors

class TransactionListItem extends StatelessWidget {
  final Transaction transaction;

  const TransactionListItem({
    super.key,
    required this.transaction,
  });

  @override
  Widget build(BuildContext context) {
    final isExpense = transaction.type == TransactionType.expense;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // استخدام ألوان الثيم المحددة للدخل والمصروفات
    final itemColor =
        isExpense ? AppColors.expenseColor : AppColors.incomeColor;
    final format = NumberFormat("#,##0", "en_US");

    return GestureDetector(
      onLongPress: () {
        showDialog(
          context: context,
          builder: (BuildContext dialogContext) {
            return ConfirmationDialog(
              title: 'حذف المعاملة',
              content:
                  'هل أنت متأكد من رغبتك في حذف هذه المعاملة؟ لا يمكن التراجع عن هذا الإجراء.',
              onConfirm: () async {
                await Provider.of<TransactionsProvider>(context, listen: false)
                    .deleteTransaction(transaction.id);
                Navigator.of(dialogContext).pop();
              },
            );
          },
        );
      },
      child: GlassCard(
        // يمكن تعديل الشفافية أو قوة التمويه لكل بطاقة إذا لزم الأمر
        // opacity: isDark ? 0.25 : 0.15,
        // blurStrength: 8.0,
        child: Row(
          children: [
            // أيقونة الفئة
            // Container(
            //   width: 45,
            //   height: 45,
            //   decoration: BoxDecoration(
            //     color: transaction.category.color
            //         .withOpacity(0.15), // شفافية خفيفة للون الخلفية
            //     borderRadius: BorderRadius.circular(8),
            //   ),
            //   child: Icon(
            //     transaction.category.icon,
            //     color: transaction.category.color, // لون الأيقونة
            //     size: 25,
            //   ),
            // ),

            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: transaction.category.color.withOpacity(0.1),
                shape: BoxShape.rectangle,
                border: Border.all(
                  color: transaction.category.color.withOpacity(0.3),
                  width: 1.5,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                transaction.category.icon,
                color: transaction.category.color,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),

            // اسم الفئة + الوقت
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transaction.category.name,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      // استخدام headlineSmall
                      fontWeight: FontWeight.bold,
                      color: isDark
                          ? AppColors.textDark
                          : AppColors.textPrimary, // لون النص
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('hh:mm a', 'ar').format(transaction.date),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      // استخدام bodyMedium
                      color: isDark
                          ? AppColors.subtextDark
                          : AppColors.textSecondary, // لون نص ثانوي
                    ),
                  ),
                ],
              ),
            ),

            // المبلغ
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: itemColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: // المبلغ
                  Text(
                "${isExpense ? '-' : '+'}${format.format(transaction.amount)} ﷼",
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: itemColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// transaction_list_item.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nabd/data/app_data.dart';
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
              onConfirm: () {
                Provider.of<AppData>(context, listen: false)
                    .deleteTransaction(transaction);
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
            Container(
              width: 45,
              height: 45,
              decoration: BoxDecoration(
                color: itemColor.withOpacity(0.15), // شفافية خفيفة للون الخلفية
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                transaction.category.icon,
                color: itemColor, // لون الأيقونة
                size: 25,
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
            Text(
              "${isExpense ? '-' : '+'}${format.format(transaction.amount)} ﷼",
              style: theme.textTheme.headlineSmall?.copyWith(
                // استخدام headlineSmall
                fontWeight: FontWeight.bold,
                color: itemColor, // لون المبلغ (أحمر/أخضر)
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nabd/data/app_data.dart';
import 'package:nabd/features/transactions/models/transaction_model.dart';
import 'package:nabd/widgets/confirmation_dialog.dart';
import 'package:nabd/widgets/glass_card.dart';
import 'package:provider/provider.dart';

class TransactionListItem extends StatelessWidget {
  final Transaction transaction;

  const TransactionListItem({
    super.key,
    required this.transaction,
  });

  @override
  Widget build(BuildContext context) {
    final isExpense = transaction.type == TransactionType.expense;
    final color = isExpense ? Colors.redAccent : Colors.greenAccent;
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
        child: Row(
          children: [
            // أيقونة الفئة
            Container(
              width: 45,
              height: 45,
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                transaction.category.icon,
                color: color,
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
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('hh:mm a', 'ar').format(transaction.date),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),

            // المبلغ
            Text(
              "${isExpense ? '-' : '+'}${format.format(transaction.amount)} ﷼",
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

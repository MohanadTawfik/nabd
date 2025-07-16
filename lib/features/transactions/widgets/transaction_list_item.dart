import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nabd/data/app_data.dart';
import 'package:nabd/features/transactions/models/transaction_model.dart';
import 'package:nabd/widgets/confirmation_dialog.dart';
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
    final color = isExpense ? Colors.red.shade400 : Colors.green.shade400;
    final format = NumberFormat("#,##0", "en_US");

    // 2. نغلف البطاقة بـ GestureDetector للاستجابة للضغط المطول
    return GestureDetector(
      onLongPress: () {
        // 3. إظهار نافذة التأكيد عند الضغط المطول
        showDialog(
          context: context,
          builder: (BuildContext dialogContext) {
            return ConfirmationDialog(
              title: 'حذف المعاملة',
              content:
                  'هل أنت متأكد من رغبتك في حذف هذه المعاملة؟ لا يمكن التراجع عن هذا الإجراء.',
              onConfirm: () {
                // 4. استدعاء دالة الحذف من AppData
                Provider.of<AppData>(context, listen: false)
                    .deleteTransaction(transaction);
                Navigator.of(dialogContext).pop(); // إغلاق نافذة التأكيد
              },
            );
          },
        );
      },
      child: Card(
        // 1. استخدام لون البطاقة من الثيم
        color: Theme.of(context).cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: color.withOpacity(0.15),
            child: Icon(transaction.category.icon, color: color),
          ),
          title: Text(transaction.category.name,
              style: Theme.of(context).textTheme.titleMedium),
          subtitle: Text(DateFormat('hh:mm a', 'ar').format(transaction.date),
              style: Theme.of(context).textTheme.bodyMedium),
        ),
      ),
    );
  }
}

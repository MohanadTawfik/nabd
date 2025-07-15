import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nabd/features/transactions/models/transaction_model.dart';

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

    return Card(
      color: const Color(0xff161b22),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.15),
          child: Icon(transaction.icon, color: color),
        ),
        title: Text(transaction.category,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold)),
        subtitle: Text(DateFormat('hh:mm a', 'ar').format(transaction.date),
            style: const TextStyle(color: Colors.white70)),
        trailing: Text(
          '${isExpense ? '-' : '+'}${format.format(transaction.amount)}',
          style: TextStyle(
              color: color, fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

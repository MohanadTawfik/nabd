import 'package:flutter/material.dart';
import 'package:nabd/data/app_data.dart';
import 'package:nabd/features/transactions/models/transaction_model.dart';
import 'package:nabd/theme/app_themes.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class RecentTransactionsWidget extends StatelessWidget {
  const RecentTransactionsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppData>(
      builder: (context, appData, child) {
        final recentTransactions = appData.transactions.take(4).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('آخر المعاملات',
                    style: Theme.of(context).textTheme.titleMedium),
                TextButton(
                  onPressed: () {
                    // الانتقال لشاشة سجل المعاملات
                  },
                  child: Text('عرض الكل',
                      style: TextStyle(color: Theme.of(context).primaryColor)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Card(
              color: Theme.of(context).cardColor,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              child: Column(
                children: List.generate(recentTransactions.length, (index) {
                  final transaction = recentTransactions[index];
                  return _buildTransactionTile(context, transaction,
                      index == recentTransactions.length - 1);
                }),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTransactionTile(
      BuildContext context, Transaction transaction, bool isLast) {
    final isExpense = transaction.type == TransactionType.expense;
    final color = isExpense ? AppThemes.expenseColor : AppThemes.incomeColor;
    final format = NumberFormat.currency(locale: 'ar', symbol: '');

    return Column(
      children: [
        ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: CircleAvatar(
            backgroundColor: transaction.category.color.withOpacity(0.1),
            child: Icon(transaction.category.icon,
                color: transaction.category.color, size: 20),
          ),
          title: Text(transaction.category.name,
              style: Theme.of(context).textTheme.titleSmall),
          subtitle: Text(DateFormat.yMMMd('ar').format(transaction.date),
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(fontSize: 12)),
          trailing: Text(
            '${isExpense ? '-' : '+'}${format.format(transaction.amount)} ريال',
            style: TextStyle(
                color: color,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                fontFamily: 'Tajawal'),
          ),
        ),
        if (!isLast)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Divider(
                height: 1,
                color: Theme.of(context).dividerColor.withOpacity(0.5)),
          ),
      ],
    );
  }
}

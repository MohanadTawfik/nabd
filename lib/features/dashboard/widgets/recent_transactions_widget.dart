import 'package:flutter/material.dart';
import 'package:nabd/theme/app_colors.dart';
import 'package:nabd/theme/app_paddings.dart';
import 'package:nabd/data/app_data.dart';
import 'package:nabd/features/transactions/models/transaction_model.dart';
import 'package:nabd/features/transactions/screens/transactions_screen.dart';
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
                Text(
                  'آخر المعاملات',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const TransactionsScreen(),
                      ),
                    );
                  },
                  child: Text(
                    'عرض الكل',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                  ),
                ),
              ],
            ),
            AppPaddings.smallHeight,
            if (recentTransactions.isEmpty)
              Card(
                color: Theme.of(context).colorScheme.surface,
                elevation: 4,
                shadowColor: Theme.of(context).colorScheme.shadow,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: AppPaddings.allLarge,
                  child: Center(
                    child: Text(
                      'لا توجد معاملات لعرضها بعد',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ),
                ),
              )
            else
              Card(
                color: Theme.of(context).colorScheme.surface,
                elevation: 4,
                shadowColor: Theme.of(context).colorScheme.shadow,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
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
    final color = isExpense ? AppColors.expenseColor : AppColors.incomeColor;
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
          title: Text(
            transaction.category.name,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
          ),
          subtitle: Text(
            DateFormat.yMMMd('ar').format(transaction.date),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          trailing: Text(
            '${isExpense ? '-' : '+'}${format.format(transaction.amount)} ريال',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
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

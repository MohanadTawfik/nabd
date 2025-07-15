import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nabd/data/app_data.dart';
import 'package:nabd/features/transactions/widgets/transaction_list_item.dart';
import 'package:provider/provider.dart';

class TransactionsScreen extends StatelessWidget {
  const TransactionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('سجل المعاملات'),
      ),
      body: Consumer<AppData>(
        builder: (context, appData, child) {
          final transactions = appData.transactions;
          // ترتيب المعاملات من الأحدث إلى الأقدم
          transactions.sort((a, b) => b.date.compareTo(a.date));

          if (transactions.isEmpty) {
            return const Center(
              child: Text('لا توجد معاملات لعرضها',
                  style: TextStyle(color: Colors.white70, fontSize: 16)),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: transactions.length,
            itemBuilder: (context, index) {
              final transaction = transactions[index];
              // منطق لإضافة عنوان التاريخ عند بداية كل يوم جديد
              bool showDateHeader = true;
              if (index > 0) {
                final prevTransaction = transactions[index - 1];
                showDateHeader =
                    transaction.date.day != prevTransaction.date.day ||
                        transaction.date.month != prevTransaction.date.month ||
                        transaction.date.year != prevTransaction.date.year;
              }

              if (showDateHeader) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                          top: 16.0, right: 16.0, bottom: 8.0),
                      child: Text(
                        _formatDateHeader(transaction.date),
                        style: const TextStyle(
                            color: Colors.white70, fontWeight: FontWeight.bold),
                      ),
                    ),
                    TransactionListItem(transaction: transaction),
                  ],
                );
              }
              return TransactionListItem(transaction: transaction);
            },
          );
        },
      ),
    );
  }

  String _formatDateHeader(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = DateTime(now.year, now.month, now.day - 1);

    if (date.year == today.year &&
        date.month == today.month &&
        date.day == today.day) {
      return 'اليوم';
    } else if (date.year == yesterday.year &&
        date.month == yesterday.month &&
        date.day == yesterday.day) {
      return 'الأمس';
    } else {
      return DateFormat('EEEE, d MMMM', 'ar').format(date);
    }
  }
}

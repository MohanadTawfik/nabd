import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nabd/data/app_data.dart';
import 'package:nabd/features/add_transaction/widgets/add_transaction_panel.dart';
import 'package:nabd/features/transactions/models/transaction_model.dart';
import 'package:nabd/features/transactions/widgets/transaction_list_item.dart';
import 'package:provider/provider.dart';

class TransactionsScreen extends StatelessWidget {
  const TransactionsScreen({super.key});

  // 2. دالة جديدة لفتح لوحة التعديل
  void _showEditPanel(BuildContext context, Transaction transaction) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      // 3. نمرر المعاملة الحالية إلى اللوحة
      builder: (context) => AddTransactionPanel(transactionToEdit: transaction),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('سجل المعاملات'),
      ),
      body: Consumer<AppData>(
        builder: (context, appData, child) {
          final transactions = appData.transactions;
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
              bool showDateHeader = true;
              if (index > 0) {
                final prevTransaction = transactions[index - 1];
                showDateHeader =
                    transaction.date.day != prevTransaction.date.day;
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (showDateHeader)
                    Padding(
                      padding: const EdgeInsets.only(
                          top: 16.0, right: 16.0, bottom: 8.0),
                      child: Text(_formatDateHeader(transaction.date),
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(fontWeight: FontWeight.bold)),
                    ),
                  // 4. نغلف العنصر بـ InkWell لجعله قابلاً للضغط
                  InkWell(
                    onTap: () => _showEditPanel(context, transaction),
                    borderRadius: BorderRadius.circular(12),
                    child: TransactionListItem(transaction: transaction),
                  ),
                ],
              );
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

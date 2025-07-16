import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nabd/data/app_data.dart';
import 'package:nabd/features/add_transaction/widgets/add_transaction_panel.dart';
import 'package:nabd/features/transactions/models/transaction_model.dart';
import 'package:nabd/features/transactions/screens/filter_transactions_screen.dart';
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
    return Consumer<AppData>(
      builder: (context, appData, child) {
        final transactions = appData.transactions;
        transactions.sort((a, b) => b.date.compareTo(a.date));

        return Scaffold(
          appBar: AppBar(
            title: const Text('سجل المعاملات'),
            actions: [
              IconButton(
                icon: const Icon(Icons.search),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const FilterTransactionsScreen()),
                  );
                },
              ),
              if (appData.isFilterActive)
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    appData.clearFilter();
                  },
                ),
            ],
          ),
          body: transactions.isEmpty
              ? const Center(
                  child: Text('لا توجد معاملات تطابق بحثك',
                      style: TextStyle(fontSize: 16)))
              // 1. هذا هو الإصلاح الكامل والصحيح
              : ListView.builder(
                  padding: const EdgeInsets.all(8.0),
                  itemCount: transactions.length,
                  itemBuilder: (context, index) {
                    final transaction = transactions[index];
                    
                    // 2. منطق ذكي لتحديد إذا كان يجب عرض عنوان التاريخ
                    bool showDateHeader = true;
                    if (index > 0) {
                      final prevTransaction = transactions[index - 1];
                      // مقارنة اليوم والشهر والسنة لضمان الدقة
                      showDateHeader = transaction.date.day !=
                              prevTransaction.date.day ||
                          transaction.date.month !=
                              prevTransaction.date.month ||
                          transaction.date.year != prevTransaction.date.year;
                    }

                    // 3. بناء العنصر مع عنوان التاريخ إذا لزم الأمر
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (showDateHeader)
                          Padding(
                            padding: const EdgeInsets.only(
                                top: 16.0, right: 16.0, bottom: 8.0),
                            child: Text(
                              _formatDateHeader(transaction.date),
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ),
                        InkWell(
                          onTap: () => _showEditPanel(context, transaction),
                          borderRadius: BorderRadius.circular(12),
                          child: TransactionListItem(transaction: transaction),
                        ),
                      ],
                    );
                  },
                ),
        );
      },
    );
  }


  // دالة لتنسيق عنوان التاريخ
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
      return DateFormat('EEEE, d MMMM yyyy', 'ar').format(date);
    }
  }

}

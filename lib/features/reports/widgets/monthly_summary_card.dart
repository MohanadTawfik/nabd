import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nabd/features/transactions/transactions_provider.dart';
import 'package:nabd/features/transactions/models/transaction_model.dart';
import 'package:provider/provider.dart';

class MonthlySummaryCard extends StatelessWidget {
  const MonthlySummaryCard({super.key});

  @override
  Widget build(BuildContext context) {
    // Listen to TransactionsProvider for all transaction data
    return Consumer<TransactionsProvider>(
      builder: (context, txProvider, child) {
        final income = txProvider.transactions
            .where((t) => t.type == TransactionType.income)
            .fold<double>(0, (sum, t) => sum + t.amount);
        final expense = txProvider.transactions
            .where((t) => t.type == TransactionType.expense)
            .fold<double>(0, (sum, t) => sum + t.amount);
        final balance = income - expense;
        return Card(
          color: const Color(0xff161b22),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildSummaryItem('الدخل', income, Colors.green.shade400),
                _buildSummaryItem('المصروف', expense, Colors.red.shade400),
                _buildSummaryItem('الصافي', balance, Colors.blue.shade400),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSummaryItem(String title, double value, Color color) {
    final format = NumberFormat("#,##0", "en_US");
    return Column(
      children: [
        Text(title,
            style: const TextStyle(color: Colors.white70, fontSize: 14)),
        const SizedBox(height: 8),
        Text(
          format.format(value),
          style: TextStyle(
              color: color, fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

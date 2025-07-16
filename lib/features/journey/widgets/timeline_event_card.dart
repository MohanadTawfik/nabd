import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nabd/features/transactions/models/transaction_model.dart';

class TimelineEventCard extends StatelessWidget {
  final Transaction transaction;
  const TimelineEventCard({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    final isExpense = transaction.type == TransactionType.expense;
    final color = isExpense ? Colors.red.shade400 : Colors.green.shade400;
    final format = NumberFormat.currency(locale: 'ar', symbol: 'ريال');

    return IntrinsicHeight(
      child: Row(
        children: [
          // 1. الدائرة على الخط الزمني
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(
                  color: Theme.of(context).scaffoldBackgroundColor, width: 3),
            ),
          ),
          const SizedBox(width: 20),

          // 2. بطاقة تفاصيل الحدث
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24.0),
              child: Card(
                color: Theme.of(context).cardColor.withOpacity(0.8),
                shape: RoundedRectangleBorder(
                  side: BorderSide(color: color.withOpacity(0.5), width: 1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        transaction.category.name,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        DateFormat.yMMMd('ar')
                            .add_jm()
                            .format(transaction.date),
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(fontSize: 12),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${isExpense ? '-' : '+'}${format.format(transaction.amount)}',
                        style: TextStyle(
                          color: color,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

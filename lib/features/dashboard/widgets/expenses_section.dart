import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nabd/data/app_data.dart';
import 'package:nabd/features/transactions/models/transaction_model.dart';
import 'package:provider/provider.dart';

class ExpensesSection extends StatelessWidget {
  const ExpensesSection({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. تعريف خريطة للألوان لكل فئة
    const categoryColors = {
      'طعام': Colors.blue,
      'مواصلات': Colors.orange,
      'مقاضي': Colors.red,
      'فواتير': Colors.purple,
    };
    const defaultColor = Colors.grey;

    return Consumer<AppData>(
      builder: (context, appData, child) {
        final expenseMap = <String, Map<String, dynamic>>{};
        for (var t in appData.transactions
            .where((t) => t.type == TransactionType.expense)) {
          expenseMap.update(
            t.category,
            (value) => {
              'amount': value['amount'] + t.amount,
              'icon': t.icon,
            },
            ifAbsent: () => {
              'amount': t.amount,
              'icon': t.icon,
            },
          );
        }

        final expensesData = expenseMap.entries.toList()
          ..sort((a, b) => b.value['amount'].compareTo(a.value['amount']));

        if (expensesData.isEmpty) {
          return Card(
            color: const Color(0xff161b22),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: const Padding(
              padding: EdgeInsets.all(40.0),
              child: Center(
                  child: Text('لا توجد مصروفات لعرضها بعد',
                      style: TextStyle(color: Colors.white54))),
            ),
          );
        }

        final totalExpenses = appData.totalExpense;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'أكبر النفقات هذا الشهر',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Card(
              color: const Color(0xff161b22),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: expensesData.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 20),
                  itemBuilder: (context, index) {
                    final expense = expensesData[index];
                    final percentage = totalExpenses > 0
                        ? expense.value['amount'] / totalExpenses
                        : 0.0;
                    // 2. تحديد لون الفئة من الخريطة أو استخدام اللون الافتراضي
                    final color = categoryColors[expense.key] ?? defaultColor;

                    return _buildExpenseRow(
                      name: expense.key,
                      icon: expense.value['icon'],
                      amount: expense.value['amount'],
                      percentage: percentage,
                      color: color, // 3. تمرير اللون الصحيح
                    );
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildExpenseRow({
    required String name,
    required IconData icon,
    required double amount,
    required double percentage,
    required Color color,
  }) {
    final format = NumberFormat("#,##0", "en_US");

    return Row(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(name,
                      style:
                          const TextStyle(color: Colors.white, fontSize: 16)),
                  Text(
                    '${format.format(amount)} ريال',
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: percentage,
                backgroundColor:
                    color.withOpacity(0.2), // استخدام اللون هنا أيضاً
                valueColor: AlwaysStoppedAnimation<Color>(color), // وهنا أيضاً
                minHeight: 8,
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

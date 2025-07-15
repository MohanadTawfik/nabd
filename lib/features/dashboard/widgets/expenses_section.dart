import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nabd/data/app_data.dart';
import 'package:nabd/features/transactions/models/transaction_model.dart';
import 'package:nabd/features/transactions/screens/transactions_screen.dart';
import 'package:provider/provider.dart';

class ExpensesSection extends StatelessWidget {
  const ExpensesSection({super.key});

  @override
  Widget build(BuildContext context) {
    const categoryColors = {
      'طعام': Colors.blue,
      'مواصلات': Colors.orange,
      'مقاضي': Colors.red,
      'فواتير': Colors.purple,
      'ترفيه': Colors.teal,
      'تسوق': Colors.pink,
    };
    const defaultColor = Colors.grey;

    return Consumer<AppData>(
      builder: (context, appData, child) {
        final expenseMap = <String, Map<String, dynamic>>{};
        for (var t in appData.transactions
            .where((t) => t.type == TransactionType.expense)) {
          expenseMap.update(t.category,
              (value) => {'amount': value['amount'] + t.amount, 'icon': t.icon},
              ifAbsent: () => {'amount': t.amount, 'icon': t.icon});
        }
        final expensesData = expenseMap.entries.toList()
          ..sort((a, b) => b.value['amount'].compareTo(a.value['amount']));

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('أكبر النفقات هذا الشهر',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold)),
                // 2. إضافة زر "عرض الكل"
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const TransactionsScreen()),
                    );
                  },
                  child: const Text('عرض الكل',
                      style: TextStyle(color: Color(0xff8952ff))),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (expensesData.isEmpty)
              Card(
                color: const Color(0xff161b22),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                child: const Padding(
                  padding: EdgeInsets.all(40.0),
                  child: Center(
                      child: Text('لا توجد مصروفات لعرضها بعد',
                          style: TextStyle(color: Colors.white54))),
                ),
              )
            else
              Card(
                color: const Color(0xff161b22),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: expensesData.length > 3
                        ? 3
                        : expensesData.length, // عرض أكبر 3 فقط
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 20),
                    itemBuilder: (context, index) {
                      final expense = expensesData[index];
                      final totalExpenses = appData.totalExpense;
                      final percentage = totalExpenses > 0
                          ? expense.value['amount'] / totalExpenses
                          : 0.0;
                      final color = categoryColors[expense.key] ?? defaultColor;
                      return _buildExpenseRow(
                        name: expense.key,
                        icon: expense.value['icon'],
                        amount: expense.value['amount'],
                        percentage: percentage,
                        color: color,
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

  Widget _buildExpenseRow(
      {required String name,
      required IconData icon,
      required double amount,
      required double percentage,
      required Color color}) {
    final format = NumberFormat("#,##0", "en_US");
    return Row(children: [
      Icon(icon, color: color, size: 28),
      const SizedBox(width: 12),
      Expanded(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(name, style: const TextStyle(color: Colors.white, fontSize: 16)),
          Text('${format.format(amount)} ريال',
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16))
        ]),
        const SizedBox(height: 8),
        LinearProgressIndicator(
            value: percentage,
            backgroundColor: color.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 8,
            borderRadius: BorderRadius.circular(4))
      ]))
    ]);
  }
}

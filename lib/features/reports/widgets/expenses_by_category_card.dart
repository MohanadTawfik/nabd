import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nabd/features/transactions/transactions_provider.dart';
import 'package:nabd/features/transactions/models/transaction_model.dart';
import 'package:provider/provider.dart'; // حزمة لتنسيق الأرقام

class ExpensesByCategoryCard extends StatefulWidget {
  const ExpensesByCategoryCard({super.key});

  @override
  State<ExpensesByCategoryCard> createState() => _ExpensesByCategoryCardState();
}

class _ExpensesByCategoryCardState extends State<ExpensesByCategoryCard> {
  int? _selectedIndex;

  // // 1. تعريف خريطة الألوان هنا
  final Map<String, Color> _categoryColors = {
    'طعام': Colors.blue,
    'مواصلات': Colors.orange,
    'مقاضي': Colors.red,
    'فواتير': Colors.purple,
    'ترفيه': Colors.teal,
    'تسوق': Colors.pink,
  };
  final Color _defaultColor = Colors.grey;

  @override
  Widget build(BuildContext context) {
    final numberFormat = NumberFormat("#,##0", "en_US");

    return Consumer<TransactionsProvider>(
      builder: (context, txProvider, child) {
        final expenseMap = <String, double>{};
        for (var t in txProvider.transactions
            .where((t) => t.type == TransactionType.expense)) {
          expenseMap.update(t.category.name, (value) => value + t.amount,
              ifAbsent: () => t.amount);
        }
        final expensesData = expenseMap.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));

        if (expensesData.isEmpty) {
          return Card(
            color: const Color(0xff161b22),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: const Padding(
              padding: EdgeInsets.all(60.0),
              child: Center(
                  child: Text('لا توجد بيانات لعرض المخطط',
                      style: TextStyle(color: Colors.white54))),
            ),
          );
        }

        final maxAmount = expensesData.fold<double>(
            0.0, (max, e) => e.value > max ? e.value : max);

        return Card(
          color: const Color(0xff161b22),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(numberFormat, expensesData),
                const SizedBox(height: 24),
                SizedBox(
                  height: 150,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: expensesData.asMap().entries.map((entry) {
                      int index = entry.key;
                      var expense = entry.value;
                      // 2. تحديد اللون من الخريطة
                      final color =
                          _categoryColors[expense.key] ?? _defaultColor;
                      return _buildBar(
                        index,
                        expense.key,
                        expense.value,
                        maxAmount > 0 ? expense.value / maxAmount : 0.0,
                        color, // 3. تمرير اللون الصحيح
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(
      NumberFormat format, List<MapEntry<String, double>> expensesData) {
    final Color selectedColor = _selectedIndex != null
        ? (_categoryColors[expensesData[_selectedIndex!].key] ?? _defaultColor)
        : Colors.blue;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: _selectedIndex == null
          ? const Text(
              'النفقات حسب الفئة',
              key: ValueKey('title'),
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
            )
          : Row(
              key: ValueKey(_selectedIndex),
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  expensesData[_selectedIndex!].key,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
                Text(
                  '${format.format(expensesData[_selectedIndex!].value)} ريال',
                  style: TextStyle(
                      color: selectedColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
    );
  }

  Widget _buildBar(
      int index, String name, double amount, double heightFactor, Color color) {
    final isSelected = _selectedIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedIndex = isSelected ? null : index;
        });
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: isSelected ? 45 : 40,
            height: 120 * heightFactor,
            decoration: BoxDecoration(
              color: isSelected ? color : color.withOpacity(0.7),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(6)),
            ),
          ),
          const SizedBox(height: 8),
          Text(name,
              style: TextStyle(
                  color: isSelected ? Colors.white : Colors.white70,
                  fontSize: 13)),
        ],
      ),
    );
  }
}

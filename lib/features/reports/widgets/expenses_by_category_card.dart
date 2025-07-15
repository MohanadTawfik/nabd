import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // حزمة لتنسيق الأرقام

// 1. حولنا الويدجت إلى StatefulWidget
class ExpensesByCategoryCard extends StatefulWidget {
  const ExpensesByCategoryCard({super.key});

  @override
  State<ExpensesByCategoryCard> createState() => _ExpensesByCategoryCardState();
}

class _ExpensesByCategoryCardState extends State<ExpensesByCategoryCard> {
  // 2. متغير حالة لتخزين مؤشر العمود المختار
  int? _selectedIndex;

  // بيانات مؤقتة
  final expenses = [
    {'name': 'طعام', 'amount': 85000.0, 'color': Colors.blue},
    {'name': 'مواصلات', 'amount': 40000.0, 'color': Colors.orange},
    {'name': 'فواتير', 'amount': 30000.0, 'color': Colors.purple},
    {'name': 'ترفيه', 'amount': 20000.0, 'color': Colors.teal},
  ];

  @override
  Widget build(BuildContext context) {
    final maxAmount = expenses.fold<double>(0.0,
        (max, e) => e['amount'] as double > max ? e['amount'] as double : max);

    // لتنسيق الأرقام مع فواصل (e.g., 85,000)
    final numberFormat = NumberFormat("#,##0", "en_US");

    return Card(
      color: const Color(0xff161b22),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 3. عرض تفاصيل العمود المختار
            _buildHeader(numberFormat),
            const SizedBox(height: 24),
            SizedBox(
              height: 150,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: expenses.asMap().entries.map((entry) {
                  int index = entry.key;
                  Map<String, dynamic> expense = entry.value;
                  return _buildBar(
                    context,
                    index,
                    expense['name'] as String,
                    expense['amount'] as double,
                    expense['color'] as Color,
                    (expense['amount'] as double) / maxAmount,
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ويدجت مساعد لبناء العنوان الذي يعرض التفاصيل
  Widget _buildHeader(NumberFormat format) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: _selectedIndex == null
          ? const Text(
              'النفقات حسب الفئة',
              key: ValueKey('title'), // مفتاح لتمييز الويدجت للأنيميشن
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
            )
          : Row(
              key: ValueKey(_selectedIndex), // مفتاح مختلف عند وجود اختيار
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  expenses[_selectedIndex!]['name'] as String,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
                Text(
                  '${format.format(expenses[_selectedIndex!]['amount'])} ريال',
                  style: TextStyle(
                      color: expenses[_selectedIndex!]['color'] as Color,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
    );
  }

  // 4. ويدجت مساعد لبناء عمود واحد تفاعلي
  Widget _buildBar(BuildContext context, int index, String name, double amount,
      Color color, double heightFactor) {
    final isSelected = _selectedIndex == index;

    return GestureDetector(
      // 5. أضفنا GestureDetector للاستجابة للمسة
      onTap: () {
        setState(() {
          // إذا ضغط على نفس العمود مرة أخرى، يلغى الاختيار
          _selectedIndex = isSelected ? null : index;
        });
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // 6. استخدمنا AnimatedContainer لتكبير العمود بسلاسة
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: isSelected ? 45 : 40, // يزيد العرض عند الاختيار
            height: 120 * heightFactor,
            decoration: BoxDecoration(
              color:
                  isSelected ? color.withOpacity(1.0) : color.withOpacity(0.7),
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

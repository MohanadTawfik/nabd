import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nabd/data/app_data.dart';
import 'package:provider/provider.dart';

class MonthlySummaryCard extends StatelessWidget {
  const MonthlySummaryCard({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. نستخدم Consumer للاستماع للتغيرات في AppData
    return Consumer<AppData>(
      builder: (context, appData, child) {
        return Card(
          color: const Color(0xff161b22),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // 2. عرض البيانات الحقيقية من مركز البيانات
                _buildSummaryItem(
                    'الدخل', appData.totalIncome, Colors.green.shade400),
                _buildSummaryItem(
                    'المصروف', appData.totalExpense, Colors.red.shade400),
                _buildSummaryItem(
                    'الصافي', appData.currentBalance, Colors.blue.shade400),
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

import 'package:flutter/material.dart';

class MonthlySummaryCard extends StatelessWidget {
  const MonthlySummaryCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xff161b22),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildSummaryItem('الدخل', '٣٥٠,٠٠٠', Colors.green.shade400),
            _buildSummaryItem('المصروف', '١٢٥,٠٠٠', Colors.red.shade400),
            _buildSummaryItem('الصافي', '٢٢٥,٠٠٠', Colors.blue.shade400),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String title, String amount, Color color) {
    return Column(
      children: [
        Text(title,
            style: const TextStyle(color: Colors.white70, fontSize: 14)),
        const SizedBox(height: 8),
        Text(
          amount,
          style: TextStyle(
              color: color, fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

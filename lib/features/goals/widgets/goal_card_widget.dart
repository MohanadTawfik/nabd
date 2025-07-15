import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class GoalCardWidget extends StatelessWidget {
  final String name;
  final IconData icon;
  final double savedAmount;
  final double totalAmount;
  final Color color;

  const GoalCardWidget({
    super.key,
    required this.name,
    required this.icon,
    required this.savedAmount,
    required this.totalAmount,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final progress = (savedAmount / totalAmount).clamp(0.0, 1.0);
    final format = NumberFormat("#,##0", "en_US");

    return Card(
      color: const Color(0xff161b22),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Icon(icon, color: color, size: 32),
              const SizedBox(width: 12),
              Text(name,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold))
            ]),
            const SizedBox(height: 16),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('تم توفير: ${format.format(savedAmount)}',
                  style: const TextStyle(color: Colors.white70, fontSize: 14)),
              Text('${(progress * 100).toStringAsFixed(0)}%',
                  style: TextStyle(
                      color: color, fontWeight: FontWeight.bold, fontSize: 14))
            ]),
            const SizedBox(height: 8),
            LinearProgressIndicator(
                value: progress,
                backgroundColor: color.withOpacity(0.2),
                valueColor: AlwaysStoppedAnimation<Color>(color),
                minHeight: 8,
                borderRadius: BorderRadius.circular(4)),
            const SizedBox(height: 8),
            Align(
                alignment: Alignment.centerLeft,
                child: Text(
                    'المتبقي: ${format.format(totalAmount - savedAmount)}',
                    style:
                        const TextStyle(color: Colors.white70, fontSize: 12))),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nabd/features/goals/models/goal_model.dart';

class GoalCardWidget extends StatelessWidget {
  final Goal goal; // 2. أصبح الآن يستقبل كائن الهدف بالكامل

  const GoalCardWidget({
    super.key,
    required this.goal,
  });

  @override
  Widget build(BuildContext context) {
    final progress = (goal.savedAmount / goal.totalAmount).clamp(0.0, 1.0);
    final format = NumberFormat("#,##0", "en_US");

    return Card(
      color: const Color(0xff161b22),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(goal.icon, color: goal.color, size: 32),
                const SizedBox(width: 12),
                Text(goal.name,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'تم توفير: ${format.format(goal.savedAmount)}',
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
                Text(
                  '${(progress * 100).toStringAsFixed(0)}%',
                  style: TextStyle(
                      color: goal.color,
                      fontWeight: FontWeight.bold,
                      fontSize: 14),
                ),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: goal.color.withOpacity(0.2),
              valueColor: AlwaysStoppedAnimation<Color>(goal.color),
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'المتبقي: ${format.format(goal.totalAmount - goal.savedAmount)}',
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

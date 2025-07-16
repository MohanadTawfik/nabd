import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nabd/features/goals/models/goal_model.dart';

class MilestoneEventCard extends StatelessWidget {
  final Goal goal;
  const MilestoneEventCard({super.key, required this.goal});

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        children: [
          // 1. نجمة متوهجة بدلاً من الدائرة العادية
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: goal.color,
              boxShadow: [
                BoxShadow(color: goal.color, blurRadius: 12, spreadRadius: 2),
              ],
            ),
            child: Icon(Icons.star, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24.0),
              child: Card(
                elevation: 8,
                shadowColor: goal.color,
                color: Theme.of(context).cardColor,
                shape: RoundedRectangleBorder(
                  side: BorderSide(color: goal.color, width: 1.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '🎉 إنجاز عظيم! 🎉',
                        style: TextStyle(
                            color: goal.color,
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'لقد حققت هدفك: "${goal.name}"',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'في تاريخ: ${DateFormat.yMMMd('ar').format(DateTime.now())}',
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(fontSize: 12),
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

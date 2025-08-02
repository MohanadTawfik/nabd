import 'package:flutter/material.dart';
import 'package:nabd/features/goals/goals_provider.dart';
import 'package:nabd/features/goals/models/goal_model.dart';
import 'package:provider/provider.dart';

class RocketBoostPanel extends StatelessWidget {
  final Goal goal;
  const RocketBoostPanel({super.key, required this.goal});

  @override
  Widget build(BuildContext context) {
    // بيانات افتراضية للتحدي
    const boostAmount = 6000.0;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Color(0xff161b22),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.rocket_launch, size: 60, color: goal.color),
          const SizedBox(height: 16),
          const Text(
            'تحدي الدفعة الصاروخية!',
            style: TextStyle(
                color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          const Text(
            'لو قمت بتقليل وجبات المطاعم، يمكنك بسهولة توفير 6,000 ريال إضافية هذا الأسبوع!',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white70, fontSize: 16, height: 1.5),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () async {
                // إضافة المبلغ للهدف وإغلاق اللوحة
                final goalsProvider =
                    Provider.of<GoalsProvider>(context, listen: false);
                final updatedGoal = Goal(
                  id: goal.id,
                  name: goal.name,
                  icon: goal.icon,
                  color: goal.color,
                  savedAmount: goal.savedAmount + boostAmount,
                  totalAmount: goal.totalAmount,
                  createdAt: goal.createdAt,
                  targetDate: goal.targetDate,
                );
                await goalsProvider.updateGoal(updatedGoal);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: goal.color,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('موافق! حوّل المبلغ إلى هدفي',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}

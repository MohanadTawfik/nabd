import 'package:flutter/material.dart';
import 'package:nabd/features/goals/widgets/goal_card_widget.dart';
// 1. استيراد شاشة إضافة هدف جديد
import 'add_goal_screen.dart';

class GoalsScreen extends StatelessWidget {
  const GoalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. عدنا لاستخدام قائمة بيانات افتراضية بسيطة
    final goals = [
      {
        'name': 'سيارة أحلامي',
        'icon': Icons.directions_car,
        'saved': 750000.0,
        'total': 1000000.0,
        'color': Colors.blue.shade300,
      },
      {
        'name': 'السفر إلى سقطرى',
        'icon': Icons.airplanemode_active,
        'saved': 200000.0,
        'total': 500000.0,
        'color': Colors.teal.shade300,
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('أهدافك'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline,
                size: 28, color: Colors.white),
            onPressed: () {
              // 2. تفعيل الزر للانتقال إلى الشاشة الجديدة
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AddGoalScreen()),
              );
            },
          ),
        ],
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16.0),
        itemCount: goals.length,
        separatorBuilder: (context, index) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          final goal = goals[index];
          // 2. نمرر البيانات مباشرة إلى الويدجت
          return GoalCardWidget(
            name: goal['name'] as String,
            icon: goal['icon'] as IconData,
            savedAmount: goal['saved'] as double,
            totalAmount: goal['total'] as double,
            color: goal['color'] as Color,
          );
        },
      ),
    );
  }
}

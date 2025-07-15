import 'package:flutter/material.dart';
import 'package:nabd/features/goals/models/goal_model.dart';
import 'package:nabd/features/goals/widgets/goal_card_widget.dart';
import 'add_goal_screen.dart';


// 2. حولنا الشاشة إلى StatefulWidget لتتمكن من تحديث حالتها (قائمة الأهداف)
class GoalsScreen extends StatefulWidget {
  const GoalsScreen({super.key});

  @override
  State<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen> {
  // 3. قائمة الأهداف الآن هي جزء من "حالة" الشاشة
  final List<Goal> _goals = [
    Goal(
        name: 'سيارة أحلامي',
        icon: Icons.directions_car,
        savedAmount: 750000.0,
        totalAmount: 1000000.0,
        color: Colors.blue.shade300),
    Goal(
        name: 'السفر إلى سقطرى',
        icon: Icons.airplanemode_active,
        savedAmount: 200000.0,
        totalAmount: 500000.0,
        color: Colors.teal.shade300),
  ];

  // 4. دالة للانتقال لشاشة الإضافة وانتظار النتيجة
  void _navigateAndAddGoal(BuildContext context) async {
    // نستخدم await لننتظر حتى تعود شاشة الإضافة بالهدف الجديد
    final newGoal = await Navigator.push<Goal>(
      context,
      MaterialPageRoute(builder: (context) => const AddGoalScreen()),
    );

    // إذا عادت الشاشة بهدف جديد (المستخدم لم يضغط "رجوع")
    if (newGoal != null) {
      setState(() {
        _goals.add(newGoal); // نضيف الهدف الجديد للقائمة
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('أهدافك'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline,
                size: 28, color: Colors.white),
            onPressed: () =>
                _navigateAndAddGoal(context), // 5. استدعاء الدالة الجديدة
          ),
        ],
      ),
      body: _goals.isEmpty
          ? const Center(
              child: Text('ليس لديك أهداف بعد. أضف هدفاً جديداً!',
                  style: TextStyle(color: Colors.white70, fontSize: 16)))
          : ListView.separated(
              padding: const EdgeInsets.all(16.0),
              itemCount: _goals.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final goal = _goals[index];
                // 6. نمرر كائن الهدف بالكامل إلى الويدجت
                return GoalCardWidget(goal: goal);
              },
            ),
    );
  }
}

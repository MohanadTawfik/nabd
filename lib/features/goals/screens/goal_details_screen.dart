import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nabd/data/app_data.dart';
import 'package:nabd/features/goals/models/goal_model.dart';
import 'package:nabd/features/goals/widgets/rocket_boost_panel.dart';
import 'package:provider/provider.dart';

class GoalDetailsScreen extends StatelessWidget {
  final Goal goal;

  const GoalDetailsScreen({super.key, required this.goal});

  void _showRocketBoostPanel(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => RocketBoostPanel(goal: goal),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppData>(
      builder: (context, appData, child) {
        final currentGoal =
            appData.goals.firstWhere((g) => g == goal, orElse: () => goal);
        final progress =
            (currentGoal.savedAmount / currentGoal.totalAmount).clamp(0.0, 1.0);
        final format = NumberFormat("#,##0", "en_US");

        return Scaffold(
          appBar: AppBar(
            title: Text(currentGoal.name),
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
          
          // 1. لقد قمنا بإزالة SingleChildScrollView من هنا
          body: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
            child: Hero(
              tag: 'goal_card_${goal.name}',
              child: Material(
                type: MaterialType.transparency,
                // 2. استخدمنا Column لتقسيم الشاشة إلى جزء ثابت وجزء قابل للتمرير
                child: Column(
                  children: [
                    // =================== الجزء الثابت ===================
                    SizedBox(
                      width: 200,
                      height: 200,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          TweenAnimationBuilder<double>(
                            tween: Tween<double>(begin: 0, end: progress),
                            duration: const Duration(milliseconds: 800),
                            builder: (context, value, child) =>
                                CircularProgressIndicator(
                              value: value,
                              strokeWidth: 12,
                              backgroundColor:
                                  currentGoal.color.withOpacity(0.2),
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  currentGoal.color),
                            ),
                          ),
                          Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(currentGoal.icon,
                                    color: currentGoal.color, size: 60),
                                const SizedBox(height: 8),
                                Text(
                                  '${(progress * 100).toStringAsFixed(0)}%',
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // =================== الجزء القابل للتمرير ===================
                    // 3. استخدمنا Expanded و SingleChildScrollView هنا
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _buildDetailChip(
                                    'المبلغ المدخر',
                                    format.format(currentGoal.savedAmount),
                                    Colors.green),
                                _buildDetailChip(
                                    'المبلغ المتبقي',
                                    format.format(currentGoal.totalAmount -
                                        currentGoal.savedAmount),
                                    Colors.orange),
                              ],
                            ),
                            const SizedBox(height: 16),
                            _buildDetailChip(
                                'المبلغ الإجمالي',
                                format.format(currentGoal.totalAmount),
                                Colors.blue,
                                isFullWidth: true),
                            const SizedBox(height: 32),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                icon: const Icon(Icons.rocket_launch_outlined),
                                label: const Text('أعطني دفعة صاروخية!',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16)),
                                onPressed: () => _showRocketBoostPanel(context),
                                style: ElevatedButton.styleFrom(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 16),
                                  backgroundColor:
                                      currentGoal.color.withOpacity(0.8),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12)),
                                ),
                              ),
                            ),
                            const SizedBox(
                                height: 24), // مسافة إضافية في الأسفل
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailChip(String title, String value, Color color,
      {bool isFullWidth = false}) {
    return Container(
      width: isFullWidth ? double.infinity : null,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xff161b22),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        children: [
          Text(title,
              style: const TextStyle(color: Colors.white70, fontSize: 14)),
          const SizedBox(height: 4),
          Text('$value ريال',
              style: TextStyle(
                  color: color, fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:nabd/data/app_data.dart';
import 'package:nabd/features/goals/models/goal_model.dart';
import 'package:nabd/features/goals/screens/goal_details_screen.dart';
import 'package:nabd/features/goals/widgets/goal_card_widget.dart';
import 'package:nabd/widgets/confirmation_dialog.dart';
import 'package:provider/provider.dart';
import 'add_goal_screen.dart';

class GoalsScreen extends StatelessWidget {
  const GoalsScreen({super.key});

  void _navigateAndAddGoal(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddGoalScreen()),
    );
  }

  // 1. دالة جديدة ومستقلة لإظهار نافذة الحذف
  void _showDeleteConfirmation(BuildContext context, Goal goal) {
    // 2. نحصل على AppData هنا، قبل أي شيء آخر، لضمان أن الـ context صالح
    final appData = Provider.of<AppData>(context, listen: false);

    showDialog(
      context: context,
      builder: (dialogContext) => ConfirmationDialog(
        title: 'حذف الهدف',
        content: 'هل أنت متأكد من رغبتك في حذف هدف "${goal.name}"؟',
        onConfirm: () {
          // 3. نستخدم نسخة AppData التي حصلنا عليها بأمان
          appData.deleteGoal(goal);
          HapticFeedback.mediumImpact();
          Navigator.of(dialogContext).pop();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('أهدافك'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline, size: 28),
            onPressed: () => _navigateAndAddGoal(context),
          ),
        ],
      ),
      body: Consumer<AppData>(
        builder: (context, appData, child) {
          final goals = appData.goals;

          if (goals.isEmpty) {
            return const Center(
                child: Text('ليس لديك أهداف بعد. أضف هدفاً جديداً!',
                    style: TextStyle(color: Colors.white70, fontSize: 16)));
          }

          return AnimationLimiter(
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: goals.length,
              itemBuilder: (context, index) {
                final goal = goals[index];
                return AnimationConfiguration.staggeredList(
                  position: index,
                  duration: const Duration(milliseconds: 500),
                  child: SlideAnimation(
                    verticalOffset: 50.0,
                    child: FadeInAnimation(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: Slidable(
                          key: ValueKey(goal.name),
                          startActionPane: ActionPane(
                            motion: const DrawerMotion(),
                            children: [
                              SlidableAction(
                                // 4. نستدعي الدالة الجديدة والآمنة هنا
                                onPressed: (context) =>
                                    _showDeleteConfirmation(context, goal),
                                backgroundColor: Colors.red.shade400,
                                foregroundColor: Colors.white,
                                icon: Icons.delete,
                                label: 'حذف',
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ],
                          ),
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                PageRouteBuilder(
                                  transitionDuration:
                                      const Duration(milliseconds: 700),
                                  pageBuilder:
                                      (context, animation, secondaryAnimation) {
                                    return GoalDetailsScreen(goal: goal);
                                  },
                                  transitionsBuilder: (context, animation,
                                      secondaryAnimation, child) {
                                    return FadeTransition(
                                        opacity: animation, child: child);
                                  },
                                ),
                              );
                            },
                            child: Hero(
                              tag: 'goal_card_${goal.name}',
                              child: GoalCardWidget(goal: goal),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

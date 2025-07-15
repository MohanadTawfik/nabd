import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:nabd/data/app_data.dart';
import 'package:nabd/features/goals/screens/goal_details_screen.dart';
import 'package:nabd/features/goals/widgets/goal_card_widget.dart';
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
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    GoalDetailsScreen(goal: goal),
                              ),
                            );
                          },
                          // 1. نغلف البطاقة بـ Hero ونعطيه وسماً فريداً
                          child: Hero(
                            tag: 'goal_card_${goal.name}', // وسم فريد لكل هدف
                            child: GoalCardWidget(goal: goal),
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

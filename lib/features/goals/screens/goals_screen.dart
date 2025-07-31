import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:nabd/data/app_data.dart';
import 'package:nabd/features/goals/models/goal_model.dart';
import 'package:nabd/features/goals/screens/goal_details_screen.dart';
import 'package:nabd/features/goals/widgets/goal_card_widget.dart';
import 'package:nabd/widgets/confirmation_dialog.dart';
import 'package:nabd/widgets/glass_card.dart';
import 'package:provider/provider.dart';
import 'add_goal_screen.dart';

class GoalsScreen extends StatelessWidget {
  const GoalsScreen({super.key});

  // Navigate to add goal screen with a smooth transition
  void _navigateAndAddGoal(BuildContext context) {
    HapticFeedback.lightImpact();
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const AddGoalScreen(),
        transitionsBuilder: (_, animation, __, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 1),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutQuart,
            )),
            child: child,
          );
        },
      ),
    );
  }

  // Show delete confirmation dialog with haptic feedback
  void _showDeleteConfirmation(BuildContext context, Goal goal) {
    HapticFeedback.mediumImpact();
    final appData = Provider.of<AppData>(context, listen: false);

    showDialog(
      context: context,
      builder: (dialogContext) => ConfirmationDialog(
        title: 'حذف الهدف',
        content: 'هل أنت متأكد من رغبتك في حذف هدف "${goal.name}"؟',
        onConfirm: () {
          appData.deleteGoal(goal);
          HapticFeedback.mediumImpact();
          Navigator.of(dialogContext).pop();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: false,
      appBar: AppBar(
        title:
            const Text('أهدافك', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.add_rounded,
                color: theme.colorScheme.primary,
                size: 24,
              ),
            ),
            onPressed: () => _navigateAndAddGoal(context),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              theme.colorScheme.surface,
              theme.colorScheme.surface.withOpacity(0.9),
            ],
          ),
        ),
        child: Consumer<AppData>(
          builder: (context, appData, child) {
            final goals = appData.goals;
            final completedGoals = goals
                .where((g) => (g.savedAmount / g.totalAmount) >= 1.0)
                .toList();
            final activeGoals = goals
                .where((g) => (g.savedAmount / g.totalAmount) < 1.0)
                .toList();

            if (goals.isEmpty) {
              return _buildEmptyState(context, theme);
            }

            return RefreshIndicator(
              onRefresh: () async {
                // Simulate refresh
                await Future.delayed(const Duration(seconds: 1));
              },
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  // Active Goals Section
                  if (activeGoals.isNotEmpty)
                    ..._buildGoalsSection(
                      context: context,
                      title: 'الأهداف النشطة',
                      goals: activeGoals,
                      onDelete: _showDeleteConfirmation,
                    ),
                  // Completed Goals Section
                  if (completedGoals.isNotEmpty)
                    ..._buildGoalsSection(
                      context: context,
                      title: 'الأهداف المكتملة',
                      goals: completedGoals,
                      onDelete: _showDeleteConfirmation,
                    ),
                  // Add some padding at the bottom for the FAB
                  const SliverToBoxAdapter(
                    child: SizedBox(height: 100),
                  ),
                ],
              ),
            );
          },
        ),
      ),
      floatingActionButton: Container(
        margin: const EdgeInsets.only(bottom: 16, left: 16, right: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.primary.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          onPressed: () => _navigateAndAddGoal(context),
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: theme.colorScheme.onPrimary,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          icon: const Icon(Icons.add_rounded, size: 24),
          label: const Text('إضافة هدف جديد',
              style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.list_alt,
            size: 48,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(height: 16),
          Text(
            'ليس لديك أهداف بعد. أضف هدفاً جديداً!',
            style: TextStyle(color: theme.colorScheme.onSurface, fontSize: 16),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildGoalsSection({
    required BuildContext context,
    required String title,
    required List<Goal> goals,
    required Function(BuildContext, Goal) onDelete,
  }) {
    return [
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ),
      ),
      SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final goal = goals[index];

            return AnimationConfiguration.staggeredList(
              position: index,
              duration: const Duration(milliseconds: 500),
              child: SlideAnimation(
                verticalOffset: 50.0,
                child: FadeInAnimation(
                  child: Padding(
                    padding: const EdgeInsets.only(
                        bottom: 16.0, left: 16, right: 16),
                    child: Dismissible(
                      key: ValueKey(goal.name),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.red.shade400,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 24),
                        child: const Icon(
                          Icons.delete_outline_rounded,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      confirmDismiss: (direction) async {
                        onDelete(context, goal);
                        return false; // We handle the deletion in the dialog
                      },
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
          childCount: goals.length,
        ),
      ),
    ];
  }
}

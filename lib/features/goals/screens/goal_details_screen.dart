import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:nabd/data/app_data.dart';
import 'package:nabd/features/goals/models/goal_model.dart';
import 'package:nabd/features/goals/widgets/rocket_boost_panel.dart';
import 'package:nabd/widgets/glass_card.dart';
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
    final theme = Theme.of(context);

    return Consumer<AppData>(
      builder: (context, appData, child) {
        final currentGoal =
            appData.goals.firstWhere((g) => g == goal, orElse: () => goal);
        final progress =
            (currentGoal.savedAmount / currentGoal.totalAmount).clamp(0.0, 1.0);
        final isCompleted = progress >= 1.0;
        final format = NumberFormat("#,##0", "ar");

        return Scaffold(
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            title: Text(
              currentGoal.name,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            centerTitle: false,
            backgroundColor: Colors.transparent,
            elevation: 0,
            systemOverlayStyle: theme.brightness == Brightness.dark
                ? SystemUiOverlayStyle.light
                : SystemUiOverlayStyle.dark,
          ),

          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  theme.colorScheme.surface,
                  theme.colorScheme.surfaceVariant.withOpacity(0.5),
                ],
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20.0, vertical: 16.0),
                child: Column(
                  children: [
                    // Progress Circle with Animation
                    _buildProgressCircle(
                        context, currentGoal, progress, isCompleted),
                    const SizedBox(height: 32),

                    // Stats Row
                    _buildStatsRow(currentGoal, format, theme, isCompleted),
                    const SizedBox(height: 24),

                    // Action Buttons
                    _buildActionButtons(
                        context, appData, currentGoal, isCompleted, theme),

                    // Spacer to push content up
                    const Spacer(),

                    // Achieve Goal Button (only if not completed)
                    if (!isCompleted)
                      _buildAchieveGoalButton(
                          context, appData, currentGoal, theme),

                    // Bottom padding for FAB
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
          ),

          // Floating Action Button for adding to goal
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () =>
                _showAddToGoalBottomSheet(context, currentGoal, appData),
            icon: const Icon(Icons.add_rounded, size: 24),
            label: const Text('إضافة مدخرات',
                style: TextStyle(fontWeight: FontWeight.bold)),
            elevation: 2,
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: theme.colorScheme.onPrimary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerFloat,
        );
      },
    );
  }

  // Build the animated progress circle
  Widget _buildProgressCircle(
      BuildContext context, Goal goal, double progress, bool isCompleted) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Background circle
        Container(
          width: 220,
          height: 220,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color:
                Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
            boxShadow: [
              BoxShadow(
                color: goal.color.withOpacity(0.1),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
        ),

        // Progress circle
        SizedBox(
          width: 200,
          height: 200,
          child: TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: progress),
            duration: const Duration(milliseconds: 1200),
            curve: Curves.easeOutQuart,
            builder: (context, value, child) => CircularProgressIndicator(
              value: value,
              strokeWidth: 14,
              strokeCap: StrokeCap.round,
              backgroundColor: goal.color.withOpacity(0.1),
              valueColor: AlwaysStoppedAnimation<Color>(
                isCompleted ? Colors.green : goal.color,
              ),
            ),
          ),
        ),

        // Center content
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon
            Icon(
              goal.icon,
              size: 48,
              color: isCompleted ? Colors.green : goal.color,
            ),
            const SizedBox(height: 8),

            // Progress percentage
            Text(
              '${(progress * 100).toStringAsFixed(0)}%',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
            ),

            // Status text
            Text(
              isCompleted ? 'مكتمل!' : 'في تقدم',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      ],
    );
  }

  // Build the stats row with saved, remaining, and total amounts
  Widget _buildStatsRow(
      Goal goal, NumberFormat format, ThemeData theme, bool isCompleted) {
    final remaining = goal.totalAmount - goal.savedAmount;

    return Builder(
      builder: (context) => Row(
        children: [
          // Saved Amount
          _buildStatCard(
            context,
            title: 'المدخر',
            amount: goal.savedAmount,
            color: isCompleted ? Colors.green : theme.colorScheme.primary,
            format: format,
            icon: Icons.savings_outlined,
          ),

          // Remaining Amount
          _buildStatCard(
            context,
            title: 'المتبقي',
            amount: remaining,
            color: isCompleted ? Colors.grey : Colors.orange,
            format: format,
            icon: Icons.timelapse_outlined,
          ),

          // Total Amount
          _buildStatCard(
            context,
            title: 'الإجمالي',
            amount: goal.totalAmount,
            color: theme.colorScheme.primaryContainer,
            format: format,
            icon: Icons.flag_outlined,
          ),
        ],
      ),
    );
  }

  // Build a single stat card
  Widget _buildStatCard(
    BuildContext context, {
    required String title,
    required double amount,
    required Color color,
    required NumberFormat format,
    required IconData icon,
  }) {
    return Expanded(
      child: GlassCard(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 8),
            Text(
              format.format(amount),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  // Build action buttons row
  Widget _buildActionButtons(
    BuildContext context,
    AppData appData,
    Goal goal,
    bool isCompleted,
    ThemeData theme,
  ) {
    return Row(
      children: [
        // Rocket Boost Button
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              HapticFeedback.mediumImpact();
              _showRocketBoostPanel(context);
            },
            icon: const Icon(Icons.rocket_launch_rounded, size: 20),
            label: const Text('دفعة صاروخية'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
              backgroundColor: theme.colorScheme.primaryContainer,
              foregroundColor: theme.colorScheme.onPrimaryContainer,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
          ),
        ),

        const SizedBox(width: 12),

        // Edit Button
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {
              HapticFeedback.lightImpact();
              // TODO: Implement edit goal functionality
            },
            icon: const Icon(Icons.edit_outlined, size: 20),
            label: const Text('تعديل'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              side: BorderSide(color: theme.colorScheme.outlineVariant),
            ),
          ),
        ),
      ],
    );
  }

  // Build the achieve goal button
  Widget _buildAchieveGoalButton(
    BuildContext context,
    AppData appData,
    Goal goal,
    ThemeData theme,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0, left: 20, right: 20),
      child: SizedBox(
        width: double.infinity,
        child: FilledButton.icon(
          onPressed: () {
            HapticFeedback.mediumImpact();
            _showAchieveGoalConfirmation(context, appData, goal);
          },
          icon: const Icon(Icons.celebration_rounded, size: 20),
          label: const Text('احتفل بتحقيق الهدف!'),
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
      ),
    );
  }

  // Show confirmation dialog for achieving goal
  void _showAchieveGoalConfirmation(
      BuildContext context, AppData appData, Goal goal) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تهانينا! 🎉'),
        content: const Text('هل أنت متأكد أنك تريد الاحتفال بتحقيق هذا الهدف؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: () {
              appData.achieveGoal(goal);
              HapticFeedback.mediumImpact();
              Navigator.pop(context);
              Navigator.pop(context); // Go back to goals list

              // Show success message
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('تهانينا! لقد حققت هدفك بنجاح 🎉'),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  margin: const EdgeInsets.all(16),
                ),
              );
            },
            child: const Text('نعم، حققت الهدف!'),
          ),
        ],
      ),
    );
  }

  // Show bottom sheet for adding to goal
  void _showAddToGoalBottomSheet(
      BuildContext context, Goal goal, AppData appData) {
    final amountController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
            left: 20,
            right: 20,
            top: 24,
          ),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'أضف إلى المدخرات',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),

                // Amount Input
                TextFormField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.done,
                  decoration: InputDecoration(
                    labelText: 'المبلغ',
                    prefixIcon: const Icon(Icons.attach_money_rounded),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    suffixText: 'ريال',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'الرجاء إدخال المبلغ';
                    }
                    final amount = double.tryParse(value);
                    if (amount == null || amount <= 0) {
                      return 'الرجاء إدخال مبلغ صحيح';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 24),

                // Save Button
                FilledButton(
                    onPressed: () {
                      if (formKey.currentState?.validate() ?? false) {
                        final amount =
                            double.tryParse(amountController.text) ?? 0;
                        if (amount > 0) {
                          appData.addSavingsToGoal(goal, amount);
                          HapticFeedback.mediumImpact();
                          Navigator.pop(context);

                          // Show success message
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  'تمت إضافة $amount ريال إلى مدخراتك بنجاح'),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              margin: const EdgeInsets.all(16),
                            ),
                          );
                        }
                      }
                    },
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text('حفظ')),
              ],
            ),
          ),
        );
      },
    );
  }
}

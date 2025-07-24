import 'package:flutter/material.dart';
import 'package:nabd/data/app_data.dart';
import 'package:nabd/features/transactions/models/transaction_model.dart';
import 'package:nabd/theme/app_colors.dart';
import 'package:nabd/theme/app_paddings.dart';
import 'package:nabd/theme/app_text_styles.dart';
import 'package:provider/provider.dart';

// 1. حولنا الويدجت إلى StatefulWidget لإدارة المراحل (اقتراح -> اختيار هدف)
class RoundUpSuggestionCard extends StatefulWidget {
  final Transaction transaction;
  final VoidCallback onDismiss;

  const RoundUpSuggestionCard({
    super.key,
    required this.transaction,
    required this.onDismiss,
  });

  @override
  State<RoundUpSuggestionCard> createState() => _RoundUpSuggestionCardState();
}

class _RoundUpSuggestionCardState extends State<RoundUpSuggestionCard> {
  // 2. متغير حالة جديد لتتبع المرحلة الحالية
  bool _isSelectingGoal = false;

  @override
  Widget build(BuildContext context) {
    final double amount = widget.transaction.amount;
    final double roundUpAmount = (amount / 1000).ceil() * 1000;
    final double difference = roundUpAmount - amount;

    if (difference <= 10) {
      Future.delayed(Duration.zero, widget.onDismiss);
      return const SizedBox.shrink();
    }

    // 3. استخدام AnimatedSwitcher للانتقال السلس بين المرحلتين
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.0, 0.3),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        );
      },
      child: _isSelectingGoal
          ? _buildGoalSelectionView(context, difference)
          : _buildSuggestionView(context, roundUpAmount, difference),
    );
  }

  // ويدجت بناء واجهة الاقتراح (المرحلة الأولى)
  Widget _buildSuggestionView(
      BuildContext context, double roundUpAmount, double difference) {
    return Column(
      key: const ValueKey('suggestion'),
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.savings_outlined,
            size: 64, color: Theme.of(context).colorScheme.primary),
        const SizedBox(height: 16),
        Text('حصالة نبض الذكية',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface)),
        const SizedBox(height: 8),
        Text(
            'ما رأيك في تقريب المبلغ إلى ${roundUpAmount.toStringAsFixed(0)} ريال وادخار ${difference.toStringAsFixed(0)} ريال إضافية?',
          textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              height: 1.5,
              color: Theme.of(context).colorScheme.onSurfaceVariant)),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              setState(() {
                _isSelectingGoal = true;
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 4,
            ),
            child: Text('نعم! أضفها لهدفي',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onPrimary)),
          ),
        ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: widget.onDismiss,
          style: TextButton.styleFrom(
            foregroundColor: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.7),
          ),
          child: Text('لا، شكراً',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.7))),
        ),
      ],
    );
  }

  // ويدجت بناء واجهة اختيار الهدف (المرحلة الثانية)
  Widget _buildGoalSelectionView(BuildContext context, double difference) {
    final appData = Provider.of<AppData>(context, listen: false);
    final goals = appData.goals;

    return Column(
      key: const ValueKey('selection'),
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('اختر الهدف',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface)),
        const SizedBox(height: 16),
        if (goals.isEmpty)
          Text('ليس لديك أهداف لإضافة المبلغ إليها.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant))
        else
          SizedBox(
            height: 180, // Increased height for better scrollability
            child: ListView.builder(
              itemCount: goals.length,
              itemBuilder: (context, index) {
                final goal = goals[index];
                return Card(
                  color: Theme.of(context).cardColor, // Use theme card color
                  margin: const EdgeInsets.symmetric(vertical: 6), // Consistent spacing
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), // Rounded corners
                  elevation: 2, // Subtle shadow
                  child: ListTile(
                    leading: Icon(goal.icon, color: goal.color, size: 30), // Larger icon
                    title: Text(goal.name,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.onSurface)),
                    trailing: Icon(Icons.arrow_forward_ios, size: 18, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)),
                    onTap: () {
                      appData.addSavingsToGoal(goal, difference);
                      widget.onDismiss();
                    },
                  ),
                );
              },
            ),
          ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: () {
            setState(() {
              _isSelectingGoal = false;
            });
          },
          style: TextButton.styleFrom(
            foregroundColor: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.7),
          ),
          child: Text('رجوع',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.7))),
        ),
      ],
    );
  }
}

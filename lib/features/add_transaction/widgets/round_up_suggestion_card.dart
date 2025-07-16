import 'package:flutter/material.dart';
import 'package:nabd/data/app_data.dart';
import 'package:nabd/features/transactions/models/transaction_model.dart';
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
            size: 60, color: Theme.of(context).primaryColor),
        const SizedBox(height: 16),
        const Text('حصالة نبض الذكية',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Text(
          'ما رأيك في تقريب المبلغ إلى ${roundUpAmount.toStringAsFixed(0)} ريال وادخار ${difference.toStringAsFixed(0)} ريال إضافية؟',
          textAlign: TextAlign.center,
          style: TextStyle(
              fontSize: 16,
              height: 1.5,
              color: Theme.of(context).textTheme.bodyMedium?.color),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              // 4. عند الضغط، ننتقل إلى مرحلة اختيار الهدف
              setState(() {
                _isSelectingGoal = true;
              });
            },
            child: const Text('نعم! أضفها لهدفي'),
          ),
        ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: widget.onDismiss,
          child: Text('لا، شكراً',
              style: TextStyle(
                  color: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.color
                      ?.withOpacity(0.7))),
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
        const Text('اختر الهدف',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        if (goals.isEmpty)
          const Text('ليس لديك أهداف لإضافة المبلغ إليها.')
        else
          // 5. بناء قائمة الأهداف القابلة للاختيار
          SizedBox(
            height: 150, // تحديد ارتفاع لتجنب الأخطاء
            child: ListView.builder(
              itemCount: goals.length,
              itemBuilder: (context, index) {
                final goal = goals[index];
                return Card(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  child: ListTile(
                    leading: Icon(goal.icon, color: goal.color),
                    title: Text(goal.name),
                    onTap: () {
                      // 6. عند اختيار الهدف، ننفذ الإجراء ونغلق الواجهة
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
            // العودة إلى شاشة الاقتراح
            setState(() {
              _isSelectingGoal = false;
            });
          },
          child: Text('رجوع',
              style: TextStyle(
                  color: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.color
                      ?.withOpacity(0.7))),
        ),
      ],
    );
  }
}

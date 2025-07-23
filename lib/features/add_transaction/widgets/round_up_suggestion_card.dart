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
            size: AppPaddings.largeIconSize, color: AppColors.primaryColor),
        AppPaddings.mediumHeight,
        Text('حصالة نبض الذكية',
            style: AppTextStyles.headline2.copyWith(
                fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
        AppPaddings.mediumHeight,
        Text(
            'ما رأيك في تقريب المبلغ إلى ${roundUpAmount.toStringAsFixed(0)} ريال وادخار ${difference.toStringAsFixed(0)} ريال إضافية?',
          textAlign: TextAlign.center,
            style: AppTextStyles.bodyText2
                .copyWith(
              height: 1.5,
              color: AppColors.textSecondary)),
        AppPaddings.largeHeight,
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
        AppPaddings.smallHeight,
        TextButton(
          onPressed: widget.onDismiss,
          child: Text('لا، شكراً',
              style: AppTextStyles.bodyText2
                  .copyWith(color: AppColors.textSecondary.withOpacity(0.7))),
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
            style: AppTextStyles.headline2.copyWith(
                fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
        AppPaddings.mediumHeight,
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
                  color: AppColors.cardLight,
                  margin: EdgeInsets.symmetric(vertical: AppPaddings.tiny.vertical),
                  child: ListTile(
                    leading: Icon(goal.icon, color: goal.color),
                    title: Text(goal.name,
                        style: AppTextStyles.bodyText1
                            .copyWith(color: AppColors.textPrimary)),
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
        AppPaddings.mediumHeight,
        TextButton(
          onPressed: () {
            // العودة إلى شاشة الاقتراح
            setState(() {
              _isSelectingGoal = false;
            });
          },
          child: Text('رجوع',
              style: AppTextStyles.bodyText2
                  .copyWith(color: AppColors.textSecondary.withOpacity(0.7))),
        ),
      ],
    );
  }
}

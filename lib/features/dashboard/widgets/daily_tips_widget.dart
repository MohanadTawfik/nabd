import 'package:flutter/material.dart';
import 'package:nabd/widgets/glass_card.dart';
import 'package:nabd/theme/app_paddings.dart';
import 'package:nabd/theme/app_text_styles.dart';
import 'package:nabd/theme/app_colors.dart';

/// Widget displaying a daily tip with an icon and micro-animation.
class DailyTipsWidget extends StatefulWidget {
  const DailyTipsWidget({Key? key}) : super(key: key);

  @override
  _DailyTipsWidgetState createState() => _DailyTipsWidgetState();
}

class _DailyTipsWidgetState extends State<DailyTipsWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _controller.reverse();
        } else if (status == AnimationStatus.dismissed) {
          _controller.forward();
        }
      });
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.1)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: AppPaddings.allMedium,
      child: Row(
        children: [
          ScaleTransition(
            scale: _scaleAnimation,
            child: Icon(
              Icons.lightbulb_outline,
              color: AppColors.primaryColor,
              size: 28,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'نصيحة اليوم: احفظ 10% من دخلك لتسريع تحقيق أهدافك!',
              style: AppTextStyles.bodyText1.copyWith(
                  color: Theme.of(context).textTheme.bodyLarge?.color),
            ),
          ),
        ],
      ),
    );
  }
}

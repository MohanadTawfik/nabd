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

class _DailyTipsWidgetState extends State<DailyTipsWidget> {


  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: AppPaddings.allMedium,
      child: Row(
        children: [
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'نصيحة اليوم: احفظ 10% من دخلك لتسريع تحقيق أهدافك!',
              style: AppTextStyles.bodyLarge.copyWith(
                  color: Theme.of(context).textTheme.bodyLarge?.color),
            ),
          ),
        ],
      ),
    );
  }
}

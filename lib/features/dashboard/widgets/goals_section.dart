import 'package:flutter/material.dart';
import 'package:nabd/theme/app_paddings.dart';
import 'package:nabd/theme/app_text_styles.dart';
import 'package:nabd/theme/app_colors.dart';
import 'goal_item_widget.dart';

class GoalsSection extends StatelessWidget {
  const GoalsSection({super.key});

  @override
  Widget build(BuildContext context) {
    // بيانات مؤقتة للأهداف
    final goals = [
      {'name': 'سيارة جديدة', 'icon': Icons.directions_car, 'progress': 0.75},
      {'name': 'السفر', 'icon': Icons.airplanemode_active, 'progress': 0.4},
      {'name': 'لابتوب', 'icon': Icons.laptop_mac, 'progress': 0.9},
      {'name': 'إضافة هدف', 'icon': Icons.add, 'progress': 0.0},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'سباق الأهداف',
          style: AppTextStyles.headline2.copyWith(color: AppColors.textLight),
        ),
        AppPaddings.mediumHeight,
        SizedBox(
          height: 110, // ارتفاع محدد للقائمة الأفقية
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: goals.length,
            separatorBuilder: (context, index) => AppPaddings.mediumWidth,
            itemBuilder: (context, index) {
              final goal = goals[index];
              return GoalItemWidget(
                name: goal['name'] as String,
                icon: goal['icon'] as IconData,
                progress: goal['progress'] as double,
              );
            },
          ),
        ),
      ],
    );
  }
}

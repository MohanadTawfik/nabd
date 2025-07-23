import 'package:flutter/material.dart';

import 'package:nabd/theme/app_paddings.dart';
import 'package:nabd/theme/app_text_styles.dart';
import 'package:nabd/theme/app_colors.dart';

class GoalItemWidget extends StatelessWidget {
  final String name;
  final IconData icon;
  final double progress;

  const GoalItemWidget({
    super.key,
    required this.name,
    required this.icon,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 70,
          height: 70,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // هذه هي "الهالة المضيئة" التي تمثل التقدم
              CircularProgressIndicator(
                value: progress,
                strokeWidth: 5,
                backgroundColor: AppColors.textLight.withOpacity(0.1),
                valueColor:
                    const AlwaysStoppedAnimation<Color>(AppColors.accentColor),
              ),
              // هذا هو "الكوكب" الذي يحتوي على الأيقونة
              Center(
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: AppColors.cardDark,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: AppColors.textSecondary, size: 28),
                ),
              ),
            ],
          ),
        ),
        AppPaddings.smallHeight,
        Text(name, style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
      ],
    );
  }
}

import 'package:flutter/material.dart';

import 'package:nabd/theme/app_paddings.dart';
import 'package:nabd/theme/app_text_styles.dart';
import 'package:nabd/theme/app_colors.dart';

class PlaceholderCard extends StatelessWidget {
  final String title;
  const PlaceholderCard({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.cardDark,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: double.infinity,
        padding: AppPaddings.allLarge,
        child: Center(
          child: Text(
            title,
            style: AppTextStyles.bodyText1.copyWith(color: AppColors.textSecondary),
          ),
        ),
      ),
    );
  }
}

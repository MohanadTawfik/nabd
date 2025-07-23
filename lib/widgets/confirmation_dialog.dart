import 'package:flutter/material.dart';

import 'package:nabd/theme/app_colors.dart';
import 'package:nabd/theme/app_paddings.dart';
import 'package:nabd/theme/app_text_styles.dart';

class ConfirmationDialog extends StatelessWidget {
  final String title;
  final String content;
  final VoidCallback onConfirm;

  const ConfirmationDialog({
    super.key,
    required this.title,
    required this.content,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.cardLight,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(title,
          style: AppTextStyles.headline2.copyWith(color: AppColors.textLight)),
      content: Text(content,
          style: AppTextStyles.bodyText1.copyWith(color: AppColors.textLight)),
      actions: <Widget>[
        TextButton(
          child: Text('إلغاء',
              style: AppTextStyles.buttonText
                  .copyWith(color: AppColors.textSecondary)),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.expenseColor,
            foregroundColor: AppColors.textLight,
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          
          onPressed: onConfirm,
          child: Text('تأكيد الحذف', style: AppTextStyles.buttonText),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:animated_digit/animated_digit.dart';
import 'package:nabd/widgets/glass_card.dart';
import 'package:nabd/theme/app_paddings.dart';
import 'package:nabd/theme/app_text_styles.dart';

/// Animated display for the current balance.
class AnimatedBalanceCard extends StatelessWidget {
  final double balance;
  const AnimatedBalanceCard({Key? key, required this.balance})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: AppPaddings.allMedium,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('الرصيد الحالي',
              style: AppTextStyles.displaySmall.copyWith(
                  color: Theme.of(context).textTheme.bodyLarge?.color)),
          AppPaddings.smallHeight,
          Row(
            children: [
              Directionality(
                textDirection: TextDirection.ltr,
                child: AnimatedDigitWidget(
                  value: balance,
                  textStyle: AppTextStyles.displayMedium.copyWith(
                      color: Theme.of(context).textTheme.bodyLarge?.color),
                  duration: const Duration(milliseconds: 800),
                  fractionDigits: 0,
                  enableSeparator: true,
                ),
              ),
              AppPaddings.smallWidth,
              Text('ريال',
                  style: AppTextStyles.displaySmall.copyWith(
                      color: Theme.of(context).textTheme.bodyLarge?.color)),
            ],
          ),
        ],
      ),
    );
  }
}

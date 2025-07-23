import 'package:animated_digit/animated_digit.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nabd/data/app_data.dart';
import 'package:nabd/theme/app_colors.dart';
import 'package:nabd/theme/app_text_styles.dart';
import 'package:nabd/theme/app_paddings.dart';
import 'package:provider/provider.dart';
import 'package:simple_gradient_text/simple_gradient_text.dart';
import 'dart:ui' as ui;

// 1. أعدنا الويدجت إلى StatefulWidget مع SingleTickerProviderStateMixin
class FinancialPulseWidget extends StatefulWidget {
  const FinancialPulseWidget({super.key});

  @override
  State<FinancialPulseWidget> createState() => _FinancialPulseWidgetState();
}

class _FinancialPulseWidgetState extends State<FinancialPulseWidget>
    with SingleTickerProviderStateMixin {
  // 2. أعدنا متحكم الأنيميشن
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  

  @override
  void initState() {
    super.initState();
    // 3. قمنا بإعداد الأنيميشن ليعمل بشكل متكرر
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
List<Color> _getPulseColors(double expenseRatio) {
    final color = Color.lerp(AppColors.incomeColor, AppColors.expenseColor,
        expenseRatio.clamp(0.0, 1.0))!;
    return [color.withOpacity(0.8), color];
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppData>(
      builder: (context, appData, child) {
        final expenseRatio = appData.totalIncome > 0
            ? appData.totalExpense / appData.totalIncome
            : 0.0;
        final pulseColors = _getPulseColors(expenseRatio);
        final score = appData.financialHealthScore;
        final format = NumberFormat("#,##0", "en_US");
        final balance = appData.currentBalance;

        // 2. حساب نسبة الإنفاق (المصروف / الدخل)
       
        return AnimatedBuilder(
          animation: _controller,
          builder: (context, animChild) {

            return Center(
              child: Transform.scale(
                scale: _scaleAnimation.value,
                child: animChild,
              ),
            );
          },
          child: AnimatedContainer(
            // 3. استخدام AnimatedContainer لتغيير اللون بسلاسة
            duration: const Duration(milliseconds: 800),
            width: 250,
            height: 250,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                // 4. استخدام الألوان الديناميكية
                colors: pulseColors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: pulseColors.last.withOpacity(0.4), // الظل أيضاً يتغير
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 1. أيقونة تتطور مع المستوى
                  if (score > 0.7)
                    Icon(Icons.star,
                        color: Colors.amber.withOpacity(0.5), size: 24)
                  else if (score > 0.3)
                    Icon(Icons.local_florist,
                        color: Colors.green.withOpacity(0.5), size: 24),

                  Text('رصيدك الحالي',
                      style: AppTextStyles.bodyText2.copyWith(color: AppColors.textLight)),
                  AppPaddings.smallHeight,

                  Directionality(
                    // 2. هذا هو الإصلاح: نحدد بوضوح أننا نريد TextDirection من مكتبة ui
                    textDirection: ui.TextDirection.ltr,
                    child: AnimatedDigitWidget(
                      value: balance,
                      textStyle: AppTextStyles.headline1.copyWith(color: AppColors.textLight),
                      fractionDigits: 0,
                      duration: const Duration(milliseconds: 500),
                      enableSeparator: true,
                    ),
                  ),
                  Text('ريال يمني',
                      style: AppTextStyles.bodyText2.copyWith(color: AppColors.textLight)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

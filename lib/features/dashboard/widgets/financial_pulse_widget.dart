import 'package:animated_digit/animated_digit.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nabd/data/app_data.dart';
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

  // 1. دالة ذكية لتحديد اللون بناءً على نسبة الإنفاق
  List<Color> _getPulseColors(double expenseRatio) {
    // Color.lerp تقوم بالدمج بين لونين بناءً على نسبة
    // إذا كانت النسبة 0 (لم يصرف شيء)، يكون اللون أخضر بالكامل
    // إذا كانت النسبة 1 (صرف كل دخله)، يكون اللون أحمر بالكامل
    // وما بينهما هو تدرج جميل
    final color = Color.lerp(Colors.green.shade400, Colors.red.shade400,
        expenseRatio.clamp(0.0, 1.0))!;
    return [color.withOpacity(0.8), color];
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppData>(
      builder: (context, appData, child) {
        final format = NumberFormat("#,##0", "en_US");
        final balance = appData.currentBalance;

        // 2. حساب نسبة الإنفاق (المصروف / الدخل)
        final expenseRatio = appData.totalIncome > 0
            ? appData.totalExpense / appData.totalIncome
            : 0.0;
        final pulseColors = _getPulseColors(expenseRatio);

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
                  color: pulseColors.last
                      .withOpacity(0.4), // الظل أيضاً يأخذ اللون الجديد
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('رصيدك الحالي',
                      style: TextStyle(color: Colors.white70, fontSize: 18)),
                  const SizedBox(height: 8),

                  Directionality(
                    // 2. هذا هو الإصلاح: نحدد بوضوح أننا نريد TextDirection من مكتبة ui
                    textDirection: ui.TextDirection.ltr,
                    child: AnimatedDigitWidget(
                      value: balance,
                      textStyle: const TextStyle(
                          color: Colors.white,
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Tajawal'),
                      fractionDigits: 0,
                      duration: const Duration(milliseconds: 500),
                      enableSeparator: true,
                    ),
                  ),
                  const Text('ريال يمني',
                      style: TextStyle(color: Colors.white70, fontSize: 16)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

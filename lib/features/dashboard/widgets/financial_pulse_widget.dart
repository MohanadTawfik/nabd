import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nabd/data/app_data.dart';
import 'package:provider/provider.dart';

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

  @override
  Widget build(BuildContext context) {
    // 4. نستخدم Consumer هنا للاستماع للتغيرات في AppData
    return Consumer<AppData>(
      builder: (context, appData, child) {
        final format = NumberFormat("#,##0", "en_US");
        final balance = appData.currentBalance;

        // 5. نمرر الـ child الذي يحتوي على الأنيميشن
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
          // 6. الـ child هنا هو الـ Container الذي يعرض البيانات الحقيقية
          child: Container(
            width: 250,
            height: 250,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [Color(0xff1fddff), Color(0xff8952ff)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xff8952ff).withOpacity(0.4),
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
                  Text(
                    format.format(balance), // الرقم الآن حقيقي!
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 40,
                        fontWeight: FontWeight.bold),
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

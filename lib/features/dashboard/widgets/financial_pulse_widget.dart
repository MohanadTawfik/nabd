import 'package:flutter/material.dart';

// 1. حولنا الويدجت إلى StatefulWidget ليتمكن من تغيير حالته (حجمه) مع الوقت
class FinancialPulseWidget extends StatefulWidget {
  const FinancialPulseWidget({super.key});

  @override
  State<FinancialPulseWidget> createState() => _FinancialPulseWidgetState();
}

// 2. أضفنا 'with SingleTickerProviderStateMixin' لنجعل الأنيميشن سلساً ومتزامناً مع الشاشة
class _FinancialPulseWidgetState extends State<FinancialPulseWidget>
    with SingleTickerProviderStateMixin {
  // 3. عرفنا متغيرين للتحكم في الأنيميشن
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    // 4. قمنا بإعداد المتحكم في الأنيميشن هنا
    _controller = AnimationController(
      vsync: this, // لربط الأنيميشن بالشاشة
      duration: const Duration(seconds: 2), // مدة النبضة الواحدة ثانيتان
    );
    // _controller = AnimationController(
    //   vsync: this, // لربط الأنيميشن بالشاشة
    //   duration: const Duration(seconds: 2), // مدة النبضة الواحدة ثانيتان
    // )..repeat(
    //     reverse: true); // ..repeat يجعل الأنيميشن يتكرر ذهاباً وإياباً بلا توقف

    // 5. قمنا بتعريف كيف سيتغير حجم الدائرة
    // Tween تحدد القيمة الابتدائية (1.0 = الحجم الطبيعي) والقيمة النهائية (1.05 = أكبر بـ 5%)
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      // نستخدم CurvedAnimation لجعل الحركة تبدو طبيعية (تبدأ ببطء ثم تسرع ثم تبطئ)
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    // 6. من المهم جداً التخلص من المتحكم عند إغلاق الشاشة لمنع استهلاك الذاكرة
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 7. نستخدم AnimatedBuilder ليقوم بإعادة بناء الدائرة في كل مرة تتغير فيها قيمة الأنيميشن
    return Center(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          // 8. نستخدم Transform.scale لتطبيق التكبير والتصغير على الدائرة
          return Transform.scale(
            scale: _scaleAnimation.value, // القيمة تأتي مباشرة من الأنيميشن
            child: child, // child هنا هو الـ Container الذي يحتوي على الدائرة
          );
        },
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
              children: const [
                Text('رصيدك الحالي',
                    style: TextStyle(color: Colors.white70, fontSize: 18)),
                SizedBox(height: 8),
                Text('٢٥٠,٠٠٠',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 40,
                        fontWeight: FontWeight.bold)),
                Text('ريال يمني',
                    style: TextStyle(color: Colors.white70, fontSize: 16)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// glass_card.dart
import 'dart:ui';
import 'package:flutter/material.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final double borderRadius;
  final double blurStrength;
  final double opacity; // درجة الشفافية الافتراضية

  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16.0),
    this.borderRadius = 12.0,
    this.blurStrength = 10.0, // تم تخفيض قوة التمويه قليلاً
    this.opacity = 0.2, // تم زيادة الشفافية الافتراضية قليلاً
  });

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;

    // تحديد ألوان البطاقة بناءً على الثيم ودرجة الشفافية
    Color baseColor = isLight ? Colors.white : Colors.black;
    Color gradientStart =
        baseColor.withOpacity(opacity + (isLight ? 0.05 : 0.0)); // تدرج خفيف
    Color gradientEnd =
        baseColor.withOpacity(opacity + (isLight ? 0.1 : 0.05)); // تدرج خفيف

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: blurStrength,
          sigmaY: blurStrength,
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(borderRadius),
            // لون زجاجي مع Gradient خفيف
            gradient: LinearGradient(
              colors: [
                gradientStart,
                gradientEnd,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            // إطار خفيف شفاف
            border: Border.all(
              color: isLight
                  ? Colors.white.withOpacity(0.5) // تم تعديل الشفافية
                  : Colors.white
                      .withOpacity(0.1), // تم تخفيض الشفافية في الوضع الداكن
              width: 1,
            ),
            // إضافة ظل خفيف للبطاقة
            boxShadow: [
              BoxShadow(
                color: (isLight ? Colors.black : Colors.black)
                    .withOpacity(0.1), // لون الظل
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          padding: padding,
          child: child,
        ),
      ),
    );
  }
}

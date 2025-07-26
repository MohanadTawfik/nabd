// glass_background.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:nabd/theme/app_colors.dart';

class GlassBackground extends StatelessWidget {
  final Widget child;

  const GlassBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;

    return Stack(
      children: [
        // الخلفية الأساسية بلون الثيم
        Positioned.fill(
          child: Container(
            color:
                isLight ? AppColors.backgroundLight : AppColors.backgroundDark,
          ),
        ),
        // دوائر الإضاءة
        Positioned(
          top: -150, // تم تعديل الموضع
          left: -150, // تم تعديل الموضع
          child: _buildCircle(
            400, // تم تصغير الحجم قليلاً
            isLight
                ? AppColors.primaryLight.withOpacity(0.3)
                : AppColors.primaryDark
                    .withOpacity(0.3), // استخدام ألوان الثيم الأساسية
          ),
        ),
        Positioned(
          bottom: -100, // تم تعديل الموضع
          right: -100, // تم تعديل الموضع
          child: _buildCircle(
            350, // تم تصغير الحجم قليلاً
            isLight
                ? AppColors.accentColor.withOpacity(0.3)
                : AppColors.accentColor
                    .withOpacity(0.2), // استخدام لون مميز ولكن أخف
          ),
        ),
        // طبقة الزجاج (التأثير الشفاف)
        Positioned.fill(
          child: ClipRRect(
            borderRadius:
                BorderRadius.circular(0), // لا نحتاج إلى حواف مدورة هنا
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
              child: Container(
                color: isLight
                    ? Colors.white.withOpacity(0.05) // تم زيادة الشفافية قليلاً
                    : Colors.black.withOpacity(
                        0.1), // تم زيادة الشفافية قليلاً في الوضع الداكن
              ),
            ),
          ),
        ),

        // محتوى الشاشة فوق الخلفية
        SafeArea(child: child),
      ],
    );
  }

  Widget _buildCircle(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color, // استخدام اللون مباشرة مع الشفافية المحددة
      ),
    );
  }
}

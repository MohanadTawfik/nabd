import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:nabd/theme/app_colors.dart';

class GlassBackground extends StatelessWidget {
  final Widget child;

  const GlassBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // خلفية الدوائر
        Positioned.fill(
          child: Container(
            color: Theme.of(context).brightness == Brightness.light
                ? AppColors.backgroundLight
                : AppColors.backgroundDark,
            child: Stack(
              children: [
                // الدائرة العلوية اليسرى
                Positioned(
                  top: -100,
                  left: -250,
                  child: _buildCircle(460, Colors.blue),
                ),
                // الدائرة الوسطى اليمنى (لون مختلف)
                Positioned(
                  top: 300,
                  right: -250,
                  child: _buildCircle(400, Colors.pink),
                ),
                // الدائرة السفلية اليسرى
                Positioned(
                  bottom: -100,
                  left: -250,
                  child: _buildCircle(450, Colors.blue),
                ),
              ],
            ),
          ),
        ),
        // خلفية الصورة
        // Positioned.fill(
        //   child: Container(
        //     decoration: BoxDecoration(
        //       image: DecorationImage(
        //         image: AssetImage('assets/images/bg.jpg'),
        //         fit: BoxFit.cover,
        //       ),
        //     ),
        //   ),
        // ),
        // طبقة الزجاج
        Positioned.fill(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(0),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),
              child: Container(
                color: Theme.of(context).brightness == Brightness.light
                    ? Colors.white.withValues(alpha: 0.01)
                    : Colors.black.withValues(alpha: 0.01), // شفافية الزجاج
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
        gradient: LinearGradient(
          colors: [
            color.withValues(alpha: 0.7),
            color.withValues(alpha: 0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
    );
  }
}

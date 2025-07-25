import 'dart:ui';
import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:flutter/material.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final double borderRadius;
  final double blurStrength;
  final double opacity;

  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16.0),
    this.borderRadius = 12.0,
    this.blurStrength = 25.0,
    this.opacity = 0.15, // درجة الشفافية الافتراضية
  });

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;

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
                (isLight ? Colors.white : Colors.black)
                    .withValues(alpha: opacity + 0.2),
                (isLight ? Colors.white : Colors.black)
                    .withValues(alpha: opacity + 0.2),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            // إطار خفيف شفاف
            border: Border.all(
              color: Theme.of(context).brightness == Brightness.light
                  ? Colors.white.withValues(alpha: 0.35)
                  : Colors.white.withValues(alpha: 0.15),
              width: 1,
            ),
          ),
          padding: padding,
          child: child,
        ),
      ),
    );
  }
}

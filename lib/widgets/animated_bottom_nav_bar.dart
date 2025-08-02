import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:nabd/theme/app_colors.dart';
import 'package:nabd/utils/animation_config.dart';

/// A modern glassmorphic bottom navigation bar with a centered FAB.
class AnimatedBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemSelected;
  final VoidCallback? onAddPressed;

  const AnimatedBottomNavBar({
    Key? key,
    required this.selectedIndex,
    required this.onItemSelected,
    this.onAddPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // تحديد لون خلفية الشريط بناءً على الثيم
    final Color barGlassBaseColor = isDark ? Colors.black : Colors.white;
    final double barGlassOpacity =
        isDark ? 0.4 : 0.7; // زيادة التباين للحصول على مظهر أكثر وضوحاً

    return Stack(
      alignment: Alignment.center,
      children: [
        // Main navigation bar with enhanced glass effect
        ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(
                sigmaX: 20.0, sigmaY: 20.0), // تمويه أعلى لعمق أفضل
            child: Container(
              height: 100,
              decoration: BoxDecoration(
                color: barGlassBaseColor.withOpacity(barGlassOpacity),
                border: Border(
                  // حد علوي خفيف جداً
                  top: BorderSide(
                    color: isDark
                        ? Colors.white.withOpacity(0.08) // شفافية أقل
                        : Colors.black.withOpacity(0.08),
                    width: 0.5,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavItem(0, Icons.home_outlined, 'الرئيسية', context),
                  _buildNavItem(
                      1, Icons.pie_chart_outline_rounded, 'الميزانية', context),
                  const SizedBox(width: 64), // Space for FAB
                  _buildNavItem(
                      2, Icons.bar_chart_outlined, 'التقارير', context),
                  _buildNavItem(
                      3, Icons.settings_outlined, 'الإعدادات', context),
                ],
              ),
            ),
          ),
        ),

        // Enhanced Floating Action Button with improved visibility and effects
        Positioned(
          bottom: 15,
          child: GestureDetector(
            onTap: onAddPressed,
            child: _buildFabContainer(context),
          ),
        ),
      ],
    );
  }

  Widget _buildFabContainer(BuildContext context) {
    return Container(
        height: 62, // حجم أكبر قليلاً
        width: 62,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.primaryColor,
              AppColors.accentColor.withOpacity(0.9),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white.withOpacity(0.2),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryColor.withOpacity(0.4),
              blurRadius: 15,
              spreadRadius: 1,
              offset: const Offset(0, 2),
            ),
            BoxShadow(
              color: AppColors.accentColor.withOpacity(0.3),
              blurRadius: 10,
              spreadRadius: 0,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: MouseRegion(
          onEnter: (_) {
            // This would be used if we implement hover animations
          },
          onExit: (_) {
            // This would be used if we implement hover animations
          },
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Enhanced glow effect
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  gradient: RadialGradient(
                    colors: [
                      Colors.white.withOpacity(0.6),
                      Colors.white.withOpacity(0.2),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.3, 1.0],
                    radius: 0.6,
                    center: Alignment.center,
                  ),
                ),
              ),
              // Enhanced icon with shadow
              ShaderMask(
                shaderCallback: (Rect bounds) {
                  return LinearGradient(
                    colors: [Colors.white, Colors.white.withOpacity(0.8)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ).createShader(bounds);
                },
                child: const Icon(
                  Icons.add_rounded,
                  color: Colors.white,
                  size: 34,
                ),
              ),
            ],
          ),
        ));
  }

  Widget _buildNavItem(
      int index, IconData icon, String label, BuildContext context) {
    final isSelected = selectedIndex == index;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => onItemSelected(index),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 75,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    isSelected
                        ? AppColors.primaryLight
                            .withOpacity(isDark ? 0.25 : 0.15)
                        : (isDark
                            ? Colors.white.withOpacity(0.05)
                            : Colors.black.withOpacity(0.02)),
                    isSelected
                        ? AppColors.primaryColor
                            .withOpacity(isDark ? 0.35 : 0.25)
                        : (isDark
                            ? Colors.white.withOpacity(0.02)
                            : Colors.black.withOpacity(0.01)),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(18),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppColors.primaryColor.withOpacity(0.3),
                          blurRadius: 12,
                          spreadRadius: 1,
                          offset: const Offset(0, 3),
                        )
                      ]
                    : null,
                border: Border.all(
                  color: isSelected
                      ? AppColors.primaryColor.withOpacity(0.5)
                      : (isDark
                          ? Colors.white.withOpacity(0.08)
                          : Colors.black.withOpacity(0.05)),
                  width: isSelected ? 1.0 : 0.5,
                ),
              ),
              child: Icon(
                icon,
                size: 24,
                color: isSelected
                    ? AppColors.primaryColor
                    : (isDark ? AppColors.iconDark : AppColors.iconLight),
              ),
            ),
            const SizedBox(height: 6),
            DefaultTextStyle(
              style: theme.textTheme.bodySmall?.copyWith(
                    color: isSelected
                        ? AppColors.primaryColor
                        : (isDark
                            ? AppColors.subtextDark
                            : AppColors.subtextLight),
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.normal,
                    fontSize: isSelected ? 12 : 11,
                    letterSpacing: isSelected ? 0.2 : 0.0,
                    height: 1.2,
                  ) ??
                  const TextStyle(),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }
}

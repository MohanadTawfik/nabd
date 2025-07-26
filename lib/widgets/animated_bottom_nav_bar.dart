import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:nabd/theme/app_colors.dart';

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
        isDark ? 0.35 : 0.65; // شفافية أعلى قليلاً من 0.3 للوضوح

    return Stack(
      alignment: Alignment.center,
      children: [
        // Main navigation bar with glass effect
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
                      1, Icons.bar_chart_outlined, 'التقارير', context),
                  const SizedBox(width: 64), // Space for FAB
                  _buildNavItem(2, Icons.wallet_outlined, 'المحفظات', context),
                  _buildNavItem(
                      3, Icons.settings_outlined, 'الإعدادات', context),
                ],
              ),
            ),
          ),
        ),

        // Floating Action Button with enhanced visibility
        Positioned(
          // bottom: 20, // ارتفاع ثابت من الأسفل
          child: GestureDetector(
            onTap: onAddPressed,
            child: Container(
              height: 60, // حجم أكبر
              width: 60,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primaryColor.withValues(alpha: 0.5),
                    AppColors.primaryDark.withValues(alpha: 0.5),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryColor.withOpacity(0.45),
                    blurRadius: 15,
                    spreadRadius: 2,
                    offset: const Offset(0, 4),
                  ),
                ],
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 1.5,
                ),
              ),

              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Glow effect
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.rectangle,
                      gradient: RadialGradient(
                        colors: [
                          Colors.white.withOpacity(0.4),
                          Colors.transparent,
                        ],
                        radius: 0.7,
                      ),
                    ),
                  ),
                  // Icon with shadow
                  Icon(
                    Icons.add_rounded,
                    color: Colors.white.withValues(alpha: 0.7),
                    size: 32,
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
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
        width: 75, // عرض أكبر قليلاً للعنصر
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Glass effect container for icon
            AnimatedContainer(
              // استخدام AnimatedContainer للحركات
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    isSelected
                        ? AppColors.primaryLight.withOpacity(
                            isDark ? 0.2 : 0.1) // ألوان من AppColors
                        : (isDark
                            ? Colors.white.withOpacity(0.05)
                            : Colors.black.withOpacity(0.02)),
                    isSelected
                        ? AppColors.primaryColor.withOpacity(
                            isDark ? 0.3 : 0.2) // ألوان من AppColors
                        : (isDark
                            ? Colors.white.withOpacity(0.02)
                            : Colors.black.withOpacity(0.01)),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius:
                    BorderRadius.circular(16), // حواف دائرية أكبر قليلاً
                border: Border.all(
                  color: isSelected
                      ? AppColors.primaryColor
                          .withOpacity(0.4) // حد أقوى للمختار
                      : (isDark
                          ? Colors.white
                              .withOpacity(0.08) // حد خفيف لغير المختار
                          : Colors.black.withOpacity(0.05)),
                  width: 0.5,
                ),
                boxShadow: isSelected
                    ? [
                        // ظل خفيف للعنصر المختار
                        BoxShadow(
                          color: AppColors.primaryColor.withOpacity(0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              child: Icon(
                icon,
                size: 24, // حجم أيقونة ثابت وواضح
                color: isSelected
                    ? AppColors.primaryColor // لون أيقونة الثيم الأساسي
                    : (isDark
                        ? AppColors
                            .iconDark // لون أيقونة الثيم الداكن لغير المختار
                        : AppColors
                            .iconLight), // لون أيقونة الثيم الفاتح لغير المختار
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                // استخدام labelSmall من AppTextStyles
                color: isSelected
                    ? AppColors.primaryColor // لون نص الثيم الأساسي
                    : (isDark
                        ? AppColors
                            .subtextDark // لون نص الثيم الداكن لغير المختار
                        : AppColors
                            .subtextLight), // لون نص الثيم الفاتح لغير المختار
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

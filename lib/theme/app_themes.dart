// app_themes.dart
import 'package:flutter/material.dart';
import 'package:nabd/theme/app_colors.dart';
import 'package:nabd/theme/app_text_styles.dart';

class AppThemes {
  // ================== Dark Theme ==================
  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    fontFamily: 'Cairo',
    primaryColor: AppColors.primaryColor,
    primaryColorLight: AppColors.primaryLight,
    primaryColorDark: AppColors.primaryDark,
    scaffoldBackgroundColor: Colors
        .transparent, // تم تعيينها شفافة لأن الخلفية الزجاجية هي من تتحكم باللون
    cardColor: AppColors.cardDark,
    dividerColor: AppColors.dividerDark,
    splashFactory: InkRipple.splashFactory,
    visualDensity: VisualDensity.adaptivePlatformDensity,
    colorScheme: const ColorScheme.dark().copyWith(
      primary: AppColors.primaryColor,
      onPrimary: AppColors.textDark,
      secondary: AppColors.accentColor,
      onSecondary: AppColors.textDark,
      surface: AppColors.cardDark,
      onSurface: AppColors.textDark,
      background: AppColors.backgroundDark, // هذه تستخدم في بعض Widgets
      onBackground: AppColors.textDark,
      error: AppColors.errorColor,
      onError: AppColors.textDark,
      brightness: Brightness.dark,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent, // AppBar دائمًا شفاف
      elevation: 0,
      centerTitle: false,
      titleTextStyle: AppTextStyles.displayMedium // استخدام النمط الجديد
          .copyWith(color: AppColors.textDark),
      iconTheme: const IconThemeData(color: AppColors.textDark),
    ),
    iconTheme:
        const IconThemeData(color: AppColors.iconDark), // استخدام iconDark
    textTheme: TextTheme(
      displayLarge:
          AppTextStyles.displayLarge.copyWith(color: AppColors.textDark),
      displayMedium:
          AppTextStyles.displayMedium.copyWith(color: AppColors.textDark),
      displaySmall:
          AppTextStyles.displaySmall.copyWith(color: AppColors.textDark),
      headlineMedium:
          AppTextStyles.headlineMedium.copyWith(color: AppColors.textDark),
      headlineSmall:
          AppTextStyles.headlineSmall.copyWith(color: AppColors.textDark),
      bodyLarge: AppTextStyles.bodyLarge.copyWith(color: AppColors.subtextDark),
      bodyMedium:
          AppTextStyles.bodyMedium.copyWith(color: AppColors.subtextDark),
      labelLarge: AppTextStyles.labelLarge.copyWith(
          color:
              AppColors.primaryColor), // استخدام primaryColor ليكون أكثر وضوحاً
      labelSmall:
          AppTextStyles.labelSmall.copyWith(color: AppColors.subtextDark),
    ),
  );

  // ================== Light Theme ==================
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    fontFamily: 'Cairo',
    primaryColor: AppColors.primaryColor,
    primaryColorLight: AppColors.primaryLight,
    primaryColorDark: AppColors.primaryDark,
    scaffoldBackgroundColor: Colors.transparent, // تم تعيينها شفافة
    cardColor: AppColors.cardLight,
    dividerColor: AppColors.dividerLight,
    splashFactory: InkRipple.splashFactory,
    visualDensity: VisualDensity.adaptivePlatformDensity,
    colorScheme: const ColorScheme.light().copyWith(
      primary: AppColors.primaryColor,
      onPrimary: AppColors.textLight,
      secondary: AppColors.accentColor,
      onSecondary: AppColors.textLight,
      surface: AppColors.cardLight,
      onSurface: AppColors.textPrimary, // تغيير ليكون أكثر وضوحاً
      background: AppColors.backgroundLight,
      onBackground: AppColors.textPrimary,
      error: AppColors.errorColor,
      onError: AppColors.textLight,
      brightness: Brightness.light,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent, // AppBar دائمًا شفاف
      elevation: 0,
      centerTitle: false,
      titleTextStyle: AppTextStyles.displayMedium // استخدام النمط الجديد
          .copyWith(color: AppColors.textPrimary), // استخدام textPrimary
      iconTheme: const IconThemeData(color: AppColors.iconLight),
    ),
    iconTheme: const IconThemeData(color: AppColors.iconLight),
    textTheme: TextTheme(
      displayLarge:
          AppTextStyles.displayLarge.copyWith(color: AppColors.textPrimary),
      displayMedium:
          AppTextStyles.displayMedium.copyWith(color: AppColors.textPrimary),
      displaySmall:
          AppTextStyles.displaySmall.copyWith(color: AppColors.textPrimary),
      headlineMedium:
          AppTextStyles.headlineMedium.copyWith(color: AppColors.textPrimary),
      headlineSmall:
          AppTextStyles.headlineSmall.copyWith(color: AppColors.textPrimary),
      bodyLarge:
          AppTextStyles.bodyLarge.copyWith(color: AppColors.textSecondary),
      bodyMedium:
          AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
      labelLarge: AppTextStyles.labelLarge
          .copyWith(color: AppColors.primaryColor), // استخدام primaryColor
      labelSmall:
          AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondary),
    ),
  );
}

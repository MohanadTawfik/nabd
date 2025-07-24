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
    scaffoldBackgroundColor: AppColors.backgroundDark,
    cardColor: AppColors.cardDark,
    dividerColor: AppColors.dividerDark,
    splashFactory: InkRipple.splashFactory,
    visualDensity: VisualDensity.adaptivePlatformDensity,
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: AppTextStyles.headline2
          .copyWith(color: AppColors.textDark, fontWeight: FontWeight.bold),
      iconTheme: const IconThemeData(color: AppColors.textDark),
    ),
    iconTheme: const IconThemeData(color: AppColors.subtextDark),
    textTheme: TextTheme(
      displayLarge: AppTextStyles.headline1.copyWith(color: AppColors.textDark),
      displayMedium:
          AppTextStyles.headline2.copyWith(color: AppColors.textDark),
      displaySmall: AppTextStyles.headline3.copyWith(color: AppColors.textDark),
      headlineMedium:
          AppTextStyles.subtitle1.copyWith(color: AppColors.textDark),
      headlineSmall:
          AppTextStyles.subtitle2.copyWith(color: AppColors.textDark),
      bodyLarge: AppTextStyles.bodyText1.copyWith(color: AppColors.subtextDark),
      bodyMedium:
          AppTextStyles.bodyText2.copyWith(color: AppColors.subtextDark),
      labelLarge:
          AppTextStyles.buttonText.copyWith(color: AppColors.primaryDark),
      bodySmall: AppTextStyles.caption.copyWith(color: AppColors.subtextDark),
    ),
  );

  // ================== Light Theme ==================
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    fontFamily: 'Cairo',
    primaryColor: AppColors.primaryColor,
    primaryColorLight: AppColors.primaryLight,
    primaryColorDark: AppColors.primaryDark,
    scaffoldBackgroundColor: AppColors.backgroundLight,
    cardColor: AppColors.cardLight,
    dividerColor: AppColors.dividerLight,
    splashFactory: InkRipple.splashFactory,
    visualDensity: VisualDensity.adaptivePlatformDensity,
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.backgroundLight,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: AppTextStyles.headline2
          .copyWith(color: AppColors.textLight, fontWeight: FontWeight.bold),
      iconTheme: const IconThemeData(color: AppColors.textLight),
    ),
    iconTheme: const IconThemeData(color: AppColors.iconLight),
    textTheme: TextTheme(
      displayLarge:
          AppTextStyles.headline1.copyWith(color: AppColors.textLight),
      displayMedium:
          AppTextStyles.headline2.copyWith(color: AppColors.textLight),
      displaySmall:
          AppTextStyles.headline3.copyWith(color: AppColors.textLight),
      headlineMedium:
          AppTextStyles.subtitle1.copyWith(color: AppColors.textLight),
      headlineSmall:
          AppTextStyles.subtitle2.copyWith(color: AppColors.textLight),
      bodyLarge:
          AppTextStyles.bodyText1.copyWith(color: AppColors.textSecondary),
      bodyMedium:
          AppTextStyles.bodyText2.copyWith(color: AppColors.textSecondary),
      labelLarge:
          AppTextStyles.buttonText.copyWith(color: AppColors.primaryLight),
      bodySmall: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
    ),
  );
}

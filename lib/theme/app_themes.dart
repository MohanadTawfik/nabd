import 'package:flutter/material.dart';

class AppThemes {
  // --- الألوان الأساسية ---
  static final Color _darkPrimaryColor = const Color(0xff9b59b6); // بنفسجي أنيق
  static final Color _darkScaffoldBg = const Color(0xff121212); // أسود حقيقي
  static final Color _darkCardColor =
      const Color(0xff1e1e1e); // رمادي داكن للبطاقات
  static final Color _darkTextColor = Colors.white.withOpacity(0.9);
  static final Color _darkSubtextColor = Colors.white60;

  static final Color _lightPrimaryColor =
      const Color(0xff673ab7); // بنفسجي مشرق
  static final Color _lightScaffoldBg = const Color(0xfff5f5f5);
  static final Color _lightCardColor = Colors.white;
  static final Color _lightTextColor = Colors.black87;
  static final Color _lightSubtextColor = Colors.grey.shade700;

  // --- ألوان المعاملات ---
  static final Color incomeColor = Colors.green.shade400;
  static final Color expenseColor = Colors.red.shade400;

  // ================== الثيم الليلي (التحفة الفنية) ==================
  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    fontFamily: 'Tajawal',
    primaryColor: _darkPrimaryColor,
    scaffoldBackgroundColor: _darkScaffoldBg,
    cardColor: _darkCardColor,
    dividerColor: Colors.white24,
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: false, // العنوان على اليمين
      titleTextStyle: TextStyle(
          fontFamily: 'Tajawal',
          fontWeight: FontWeight.bold,
          fontSize: 24,
          color: _darkTextColor),
      iconTheme: IconThemeData(color: _darkTextColor),
    ),
    iconTheme: IconThemeData(color: _darkSubtextColor),
    textTheme: TextTheme(
      bodyMedium:
          TextStyle(color: _darkSubtextColor, fontSize: 14, height: 1.5),
      titleLarge: TextStyle(
          color: _darkTextColor, fontWeight: FontWeight.bold, fontSize: 32),
      titleMedium: TextStyle(
          color: _darkTextColor, fontWeight: FontWeight.bold, fontSize: 18),
      titleSmall: TextStyle(
          color: _darkTextColor, fontWeight: FontWeight.normal, fontSize: 16),
    ),
  );

  // ================== الثيم النهاري (الوجه المشرق) ==================
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    fontFamily: 'Tajawal',
    primaryColor: _lightPrimaryColor,
    scaffoldBackgroundColor: _lightScaffoldBg,
    cardColor: _lightCardColor,
    dividerColor: Colors.grey.shade300,
    appBarTheme: AppBarTheme(
      backgroundColor: _lightScaffoldBg,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
          fontFamily: 'Tajawal',
          fontWeight: FontWeight.bold,
          fontSize: 24,
          color: _lightTextColor),
      iconTheme: IconThemeData(color: _lightTextColor),
    ),
    iconTheme: IconThemeData(color: _lightSubtextColor),
    textTheme: TextTheme(
      bodyMedium:
          TextStyle(color: _lightSubtextColor, fontSize: 14, height: 1.5),
      titleLarge: TextStyle(
          color: _lightTextColor, fontWeight: FontWeight.bold, fontSize: 32),
      titleMedium: TextStyle(
          color: _lightTextColor, fontWeight: FontWeight.bold, fontSize: 18),
      titleSmall: TextStyle(
          color: _lightTextColor, fontWeight: FontWeight.normal, fontSize: 16),
    ),
  );
}

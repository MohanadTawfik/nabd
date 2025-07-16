import 'package:flutter/material.dart';

class AppThemes {
  // --- الألوان الأساسية ---
  static final Color _darkPrimaryColor = const Color(0xff8952ff);
  static final Color _darkScaffoldBg = const Color(0xff0d1117);
  static final Color _darkCardColor = const Color(0xff161b22);
  static final Color _darkTextColor = Colors.white.withOpacity(0.87);
  static final Color _darkSubtextColor = Colors.white70;

  static final Color _lightPrimaryColor = Colors.deepPurple;
  static final Color _lightScaffoldBg = Colors.grey.shade100;
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
    dividerColor: Colors.grey.shade800,
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      titleTextStyle: TextStyle(
          fontFamily: 'Tajawal',
          fontWeight: FontWeight.bold,
          fontSize: 22,
          color: _darkTextColor),
      iconTheme: IconThemeData(color: _darkTextColor),
    ),
    bottomAppBarTheme: BottomAppBarTheme(
      color: _darkCardColor.withOpacity(0.95),
      elevation: 0,
    ),
    iconTheme: IconThemeData(color: _darkSubtextColor),
    textTheme: TextTheme(
      bodyMedium: TextStyle(color: _darkSubtextColor),
      titleLarge: TextStyle(color: _darkTextColor, fontWeight: FontWeight.bold),
      titleMedium:
          TextStyle(color: _darkTextColor, fontWeight: FontWeight.bold),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _darkPrimaryColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(
            fontFamily: 'Tajawal', fontSize: 16, fontWeight: FontWeight.bold),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      labelStyle: TextStyle(color: _darkSubtextColor),
      filled: true,
      fillColor: _darkCardColor,
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _darkPrimaryColor)),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: _darkScaffoldBg,
      selectedColor: _darkPrimaryColor,
      labelStyle: TextStyle(
          color: _darkSubtextColor,
          fontWeight: FontWeight.bold,
          fontFamily: 'Tajawal'),
      secondaryLabelStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontFamily: 'Tajawal'),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Colors.white24)),
      secondarySelectedColor: _darkPrimaryColor,
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
      backgroundColor: Colors.transparent,
      elevation: 0,
      titleTextStyle: TextStyle(
          fontFamily: 'Tajawal',
          fontWeight: FontWeight.bold,
          fontSize: 22,
          color: _lightTextColor),
      iconTheme: IconThemeData(color: _lightTextColor),
    ),
    bottomAppBarTheme: BottomAppBarTheme(
      color: _lightCardColor.withOpacity(0.95),
      elevation: 8,
    ),
    iconTheme: IconThemeData(color: _lightSubtextColor),
    textTheme: TextTheme(
      bodyMedium: TextStyle(color: _lightSubtextColor),
      titleLarge:
          TextStyle(color: _lightTextColor, fontWeight: FontWeight.bold),
      titleMedium:
          TextStyle(color: _lightTextColor, fontWeight: FontWeight.bold),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _lightPrimaryColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(
            fontFamily: 'Tajawal', fontSize: 16, fontWeight: FontWeight.bold),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      labelStyle: TextStyle(color: Colors.grey.shade600),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300)),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _lightPrimaryColor)),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: _lightScaffoldBg,
      selectedColor: _lightPrimaryColor,
      labelStyle: TextStyle(
          color: _lightSubtextColor,
          fontWeight: FontWeight.bold,
          fontFamily: 'Tajawal'),
      secondaryLabelStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontFamily: 'Tajawal'),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: Colors.grey.shade400)),
      secondarySelectedColor: _lightPrimaryColor,
    ),
  );
}

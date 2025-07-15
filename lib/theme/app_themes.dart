import 'package:flutter/material.dart';

class AppThemes {
  static final Color _darkPrimaryColor = const Color(0xff8952ff);
  static final Color _darkScaffoldBg = const Color(0xff0d1117);
  static final Color _darkCardColor = const Color(0xff161b22);

  static final Color _lightPrimaryColor = Colors.deepPurple;
  static final Color _lightScaffoldBg = Colors.grey.shade100;
  static final Color _lightCardColor = Colors.white;

  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    fontFamily: 'Tajawal',
    primaryColor: _darkPrimaryColor,
    scaffoldBackgroundColor: _darkScaffoldBg,
    cardColor: _darkCardColor,
    dividerColor: Colors.grey.shade800,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      titleTextStyle: TextStyle(
          fontFamily: 'Tajawal',
          fontWeight: FontWeight.bold,
          fontSize: 22,
          color: Colors.white),
      iconTheme: IconThemeData(color: Colors.white),
    ),
    bottomAppBarTheme: BottomAppBarTheme(
      color: _darkCardColor.withOpacity(0.95),
      elevation: 8,
    ),
    iconTheme: const IconThemeData(color: Colors.white70),
    textTheme: const TextTheme(
      bodyMedium: TextStyle(color: Colors.white70),
      titleLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      titleMedium: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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
      labelStyle: const TextStyle(color: Colors.white54),
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
      labelStyle: const TextStyle(
          color: Colors.white70,
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
          color: _lightPrimaryColor),
      iconTheme: IconThemeData(color: _lightPrimaryColor),
    ),
    bottomAppBarTheme: BottomAppBarTheme(
      color: _lightCardColor.withOpacity(0.95),
      elevation: 8,
    ),
    iconTheme: IconThemeData(color: Colors.grey.shade700),
    textTheme: const TextTheme(
      bodyMedium: TextStyle(color: Colors.black87),
      titleLarge: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
      titleMedium: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
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
          color: Colors.grey.shade800,
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

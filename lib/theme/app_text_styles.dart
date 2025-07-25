import 'package:flutter/material.dart';

class AppTextStyles {
  // تم تعديل أحجام الخطوط لتوفير تباين أفضل وراحة للعين
  static const TextStyle displayLarge = TextStyle(
    fontSize: 32, // كان 24، تم زيادته للوضوح كعنوان رئيسي
    fontWeight: FontWeight.bold,
    fontFamily: 'Cairo',
    letterSpacing: 0.5,
  );

  static const TextStyle displayMedium = TextStyle(
    fontSize: 24, // كان 20، تم زيادته
    fontWeight: FontWeight.bold,
    fontFamily: 'Cairo',
    letterSpacing: 0.4,
  );

  static const TextStyle displaySmall = TextStyle(
    // كان headline3
    fontSize: 20, // كان 18، تم زيادته
    fontWeight: FontWeight.bold,
    fontFamily: 'Cairo',
    letterSpacing: 0.3,
  );

  static const TextStyle headlineMedium = TextStyle(
    // كان subtitle1
    fontSize: 18, // لم يتغير
    fontWeight: FontWeight.bold,
    fontFamily: 'Cairo',
    letterSpacing: 0.2,
  );

  static const TextStyle headlineSmall = TextStyle(
    // كان subtitle2
    fontSize: 16, // لم يتغير
    fontWeight: FontWeight.normal,
    fontFamily: 'Cairo',
    letterSpacing: 0.1,
  );

  static const TextStyle bodyLarge = TextStyle(
    // كان bodyText1
    fontSize: 15, // كان 14، تم زيادته قليلاً
    height: 1.5,
    fontFamily: 'Cairo',
    letterSpacing: 0.1,
  );

  static const TextStyle bodyMedium = TextStyle(
    // كان bodyText2
    fontSize: 13, // كان 12، تم زيادته قليلاً
    height: 1.5,
    fontFamily: 'Cairo',
    letterSpacing: 0.1,
  );

  static const TextStyle labelLarge = TextStyle(
    // كان buttonText
    fontSize: 16,
    fontWeight: FontWeight.bold,
    fontFamily: 'Cairo',
    letterSpacing: 0.2,
  );

  static const TextStyle labelSmall = TextStyle(
    // كان caption
    fontSize: 11, // كان 10، تم زيادته قليلاً
    fontStyle: FontStyle.italic,
    fontFamily: 'Cairo',
    letterSpacing: 0.1,
  );

  static const TextStyle numpadText = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.normal,
    fontFamily: 'Cairo',
    letterSpacing: 0.5,
  );
}

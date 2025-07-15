import 'package:flutter/material.dart';
import 'features/onboarding/screens/onboarding_screen.dart'; // 1. استيراد شاشة البداية

class FinancialApp extends StatelessWidget {
  const FinancialApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: child!,
        );
      },
      theme: ThemeData(
        fontFamily: 'Tajawal',
        scaffoldBackgroundColor: const Color(0xff0d1117),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          elevation: 0,
          titleTextStyle: TextStyle(
              fontFamily: 'Tajawal',
              fontWeight: FontWeight.bold,
              fontSize: 22,
              color: Colors.white),
        ),
      ),
      // 2. نجعل شاشة البداية هي الواجهة الرئيسية للتطبيق
      home: const OnboardingScreen(),
    );
  }
}

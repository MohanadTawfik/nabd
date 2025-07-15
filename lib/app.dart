import 'package:flutter/material.dart';
import 'package:nabd/data/app_data.dart';
import 'package:nabd/theme/app_themes.dart';
import 'package:provider/provider.dart';
import 'features/onboarding/screens/onboarding_screen.dart'; // 1. استيراد شاشة البداية

class FinancialApp extends StatelessWidget {
  const FinancialApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppData>(
      builder: (context, appData, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          builder: (context, child) {
            return Directionality(
              textDirection: TextDirection.rtl,
              child: child!,
            );
          },
          // 2. تطبيق الثيمات من الملف الجديد
          theme: AppThemes.lightTheme,
          darkTheme: AppThemes.darkTheme,
          themeMode: appData.themeMode,
          home: const OnboardingScreen(),
        );
      },
    );
  }
}

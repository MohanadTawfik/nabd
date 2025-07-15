import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // 1. استيراد الحزمة
import 'app.dart';
import 'data/app_data.dart'; // 2. استيراد مركز البيانات

void main() {
  // 3. نستخدم ChangeNotifierProvider لتوفير نسخة من AppData لكل التطبيق
  runApp(
    ChangeNotifierProvider(
      create: (context) => AppData(),
      child: const FinancialApp(),
    ),
  );
}

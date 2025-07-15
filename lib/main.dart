import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart'; // 1. استيراد الحزمة
import 'app.dart';
import 'data/app_data.dart'; // 2. استيراد مركز البيانات

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('ar', null);

  // 3. هذا هو السطر الذي أعدناه!
  // يقوم بتوفير AppData (العقل) لكل التطبيق.
  runApp(
    ChangeNotifierProvider(
      create: (context) => AppData(),
      child: const FinancialApp(),
    ),
  );
}

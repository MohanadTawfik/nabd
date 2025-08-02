import 'package:nabd/features/budgets/budgets_provider.dart';
import 'package:nabd/features/categories/categories_provider.dart';
import 'package:nabd/features/goals/goals_provider.dart';
import 'package:nabd/features/reports/reports_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:nabd/services/database_service.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'services/service_locator.dart';
import 'utils/animation_config.dart';
import 'package:nabd/features/auth/auth_provider.dart';
import 'package:nabd/features/transactions/transactions_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('ar', null);

  // Initialize service locator
  serviceLocator.initialize();

  // Initialize database first
  final dbService = DatabaseService();
  await dbService.database; // This will initialize the database

  // Initialize AuthService
  await serviceLocator.authService.initialize();

  // Initialize animation settings
  AnimationConfig.initialize();

  // Provide all providers to the entire app
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>(
          create: (context) => AuthProvider(),
          lazy: false,
        ),
        ChangeNotifierProvider<TransactionsProvider>(
          create: (context) => TransactionsProvider(),
          lazy: false,
        ),
        ChangeNotifierProvider<BudgetsProvider>(
          create: (context) => BudgetsProvider(),
          lazy: false,
        ),
        ChangeNotifierProvider<GoalsProvider>(
          create: (context) => GoalsProvider(),
          lazy: false,
        ),
        ChangeNotifierProvider<CategoriesProvider>(
          create: (context) => CategoriesProvider(),
          lazy: false,
        ),
        ChangeNotifierProvider<ReportsProvider>(
          create: (context) => ReportsProvider(),
          lazy: false,
        ),
      ],
      child: const FinancialApp(),
    ),
  );
}

import 'package:flutter/material.dart';
import 'package:nabd/features/auth/screens/change_password_screen.dart';
import 'package:nabd/features/auth/screens/login_screen.dart';
import 'package:nabd/features/auth/screens/profile_screen.dart';
import 'package:nabd/features/auth/screens/register_screen.dart';
import 'package:nabd/features/auth/widgets/auth_wrapper.dart';
import 'package:nabd/features/main_screen/screens/main_screen.dart';
import 'package:nabd/features/onboarding/screens/onboarding_screen.dart';
import 'package:nabd/features/transactions/screens/add_transaction_screen.dart';
import 'package:nabd/features/budgets/screens/budgets_screen.dart';
import 'package:nabd/features/budgets/screens/add_budget_screen.dart';
import 'package:nabd/features/goals/screens/add_goal_screen.dart';
import 'package:nabd/features/insights/screens/insights_hub_screen.dart';
import 'package:nabd/features/settings/screens/settings_screen.dart';
import 'package:nabd/features/transactions/screens/smart_input_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nabd/theme/app_themes.dart';

class FinancialApp extends StatefulWidget {
  const FinancialApp({super.key});

  @override
  State<FinancialApp> createState() => _FinancialAppState();
}

class _FinancialAppState extends State<FinancialApp> {
  bool _onboardingComplete = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _checkOnboarding();
  }

  Future<void> _checkOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _onboardingComplete = prefs.getBool('onboarding_complete') ?? false;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const MaterialApp(
          home: Scaffold(body: Center(child: CircularProgressIndicator())));
    }
    // Default to system theme,
    //TODO can be replaced with a theme provider if needed
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: child!,
        );
      },
      theme: AppThemes.darkTheme,
      darkTheme: AppThemes.darkTheme,
      themeMode: ThemeMode.system,
      home:
          _onboardingComplete ? const AuthWrapper() : const OnboardingScreen(),
      routes: {
        '/main': (context) => const MainScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/change_password': (context) => const ChangePasswordScreen(),
        '/add_transaction': (context) => const AddTransactionScreen(),
        '/smart_input': (context) => const SmartInputScreen(),
        '/budgets': (context) => const BudgetsScreen(),
        '/add_budget': (context) => const AddBudgetScreen(),
        '/add_goal': (context) => const AddGoalScreen(),
        '/insights': (context) => const InsightsHubScreen(),
        '/settings': (context) => const SettingsScreen(),
        '/onboarding': (context) => const OnboardingScreen(),
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:nabd/features/auth/screens/login_screen.dart';
import 'package:nabd/features/main_screen/main_screen.dart';
import 'package:nabd/features/onboarding/screens/onboarding_screen.dart';
import 'package:nabd/features/auth/auth_provider.dart';
import 'package:nabd/services/auth_service.dart';
import 'package:nabd/widgets/loading_state.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A widget that handles authentication state and routing using Provider
class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _isFirstLaunch = true;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkFirstLaunch();
    // Initialize auth provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AuthProvider>(context, listen: false).initialize();
    });
  }

  Future<void> _checkFirstLaunch() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final hasCompletedOnboarding =
          prefs.getBool('hasCompletedOnboarding') ?? false;

      setState(() {
        _isFirstLaunch = !hasCompletedOnboarding;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const LoadingState();
    }

    if (_isFirstLaunch) {
      return const OnboardingScreen();
    }

    // Always show MainScreen for now
    return const MainScreen();
    // TODO: Restore authentication logic after implementing login screen

    // return Consumer<AuthProvider>(
    //   builder: (context, authProvider, _) {
    //     switch (authProvider.status) {
    //       case AuthStatus.initial:
    //         return const LoadingState();
    //       case AuthStatus.authenticated:
    //         return const MainScreen();
    //       case AuthStatus.unauthenticated:
    //         return const LoginScreen();
    //     }
    //   },
    // );
  }
}

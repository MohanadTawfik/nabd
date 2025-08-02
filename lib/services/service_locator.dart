import 'package:nabd/services/api_service.dart';
import 'package:nabd/services/auth_service.dart';
import 'package:nabd/services/journey_service.dart';

/// A simple service locator for dependency injection
class ServiceLocator {
  // Singleton pattern
  static final ServiceLocator _instance = ServiceLocator._internal();
  factory ServiceLocator() => _instance;
  ServiceLocator._internal();

  // Services
  late final ApiService apiService;
  late final AuthService authService;
  late final JourneyService journeyService;

  bool _initialized = false;
  // Initialize all services
  void initialize() {
    if (_initialized) return;
    apiService = ApiService();
    authService = AuthService(); // Use MockAuthService for development
    journeyService = JourneyService();
    _initialized = true;
  }

  // Generic getter for services
  T call<T>() {
    if (T == ApiService) {
      return apiService as T;
    } else if (T == AuthService) {
      return authService as T;
    } else if (T == JourneyService) {
      return journeyService as T;
    }
    throw Exception('Service $T not found');
  }
}

// Global instance for easy access
final serviceLocator = ServiceLocator();

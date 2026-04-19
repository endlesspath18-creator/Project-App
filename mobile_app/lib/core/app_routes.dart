import 'package:flutter/material.dart';
import '../ui/screens/splash_screen.dart';
import '../ui/screens/auth/login_screen.dart';
import '../ui/screens/auth/signup_screen.dart';
import '../ui/screens/home/user_home_screen.dart';
import '../ui/screens/home/provider_home_screen.dart';
import '../ui/screens/home/add_service_screen.dart';

import '../ui/screens/auth/role_selection_screen.dart';

class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String roleSelection = '/role-selection';
  static const String userHome = '/user-home';
  static const String providerHome = '/provider-home';
  static const String addService = '/add-service';

  static Map<String, WidgetBuilder> getRoutes() {
    return {
      splash: (context) => const SplashScreen(),
      login: (context) => const LoginScreen(),
      signup: (context) => const SignupScreen(),
      roleSelection: (context) => const RoleSelectionScreen(),
      userHome: (context) => const UserHomeScreen(),
      providerHome: (context) => const ProviderHomeScreen(),
      addService: (context) => const AddServiceScreen(),
    };
  }
}

import 'package:flutter/material.dart';
import '../ui/screens/splash_screen.dart';
import '../ui/screens/auth/welcome_screen.dart';
import '../ui/screens/auth/login_screen.dart';
import '../ui/screens/auth/signup_screen.dart';
import '../ui/screens/auth/forgot_password_screen.dart';
import '../ui/screens/auth/otp_screen.dart';
import '../ui/screens/home/user_home_screen.dart';
import '../ui/screens/home/provider_home_screen.dart';
import '../ui/screens/home/add_service_screen.dart';
import '../ui/screens/home/categories_screen.dart';
import '../ui/screens/home/provider_details_screen.dart';
import '../ui/screens/home/booking_screen.dart';

class AppRoutes {
  static const String splash = '/';
  static const String welcome = '/welcome';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String forgotPassword = '/forgot-password';
  static const String otp = '/otp';
  static const String userHome = '/user-home';
  static const String providerHome = '/provider-home';
  static const String addService = '/add-service';
  static const String categories = '/categories';
  static const String providerDetails = '/provider-details';
  static const String booking = '/booking';

  static Map<String, WidgetBuilder> getRoutes() {
    return {
      splash: (context) => const SplashScreen(),
      welcome: (context) => const WelcomeScreen(),
      login: (context) => const LoginScreen(),
      signup: (context) => const SignupScreen(),
      forgotPassword: (context) => const ForgotPasswordScreen(),
      otp: (context) => const OTPScreen(),
      userHome: (context) => const UserHomeScreen(),
      providerHome: (context) => const ProviderHomeScreen(),
      addService: (context) => const AddServiceScreen(),
      categories: (context) => const CategoriesScreen(),
      providerDetails: (context) => const ProviderDetailsScreen(),
      booking: (context) => const BookingScreen(),
    };
  }
}

import 'package:flutter/material.dart';
import 'package:mobile_app/features/auth/ui/welcome_screen.dart';
import 'package:mobile_app/features/auth/ui/login_screen.dart';
import 'package:mobile_app/features/auth/ui/signup_screen.dart';
import 'package:mobile_app/features/auth/ui/forgot_password_screen.dart';
import 'package:mobile_app/features/auth/ui/otp_screen.dart';
import 'package:mobile_app/features/user/ui/user_main_screen.dart';
import 'package:mobile_app/features/user/ui/categories_screen.dart';
import 'package:mobile_app/features/user/ui/provider_details_screen.dart';
import 'package:mobile_app/features/user/ui/booking_screen.dart';
import 'package:mobile_app/features/user/ui/user_search_screen.dart';
import 'package:mobile_app/features/notifications/ui/notifications_screen.dart';
import 'package:mobile_app/features/user/ui/user_favorites_screen.dart';
import 'package:mobile_app/features/user/ui/bookings_view.dart';
import 'package:mobile_app/features/provider/ui/provider_dashboard.dart';
import 'package:mobile_app/features/provider/ui/add_service_screen.dart';
import 'package:mobile_app/features/provider/ui/provider_earnings_screen.dart';
import 'package:mobile_app/features/provider/ui/provider_services_screen.dart';
import 'package:mobile_app/features/provider/ui/provider_activation_screen.dart';
import 'package:mobile_app/features/provider/ui/premium_status_screen.dart';
import 'package:mobile_app/features/profile/ui/profile_screen.dart';
import 'package:mobile_app/features/profile/ui/edit_profile_screen.dart';
import 'package:mobile_app/features/profile/ui/change_password_screen.dart';
import 'package:mobile_app/features/user/account/ui/user_account_screen.dart';
import 'package:mobile_app/features/splash/ui/motion_splash.dart';
import 'package:mobile_app/features/admin/ui/admin_dashboard.dart';
import 'package:mobile_app/features/admin/ui/admin_finance_screen.dart';


class AppRoutes {
  static const String splash = '/';
  static const String welcome = '/welcome';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String forgotPassword = '/forgotPassword';
  static const String otp = '/otp';
  static const String adminDashboard = '/adminDashboard';
  
  // User Panel
  static const String userHome = '/userHome';
  static const String categories = '/categories';
  static const String providerDetails = '/providerDetails';
  static const String booking = '/booking';
  static const String search = '/search';
  static const String notifications = '/notifications';
  
  // Specifically requested by user
  static const String userProfile = '/userProfile';
  static const String userFavorites = '/userFavorites';
  static const String userBookings = '/userBookings';
  static const String userSettings = '/userSettings';
  static const String userHelp = '/userHelp';
  
  // Provider Panel
  static const String providerHome = '/providerHome';
  static const String addService = '/addService';
  static const String earnings = '/earnings';
  static const String providerServices = '/providerServices';
  static const String providerActivation = '/providerActivation';
  static const String premiumStatus = '/premiumStatus';
  static const String availability = '/availability';
  static const String editProfile = '/editProfile';
  static const String changePassword = '/changePassword';
  static const String adminFinance = '/adminFinance';

  static Map<String, WidgetBuilder> getRoutes() {
    return {
      splash: (context) => const ServiceMotionSplash(),
      welcome: (context) => const WelcomeScreen(),
      login: (context) => const LoginScreen(),
      signup: (context) => const SignupScreen(),
      forgotPassword: (context) => const ForgotPasswordScreen(),
      otp: (context) {
        final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
        return OTPScreen(
          email: args?['email'] ?? "",
          debugOtp: args?['debugOtp'],
        );
      },
      
      // User Screens
      userHome: (context) => const UserMainScreen(),
      categories: (context) => const CategoriesScreen(),
      providerDetails: (context) => const ProviderDetailsScreen(),
      booking: (context) => const BookingScreen(),
      search: (context) => const UserSearchScreen(),
      notifications: (context) => const NotificationsScreen(),
      
      userProfile: (context) => const UserAccountScreen(),
      userFavorites: (context) => const UserFavoritesScreen(),
      userBookings: (context) => const BookingsView(isStandalone: true),
      userSettings: (context) => const UserAccountScreen(),
      userHelp: (context) => const UserAccountScreen(), // Support is inside now


      // Provider Screens
      providerHome: (context) => const ProviderDashboard(),
      addService: (context) => const AddServiceScreen(),
      earnings: (context) => const ProviderEarningsScreen(),
      providerServices: (context) => const ProviderServicesScreen(),
      providerActivation: (context) => const ProviderActivationScreen(),
      premiumStatus: (context) => const PremiumStatusScreen(),
      availability: (context) => const PlaceholderScreen(title: "Availability"),
      editProfile: (context) => const EditProfileScreen(),
      changePassword: (context) => const ChangePasswordScreen(),

      // Admin Screens
      adminDashboard: (context) => const AdminDashboard(),
      adminFinance: (context) => const AdminFinanceScreen(),
    };
  }
}

class PlaceholderScreen extends StatelessWidget {
  final String title;
  const PlaceholderScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(child: Text("$title Screen\n(Development in Progress)", textAlign: TextAlign.center)),
    );
  }
}

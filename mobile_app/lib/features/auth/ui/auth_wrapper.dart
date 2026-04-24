import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile_app/providers/auth_provider.dart';
import 'package:mobile_app/features/auth/ui/welcome_screen.dart';
import 'package:mobile_app/features/user/ui/user_main_screen.dart';
import 'package:mobile_app/features/provider/ui/provider_dashboard.dart';
import 'package:mobile_app/features/admin/ui/admin_dashboard.dart';
import 'package:mobile_app/core/design_system.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  @override
  void initState() {
    super.initState();
    // Start auth check immediately
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthProvider>().checkAuthStatus();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        if (!auth.isInitialized) {
          // Show a very brief minimalist loading during startup check
          return Scaffold(
            backgroundColor: AppColors.background,
            body: const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            ),
          );
        }

        if (auth.isAuthenticated) {
          if (auth.isAdmin) return const AdminDashboard();
          
          return auth.isProvider 
            ? const ProviderDashboard() 
            : const UserMainScreen();
        }

        return const WelcomeScreen();
      },
    );
  }
}

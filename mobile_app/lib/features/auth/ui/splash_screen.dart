import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:provider/provider.dart';
import 'package:mobile_app/core/app_routes.dart';
import 'package:mobile_app/core/design_system.dart';
import 'package:mobile_app/providers/auth_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _startApp();
  }

  Future<void> _startApp() async {
    // Artificial delay for splash experience
    await Future.delayed(const Duration(seconds: 3));
    
    if (!mounted) return;
    
    final authProvider = context.read<AuthProvider>();
    final isLoggedIn = await authProvider.checkAuthStatus();

    if (!mounted) return;

    if (isLoggedIn) {
      Navigator.pushReplacementNamed(
        context,
        authProvider.isProvider ? AppRoutes.providerHome : AppRoutes.userHome,
      );
    } else {
      Navigator.pushReplacementNamed(context, AppRoutes.welcome);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(decoration: const BoxDecoration(gradient: AppGradients.bgGlow)),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 60), // Space where logo was
               FadeInDown(
                  duration: const Duration(seconds: 1),
                  child: const Column(
                    children: [
                      Text(
                        "EndlessPath",
                        style: TextStyle(
                          fontSize: 44,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                          letterSpacing: -2,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        "PREMIUM SERVICES",
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 4,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 60),
                const SizedBox(height: 60),
                SizedBox(
                  width: 150,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: const LinearProgressIndicator(
                      color: AppColors.primary,
                      backgroundColor: AppColors.border,
                      minHeight: 3,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

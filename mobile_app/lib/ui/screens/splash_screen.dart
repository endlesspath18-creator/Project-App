import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import '../../providers/auth_provider.dart';
import '../../core/app_routes.dart';
import '../../core/design_system.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _startStartupSequence();
  }

  Future<void> _startStartupSequence() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    // Auth check
    bool isAuthenticated = await authProvider.checkAuthStatus();

    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    if (isAuthenticated) {
      Navigator.of(context).pushReplacementNamed(
        authProvider.isProvider ? AppRoutes.providerHome : AppRoutes.userHome,
      );
    } else {
      Navigator.of(context).pushReplacementNamed(AppRoutes.welcome);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(gradient: GlacierGradients.bgGlow),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FadeInDown(
              duration: const Duration(seconds: 1),
              child: SizedBox(
                height: 150,
                child: Image.asset('assets/images/logo.png'),
              ),
            ),
            const SizedBox(height: 24),
            FadeInUp(
              delay: const Duration(milliseconds: 500),
              child: const Text(
                "ENDLESSPATH",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 8,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 48),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(GlacierColors.primary),
            ),
          ],
        ),
      ),
    );
  }
}

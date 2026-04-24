import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:mobile_app/core/app_routes.dart';
import 'package:mobile_app/core/design_system.dart';
import 'package:mobile_app/core/app_dimensions.dart';
import 'package:mobile_app/widgets/glass_widgets.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(child: Container(decoration: const BoxDecoration(gradient: AppGradients.bgGlow))),
          
          SafeArea(
            child: Padding(
              padding: AppDimensions.screenPadding(context),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: Column(
                    children: [
                      const Spacer(flex: 2),
                      
                      FadeInDown(
                        duration: const Duration(seconds: 1),
                        child: Hero(
                          tag: 'app_logo',
                          child: Container(
                            padding: const EdgeInsets.all(AppDimensions.s24),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.primary.withValues(alpha: 0.1), width: 3),
                              boxShadow: [
                                BoxShadow(color: AppColors.primary.withValues(alpha: 0.1), blurRadius: 40, spreadRadius: 10)
                              ],
                            ),
                            child: const Icon(Icons.auto_awesome_rounded, color: AppColors.primary, size: 80),
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: AppDimensions.s40),
                      
                      FadeInUp(
                        delay: const Duration(milliseconds: 300),
                        child: const Text(
                          "EndlessPath",
                          style: TextStyle(
                            fontSize: 42,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                            letterSpacing: -1,
                          ),
                        ),
                      ),
                      
                      FadeInUp(
                        delay: const Duration(milliseconds: 400),
                        child: const Text(
                          "PREMIUM HOME SERVICES",
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 4,
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: AppDimensions.s16),
                      
                      FadeInUp(
                        delay: const Duration(milliseconds: 500),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(horizontal: AppDimensions.s24),
                          child: Text(
                            "Experience luxury and trust with our curated marketplace for expert home services.",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 16,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ),
                      
                      const Spacer(flex: 3),
                      
                      FadeInUp(
                        delay: const Duration(milliseconds: 700),
                        child: GlassButton(
                          onPressed: () => Navigator.pushNamed(context, AppRoutes.login),
                          text: "Get Started",
                        ),
                      ),
                      
                      const SizedBox(height: AppDimensions.s16),
                      
                      FadeInUp(
                        delay: const Duration(milliseconds: 800),
                        child: GlassButton(
                          onPressed: () => Navigator.pushNamed(context, AppRoutes.signup),
                          text: "Create Account",
                          isPrimary: false,
                        ),
                      ),
                      
                      const SizedBox(height: AppDimensions.s40),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../../core/design_system.dart';
import '../../../core/app_routes.dart';
import '../../../widgets/glass_widgets.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Glow
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: GlacierGradients.bgGlow,
              ),
            ),
          ),
          
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Spacer(),
                  const Text(
                    "Professional Services\nat your Doorstep",
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Premium home services. Trusted professionals. Glass-smooth experience.",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 48),
                  GlassButton(
                    onPressed: () => Navigator.pushNamed(context, AppRoutes.login),
                    text: "Sign In",
                  ),
                  const SizedBox(height: 16),
                  GlassButton(
                    onPressed: () => Navigator.pushNamed(context, AppRoutes.signup),
                    text: "Create Account",
                    isPrimary: false,
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

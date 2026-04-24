import 'package:flutter/material.dart';
import '../../../core/design_system.dart';
import '../../../widgets/glass_widgets.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final emailController = TextEditingController();

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(child: Container(decoration: const BoxDecoration(gradient: GlacierGradients.bgGlow))),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    "Forgot Password",
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "Enter your email to receive a password reset link.",
                    style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 16),
                  ),
                  const SizedBox(height: 48),
                  GlassInput(controller: emailController, hintText: "Email", prefixIcon: Icons.email_outlined),
                  const SizedBox(height: 24),
                  GlassButton(
                    onPressed: () {
                      // Logic for forgot password
                    },
                    text: "Send Reset Link",
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

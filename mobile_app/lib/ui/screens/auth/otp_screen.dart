import 'package:flutter/material.dart';
import '../../../core/design_system.dart';
import '../../../widgets/glass_widgets.dart';

class OTPScreen extends StatelessWidget {
  const OTPScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final otpController = TextEditingController();

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
                    "Verification",
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "We have sent a verification code to your email/phone.",
                    style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 16),
                  ),
                  const SizedBox(height: 48),
                  GlassInput(
                    controller: otpController,
                    hintText: "Enter 6-digit OTP",
                    prefixIcon: Icons.lock_outline,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 24),
                  GlassButton(
                    onPressed: () {
                      // Logic for OTP verification
                    },
                    text: "Verify OTP",
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

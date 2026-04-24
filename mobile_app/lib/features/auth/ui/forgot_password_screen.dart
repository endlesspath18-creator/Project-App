import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:mobile_app/core/app_routes.dart';
import 'package:mobile_app/core/design_system.dart';
import 'package:mobile_app/core/app_dimensions.dart';
import 'package:mobile_app/widgets/glass_widgets.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  bool _isLoading = false;

  void _handleReset() async {
    if (_emailController.text.isEmpty) return;
    
    setState(() => _isLoading = true);
    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      Navigator.pushNamed(context, AppRoutes.otp);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          Positioned.fill(child: Container(decoration: const BoxDecoration(gradient: AppGradients.bgGlow))),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: AppDimensions.screenPadding(context),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 500),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FadeInDown(
                        child: const Text(
                          "Pardon the\nInterruption",
                          style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: AppColors.textPrimary, height: 1.1, letterSpacing: -1),
                        ),
                      ),
                      const SizedBox(height: AppDimensions.s12),
                      FadeInDown(
                        delay: const Duration(milliseconds: 200),
                        child: const Text(
                          "Enter your email to recover your account.",
                          style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
                        ),
                      ),
                      const SizedBox(height: AppDimensions.s48),
                      FadeInUp(
                        delay: const Duration(milliseconds: 400),
                        child: GlassCard(
                          padding: const EdgeInsets.all(AppDimensions.s24),
                          child: Column(
                            children: [
                               GlassInput(
                                controller: _emailController,
                                hintText: "Email address",
                                prefixIcon: Icons.email_outlined,
                                keyboardType: TextInputType.emailAddress,
                              ),
                              const SizedBox(height: AppDimensions.s24),
                              GlassButton(
                                onPressed: _isLoading ? null : _handleReset,
                                isLoading: _isLoading,
                                text: "Send Reset Link",
                              ),
                            ],
                          ),
                        ),
                      ),
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

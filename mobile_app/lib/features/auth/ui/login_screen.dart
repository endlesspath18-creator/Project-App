import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import 'package:mobile_app/providers/auth_provider.dart';
import 'package:mobile_app/core/app_routes.dart';
import 'package:mobile_app/core/design_system.dart';
import 'package:mobile_app/core/app_dimensions.dart';
import 'package:mobile_app/widgets/glass_widgets.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.login(
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );

    if (success) {
      if (!mounted) return;
      if (authProvider.isAdmin) {
        Navigator.of(context).pushReplacementNamed(AppRoutes.adminDashboard);
      } else {
        Navigator.of(context).pushReplacementNamed(
          authProvider.isProvider ? AppRoutes.providerHome : AppRoutes.userHome,
        );
      }
    } else {
      if (!mounted) return;
      final error = authProvider.error ?? 'Login failed';
      _showErrorSnackBar(error);
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.r16)),
        margin: const EdgeInsets.all(AppDimensions.s24),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(child: Container(decoration: const BoxDecoration(gradient: AppGradients.bgGlow))),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: AppDimensions.screenPadding(context),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 500),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: AppDimensions.s40),
                        FadeInDown(
                          duration: const Duration(milliseconds: 800),
                          child: const Text(
                            "Welcome\nBack",
                            style: TextStyle(
                              fontSize: 44,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                              height: 1.1,
                              letterSpacing: -1,
                            ),
                          ),
                        ),
                        const SizedBox(height: AppDimensions.s12),
                        FadeInDown(
                          delay: const Duration(milliseconds: 200),
                          child: const Text(
                            "Sign in to your premium experience",
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
                                  hintText: "Email or Phone",
                                  prefixIcon: Icons.email_outlined,
                                  keyboardType: TextInputType.emailAddress,
                                  validator: (v) => v!.isEmpty ? "Required" : null,
                                ),
                                const SizedBox(height: AppDimensions.s16),
                                GlassInput(
                                  controller: _passwordController,
                                  hintText: "Password",
                                  obscureText: !_isPasswordVisible,
                                  prefixIcon: Icons.lock_outline,
                                  suffixIcon: _isPasswordVisible ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                  onSuffixIconTap: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                                  validator: (v) => v!.length < 6 ? "Minimum 6 chars" : null,
                                ),
                                const SizedBox(height: AppDimensions.s8),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton(
                                    onPressed: () => Navigator.pushNamed(context, AppRoutes.forgotPassword),
                                    child: const Text("Forgot Password?", style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600)),
                                  ),
                                ),
                                const SizedBox(height: AppDimensions.s24),
                                Consumer<AuthProvider>(
                                  builder: (context, auth, _) {
                                    return GlassButton(
                                      onPressed: auth.isLoading ? null : _handleLogin,
                                      isLoading: auth.isLoading,
                                      text: "Sign In",
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: AppDimensions.s40),
                        FadeInUp(
                          delay: const Duration(milliseconds: 600),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text("Don't have an account? ", style: TextStyle(color: AppColors.textSecondary)),
                              TextButton(
                                onPressed: () => Navigator.pushNamed(context, AppRoutes.signup),
                                child: const Text(
                                  "Create One",
                                  style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppDimensions.s24),
                      ],
                    ),
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

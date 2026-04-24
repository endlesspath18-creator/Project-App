import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import 'package:mobile_app/providers/auth_provider.dart';
import 'package:mobile_app/core/app_routes.dart';
import 'package:mobile_app/core/design_system.dart';
import 'package:mobile_app/core/app_dimensions.dart';
import 'package:mobile_app/widgets/glass_widgets.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _businessNameController = TextEditingController();
  
  bool _isProvider = false;
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _businessNameController.dispose();
    super.dispose();
  }

  void _handleSignup() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.register(
      fullName: _fullNameController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      password: _passwordController.text.trim(),
      role: _isProvider ? 'PROVIDER' : 'USER',
      businessName: _isProvider ? _businessNameController.text.trim() : null,
    );

    if (success) {
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed(
        _isProvider ? AppRoutes.providerHome : AppRoutes.userHome,
      );
    } else {
      if (!mounted) return;
      _showErrorSnackBar(authProvider.error ?? 'Registration failed');
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
                            "Create\nAccount",
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
                            "Join the future of service marketplaces",
                            style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
                          ),
                        ),
                        const SizedBox(height: AppDimensions.s32),
                        
                        // Role Selection Toggle
                        FadeInRight(
                          delay: const Duration(milliseconds: 300),
                          child: _buildRoleToggle(),
                        ),
                        
                        const SizedBox(height: AppDimensions.s24),
                        
                        FadeInUp(
                          delay: const Duration(milliseconds: 400),
                          child: GlassCard(
                            padding: const EdgeInsets.all(AppDimensions.s24),
                            child: Column(
                              children: [
                                GlassInput(
                                  controller: _fullNameController,
                                  hintText: "Full Name",
                                  prefixIcon: Icons.person_outline,
                                  validator: (v) => v!.isEmpty ? "Required" : null,
                                ),
                                const SizedBox(height: AppDimensions.s16),
                                GlassInput(
                                  controller: _emailController,
                                  hintText: "Email",
                                  prefixIcon: Icons.email_outlined,
                                  keyboardType: TextInputType.emailAddress,
                                  validator: (v) => !v!.contains('@') ? "Invalid email" : null,
                                ),
                                const SizedBox(height: AppDimensions.s16),
                                GlassInput(
                                  controller: _phoneController,
                                  hintText: "Phone Number",
                                  prefixIcon: Icons.phone_outlined,
                                  keyboardType: TextInputType.phone,
                                  validator: (v) => v!.length < 10 ? "Invalid phone" : null,
                                ),
                                if (_isProvider) ...[
                                  const SizedBox(height: AppDimensions.s16),
                                  GlassInput(
                                    controller: _businessNameController,
                                    hintText: "Business Name",
                                    prefixIcon: Icons.business_outlined,
                                    validator: (v) => v!.isEmpty ? "Required for Providers" : null,
                                  ),
                                ],
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
                                const SizedBox(height: AppDimensions.s32),
                                Consumer<AuthProvider>(
                                  builder: (context, auth, _) {
                                    return GlassButton(
                                      onPressed: auth.isLoading ? null : _handleSignup,
                                      isLoading: auth.isLoading,
                                      text: "Get Started",
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: AppDimensions.s40),
                        Center(
                          child: FadeInUp(
                            delay: const Duration(milliseconds: 600),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text("Already a member? ", style: TextStyle(color: AppColors.textSecondary)),
                                TextButton(
                                  onPressed: () => Navigator.pushReplacementNamed(context, AppRoutes.login),
                                  child: const Text("Sign In", style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: AppDimensions.s32),
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

  Widget _buildRoleToggle() {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.s4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.r16),
        border: Border.all(color: AppColors.border),
        boxShadow: const [AppShadows.soft],
      ),
      child: Row(
        children: [
          Expanded(
            child: _RoleTab(
              label: "I'm a Customer",
              isSelected: !_isProvider,
              onTap: () => setState(() => _isProvider = false),
            ),
          ),
          Expanded(
            child: _RoleTab(
              label: "I'm a Provider",
              isSelected: _isProvider,
              onTap: () => setState(() => _isProvider = true),
            ),
          ),
        ],
      ),
    );
  }
}

class _RoleTab extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _RoleTab({required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(AppDimensions.r12),
          boxShadow: isSelected ? [
            BoxShadow(color: AppColors.primary.withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 4))
          ] : null,
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : AppColors.textSecondary,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}

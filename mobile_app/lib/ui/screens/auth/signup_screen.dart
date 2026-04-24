import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import '../../../providers/auth_provider.dart';
import '../../../core/app_routes.dart';
import '../../../core/design_system.dart';
import '../../../widgets/glass_widgets.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _businessNameController = TextEditingController();
  
  String _selectedRole = 'USER';

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _businessNameController.dispose();
    super.dispose();
  }

  void _handleSignup() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.register(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
      fullName: _fullNameController.text.trim(),
      role: _selectedRole,
      businessName: _selectedRole == 'PROVIDER' ? _businessNameController.text.trim() : null,
      phone: _phoneController.text.trim(),
    );

    if (success) {
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed(
        _selectedRole == 'PROVIDER' ? AppRoutes.providerHome : AppRoutes.userHome,
      );
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.error ?? 'Signup failed'),
          backgroundColor: GlacierColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(child: Container(decoration: const BoxDecoration(gradient: GlacierGradients.bgGlow))),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FadeInDown(
                    child: IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 20),
                  FadeInDown(
                    duration: const Duration(milliseconds: 800),
                    child: const Text(
                      "Create\nAccount",
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        height: 1.1,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  FadeInDown(
                    delay: const Duration(milliseconds: 200),
                    child: Text(
                      "Join the elite network of services",
                      style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 16),
                    ),
                  ),
                  const SizedBox(height: 40),
                  
                  // Role Selector
                  FadeInUp(
                    delay: const Duration(milliseconds: 300),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: GlacierColors.glassBackground.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: GlacierColors.glassBorder),
                      ),
                      child: Row(
                        children: [
                          _buildRoleButton('USER', 'Looking for Services'),
                          _buildRoleButton('PROVIDER', 'Offering Services'),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  FadeInUp(
                    delay: const Duration(milliseconds: 400),
                    child: GlassCard(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          GlassInput(controller: _fullNameController, hintText: "Full Name", prefixIcon: Icons.person_outline),
                          const SizedBox(height: 16),
                          GlassInput(controller: _emailController, hintText: "Email", prefixIcon: Icons.email_outlined),
                          const SizedBox(height: 16),
                          GlassInput(controller: _phoneController, hintText: "Phone Number", prefixIcon: Icons.phone_android_outlined),
                          const SizedBox(height: 16),
                          if (_selectedRole == 'PROVIDER') ...[
                            GlassInput(controller: _businessNameController, hintText: "Business Name", prefixIcon: Icons.business_outlined),
                            const SizedBox(height: 16),
                          ],
                          GlassInput(controller: _passwordController, hintText: "Password", isPassword: true, prefixIcon: Icons.lock_outline),
                          const SizedBox(height: 32),
                          Consumer<AuthProvider>(
                            builder: (context, auth, _) {
                              return GlassButton(
                                onPressed: auth.isLoading ? () {} : _handleSignup,
                                text: auth.isLoading ? "Creating..." : "Create Account",
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleButton(String role, String label) {
    final isActive = _selectedRole == role;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedRole = role),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: isActive ? GlacierColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: isActive ? GlacierColors.background : Colors.white.withOpacity(0.6),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

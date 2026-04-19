import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import '../../../providers/auth_provider.dart';
import '../../../core/app_routes.dart';
import '../../../core/motion_utils.dart';
import '../../../widgets/animated_background.dart';
import '../../../widgets/auth_card.dart';
import '../../../widgets/google_button.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _businessNameController = TextEditingController();
  final _phoneController = TextEditingController();
  
  String _selectedRole = 'USER';
  bool _obscurePassword = true;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _businessNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _handleSignup() async {
    if (_formKey.currentState!.validate()) {
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
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: AnimatedBackground(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight - 80, // Account for padding
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FadeInDown(
                        duration: const Duration(milliseconds: 800),
                        child: Column(
                          children: [
                            SizedBox(
                              height: 100,
                              child: Image.asset(
                                'assets/images/logo.png',
                                fit: BoxFit.contain,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Create Account',
                              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Join our premium marketplace',
                              style: TextStyle(
                                color: Colors.black.withValues(alpha: 0.5),
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 40),
                      FadeInUp(
                        duration: const Duration(milliseconds: 800),
                        delay: const Duration(milliseconds: 200),
                        child: AuthCard(
                          child: Form(
                            key: _formKey,
                            child: Column(
                              children: [
                                // Role Selector
                                Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.withValues(alpha: 0.05),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    children: [
                                      _buildRoleTab('USER', 'Looking for Help'),
                                      _buildRoleTab('PROVIDER', 'Offering Service'),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 24),
                                
                                TextFormField(
                                  controller: _fullNameController,
                                  decoration: const InputDecoration(
                                    labelText: 'Full Name',
                                    prefixIcon: Icon(Icons.person_outline),
                                  ),
                                  validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                                ),
                                const SizedBox(height: 16),
                                
                                TextFormField(
                                  controller: _emailController,
                                  keyboardType: TextInputType.emailAddress,
                                  decoration: const InputDecoration(
                                    labelText: 'Email Address',
                                    prefixIcon: Icon(Icons.email_outlined),
                                  ),
                                  validator: (value) => value == null || !value.contains('@') ? 'Invalid email' : null,
                                ),
                                const SizedBox(height: 16),
                                
                                TextFormField(
                                  controller: _phoneController,
                                  keyboardType: TextInputType.phone,
                                  decoration: const InputDecoration(
                                    labelText: 'Phone Number',
                                    prefixIcon: Icon(Icons.phone_iphone_outlined),
                                  ),
                                  validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                                ),
                                const SizedBox(height: 16),

                                if (_selectedRole == 'PROVIDER') ...[
                                  FadeInDown(
                                    duration: const Duration(milliseconds: 400),
                                    child: Padding(
                                      padding: const EdgeInsets.only(bottom: 16),
                                      child: TextFormField(
                                        controller: _businessNameController,
                                        decoration: const InputDecoration(
                                          labelText: 'Business Name',
                                          prefixIcon: Icon(Icons.business_outlined),
                                        ),
                                        validator: (value) {
                                          if (_selectedRole == 'PROVIDER' && (value == null || value.isEmpty)) {
                                            return 'Business name is required for providers';
                                          }
                                          return null;
                                        },
                                      ),
                                    ),
                                  ),
                                ],

                                TextFormField(
                                  controller: _passwordController,
                                  obscureText: _obscurePassword,
                                  decoration: InputDecoration(
                                    labelText: 'Password',
                                    prefixIcon: const Icon(Icons.lock_outline),
                                    suffixIcon: IconButton(
                                      icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                                    ),
                                  ),
                                  validator: (value) => value != null && value.length < 6 ? 'Min 6 characters' : null,
                                ),
                                
                                const SizedBox(height: 32),
                                Consumer<AuthProvider>(
                                  builder: (context, auth, _) {
                                    return MotionUtils.tapScale(
                                      onTap: auth.isLoading ? () {} : _handleSignup,
                                      child: AnimatedContainer(
                                        duration: const Duration(milliseconds: 300),
                                        width: double.infinity,
                                        height: 56,
                                        decoration: BoxDecoration(
                                          color: Theme.of(context).primaryColor,
                                          borderRadius: BorderRadius.circular(16),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Theme.of(context).primaryColor.withValues(alpha: 0.3),
                                              blurRadius: 10,
                                              offset: const Offset(0, 4),
                                            ),
                                          ],
                                        ),
                                        child: Center(
                                          child: auth.isLoading
                                              ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                                              : const Text(
                                                  'Create Account',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      FadeInUp(
                        delay: const Duration(milliseconds: 300),
                        child: Consumer<AuthProvider>(
                          builder: (context, auth, _) => GoogleButton(
                            isLoading: auth.isLoading,
                            isAvailable: auth.isFirebaseAvailable,
                            onPressed: () async {
                              final success = await auth.signInWithGoogle();
                              if (context.mounted) {
                                if (success) {
                                  Navigator.of(context).pushReplacementNamed(
                                    auth.isProvider ? AppRoutes.providerHome : AppRoutes.userHome,
                                  );
                                } else if (auth.user != null && auth.user!.role.isEmpty) {
                                  Navigator.of(context).pushNamed(AppRoutes.roleSelection);
                                }
                              }
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      FadeInUp(
                        delay: const Duration(milliseconds: 400),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Already have an account? ",
                              style: TextStyle(color: Colors.black.withValues(alpha: 0.6)),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text(
                                'Sign In',
                                style: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildRoleTab(String role, String label) {
    final isActive = _selectedRole == role;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedRole = role),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isActive ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    )
                  ]
                : [],
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                color: isActive ? Theme.of(context).primaryColor : Colors.grey,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:provider/provider.dart';
import 'package:mobile_app/providers/auth_provider.dart';
import 'package:mobile_app/core/app_routes.dart';
import 'package:mobile_app/core/design_system.dart';
import 'package:mobile_app/core/app_dimensions.dart';
import 'package:mobile_app/widgets/glass_widgets.dart';

class OTPScreen extends StatefulWidget {
  final String email;
  final String? debugOtp;

  const OTPScreen({super.key, required this.email, this.debugOtp});

  @override
  State<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  final List<TextEditingController> _controllers = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  void _handleVerify() async {
    String otp = _controllers.map((e) => e.text).join();
    if (otp.length < 6) {
      _showErrorSnackBar("Please enter the complete 6-digit code");
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.verifyOtp(widget.email, otp);

    if (success) {
      if (!mounted) return;
      // Redirect based on role
      final user = authProvider.user;
      if (user?.role == 'ADMIN') {
        Navigator.pushReplacementNamed(context, AppRoutes.adminDashboard);
      } else if (user?.role == 'PROVIDER') {
        Navigator.pushReplacementNamed(context, AppRoutes.providerHome);
      } else {
        Navigator.pushReplacementNamed(context, AppRoutes.userHome);
      }
    } else {
      if (!mounted) return;
      _showErrorSnackBar(authProvider.error ?? "Verification failed");
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
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0,
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
                          "Verify\nIdentity",
                          style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: AppColors.textPrimary, height: 1.1, letterSpacing: -1),
                        ),
                      ),
                      const SizedBox(height: AppDimensions.s12),
                      FadeInDown(
                        delay: const Duration(milliseconds: 200),
                        child: Text(
                          "Check your email (${widget.email}) and mobile for the 6-digit code.",
                          style: const TextStyle(color: AppColors.textSecondary, fontSize: 16),
                        ),
                      ),
                      if (widget.debugOtp != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          "Debug Code: ${widget.debugOtp}",
                          style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                        ),
                      ],
                      const SizedBox(height: AppDimensions.s48),
                      FadeInUp(
                        delay: const Duration(milliseconds: 400),
                        child: GlassCard(
                          padding: const EdgeInsets.all(AppDimensions.s24),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: List.generate(6, (index) => _buildOTPBox(index)),
                              ),
                              const SizedBox(height: AppDimensions.s32),
                              Consumer<AuthProvider>(
                                builder: (context, auth, _) {
                                  return GlassButton(
                                    onPressed: auth.isLoading ? null : _handleVerify,
                                    isLoading: auth.isLoading,
                                    text: "Verify Account",
                                  );
                                },
                              ),
                              const SizedBox(height: AppDimensions.s24),
                              Center(
                                child: TextButton(
                                  onPressed: () {},
                                  child: const Text("Resend Code", style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                                ),
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

  Widget _buildOTPBox(int index) {
    return Container(
      width: 45,
      height: 60,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.r12),
        border: Border.all(color: AppColors.border),
        boxShadow: const [AppShadows.soft],
      ),
      child: Center(
        child: TextField(
          controller: _controllers[index],
          focusNode: _focusNodes[index],
          textAlign: TextAlign.center,
          keyboardType: TextInputType.number,
          maxLength: 1,
          style: const TextStyle(color: AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.bold),
          decoration: const InputDecoration(counterText: "", border: InputBorder.none),
          onChanged: (v) {
            if (v.isNotEmpty && index < 5) {
              _focusNodes[index + 1].requestFocus();
            } else if (v.isEmpty && index > 0) {
              _focusNodes[index - 1].requestFocus();
            }
          },
        ),
      ),
    );
  }
}

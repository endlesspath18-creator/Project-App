import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:mobile_app/core/app_routes.dart';
import 'package:mobile_app/core/design_system.dart';
import 'package:mobile_app/core/app_dimensions.dart';
import 'package:mobile_app/widgets/glass_widgets.dart';

class OTPScreen extends StatefulWidget {
  const OTPScreen({super.key});

  @override
  State<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  final List<TextEditingController> _controllers = List.generate(4, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(4, (_) => FocusNode());
  bool _isLoading = false;

  void _handleVerify() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      Navigator.pushReplacementNamed(context, AppRoutes.login);
    }
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
                        child: const Text(
                          "Check your inbox for the 4-digit code.",
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
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: List.generate(4, (index) => _buildOTPBox(index)),
                              ),
                              const SizedBox(height: AppDimensions.s32),
                              GlassButton(
                                onPressed: _isLoading ? null : _handleVerify,
                                isLoading: _isLoading,
                                text: "Verify Code",
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
      width: 60,
      height: 70,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.r16),
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
          style: const TextStyle(color: AppColors.textPrimary, fontSize: 24, fontWeight: FontWeight.bold),
          decoration: const InputDecoration(counterText: "", border: InputBorder.none),
          onChanged: (v) {
            if (v.isNotEmpty && index < 3) {
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

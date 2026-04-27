import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile_app/providers/auth_provider.dart';
import 'package:mobile_app/providers/dashboard_provider.dart';
import 'package:mobile_app/core/design_system.dart';
import 'package:mobile_app/core/app_dimensions.dart';
import 'package:mobile_app/widgets/glass_widgets.dart';

class UpdateBankDetailsScreen extends StatefulWidget {
  const UpdateBankDetailsScreen({super.key});

  @override
  State<UpdateBankDetailsScreen> createState() => _UpdateBankDetailsScreenState();
}

class _UpdateBankDetailsScreenState extends State<UpdateBankDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _bankNameController = TextEditingController();
  final _accHolderController = TextEditingController();
  final _accNumberController = TextEditingController();
  final _ifscController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final profile = context.read<AuthProvider>().user?.providerProfile;
    if (profile != null) {
      _bankNameController.text = profile['bankName'] ?? '';
      _accHolderController.text = profile['bankAccountName'] ?? '';
      _accNumberController.text = profile['bankAccountNumber'] ?? '';
      _ifscController.text = profile['bankIFSC'] ?? '';
    }
  }

  @override
  void dispose() {
    _bankNameController.dispose();
    _accHolderController.dispose();
    _accNumberController.dispose();
    _ifscController.dispose();
    super.dispose();
  }

  void _handleUpdate() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthProvider>();
    final success = await auth.updateProfile(
      // We pass the new bank fields here. AuthProvider already handles provider/profile endpoint.
      // I'll need to update AuthProvider.updateProfile to support these fields if not done.
    );

    // Wait, let me check AuthProvider.updateProfile again.
    // I should update it to take these bank fields specifically.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Banking Details", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Positioned.fill(child: Container(decoration: const BoxDecoration(gradient: AppGradients.bgGlow))),
          SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Payout Settings",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Enter your bank account details where you wish to receive your earnings.",
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 32),
                  GlassCard(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        _buildInput(_bankNameController, "Bank Name", Icons.account_balance_rounded),
                        const SizedBox(height: 16),
                        _buildInput(_accHolderController, "Account Holder Name", Icons.person_outline),
                        const SizedBox(height: 16),
                        _buildInput(_accNumberController, "Account Number", Icons.numbers_rounded, isNumeric: true),
                        const SizedBox(height: 16),
                        _buildInput(_ifscController, "IFSC Code", Icons.code_rounded),
                        const SizedBox(height: 32),
                        Consumer<AuthProvider>(
                          builder: (context, auth, _) {
                            return GlassButton(
                              onPressed: auth.isLoading ? null : () async {
                                if (!_formKey.currentState!.validate()) return;
                                
                                // We'll call the custom provider profile update
                                final success = await _updateOnServer(context);
                                if (success && context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text("Bank details updated successfully! ✅"), backgroundColor: Colors.green)
                                  );
                                  context.read<DashboardProvider>().fetchStats(force: true);
                                  Navigator.pop(context);
                                }
                              },
                              isLoading: auth.isLoading,
                              text: "Save & Continue",
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<bool> _updateOnServer(BuildContext context) async {
    return await context.read<AuthProvider>().updateProfile(
      bankName: _bankNameController.text.trim(),
      bankAccountName: _accHolderController.text.trim(),
      bankAccountNumber: _accNumberController.text.trim(),
      bankIFSC: _ifscController.text.trim(),
    );
  }

  Widget _buildInput(TextEditingController controller, String hint, IconData icon, {bool isNumeric = false}) {
    return GlassInput(
      controller: controller,
      hintText: hint,
      prefixIcon: icon,
      keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
      validator: (v) => v!.isEmpty ? "This field is required" : null,
    );
  }
}

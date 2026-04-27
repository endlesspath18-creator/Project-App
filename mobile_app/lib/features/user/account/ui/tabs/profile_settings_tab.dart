import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile_app/core/design_system.dart';
import 'package:mobile_app/core/app_dimensions.dart';
import 'package:mobile_app/providers/auth_provider.dart';
import 'package:mobile_app/providers/user_account_provider.dart';
import 'package:mobile_app/widgets/glass_widgets.dart';
import 'package:animate_do/animate_do.dart';

class ProfileSettingsTab extends StatefulWidget {
  const ProfileSettingsTab({super.key});

  @override
  State<ProfileSettingsTab> createState() => _ProfileSettingsTabState();
}

class _ProfileSettingsTabState extends State<ProfileSettingsTab> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    if (user != null) {
      _nameController.text = user.fullName;
      _phoneController.text = user.phone ?? "";
      _emailController.text = user.email;
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final user = auth.user;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Personal Information", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          GlassCard(
            child: Column(
              children: [
                _buildTextField(_nameController, "Full Name", Icons.person_outline),
                const Divider(),
                _buildTextField(_emailController, "Email Address", Icons.email_outlined, enabled: false),
                const Divider(),
                _buildTextField(_phoneController, "Phone Number", Icons.phone_outlined),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                auth.updateProfile(fullName: _nameController.text, phone: _phoneController.text);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text("Save Changes", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: 32),
          const Text("Security & Account", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          GlassCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                _buildMenuTile(Icons.lock_outline, "Change Password", () {}),
                const Divider(height: 1),
                _buildMenuTile(Icons.devices_outlined, "Logout All Devices", () {
                  Provider.of<UserAccountProvider>(context, listen: false).logoutAllDevices().then((success) {
                    if (success) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Logged out from all other devices")));
                    }
                  });
                }),

                const Divider(height: 1),
                _buildMenuTile(Icons.delete_outline, "Delete Account", () {}, color: AppColors.error),
              ],
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => auth.logout(),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: const BorderSide(color: AppColors.error),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text("Sign Out", style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {bool enabled = true}) {
    return TextField(
      controller: controller,
      enabled: enabled,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
        border: InputBorder.none,
        labelStyle: const TextStyle(color: AppColors.textTertiary, fontSize: 12),
      ),
    );
  }

  Widget _buildMenuTile(IconData icon, String title, VoidCallback onTap, {Color? color}) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: color ?? AppColors.textPrimary, size: 22),
      title: Text(title, style: TextStyle(color: color ?? AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w500)),
      trailing: const Icon(Icons.chevron_right, size: 20),
    );
  }
}

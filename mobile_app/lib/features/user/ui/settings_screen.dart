import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:mobile_app/core/design_system.dart';
import 'package:mobile_app/core/app_dimensions.dart';
import 'package:mobile_app/widgets/glass_widgets.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings", style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          Positioned.fill(child: Container(decoration: const BoxDecoration(gradient: AppGradients.bgGlow))),
          SafeArea(
            child: SingleChildScrollView(
              padding: AppDimensions.screenPadding(context).copyWith(top: AppDimensions.s24),
              child: Column(
                children: [
                  FadeInUp(child: _buildSection("Account", [
                    _SettingsItem(Icons.person_outline_rounded, "Edit Profile", () {}),
                    _SettingsItem(Icons.lock_outline_rounded, "Change Password", () {}),
                    _SettingsItem(Icons.notifications_none_rounded, "Notification Settings", () {}),
                  ])),
                  const SizedBox(height: 24),
                  FadeInUp(delay: const Duration(milliseconds: 100), child: _buildSection("General", [
                    _SettingsItem(Icons.language_rounded, "Language", () {}, trailing: "English"),
                    _SettingsItem(Icons.dark_mode_outlined, "Appearance", () {}, trailing: "Light"),
                    _SettingsItem(Icons.help_outline_rounded, "Help & Support", () {}),
                    _SettingsItem(Icons.info_outline_rounded, "About App", () {}),
                  ])),
                  const SizedBox(height: 40),
                  FadeInUp(
                    delay: const Duration(milliseconds: 200),
                    child: GlassButton(
                      onPressed: () {},
                      text: "Sign Out",
                      isPrimary: false,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text("Version 1.0.0", style: TextStyle(color: AppColors.textTertiary, fontSize: 12)),
                  const SizedBox(height: 48),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 12),
          child: Text(title, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 18)),
        ),
        GlassCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: items,
          ),
        ),
      ],
    );
  }
}

class _SettingsItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final String? trailing;

  const _SettingsItem(this.icon, this.title, this.onTap, {this.trailing});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: AppColors.primary, size: 22),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (trailing != null) ...[
            Text(trailing!, style: const TextStyle(color: AppColors.textTertiary, fontSize: 13)),
            const SizedBox(width: 8),
          ],
          const Icon(Icons.chevron_right_rounded, color: AppColors.textTertiary),
        ],
      ),
    );
  }
}

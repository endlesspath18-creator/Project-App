import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import 'package:mobile_app/providers/auth_provider.dart';
import 'package:mobile_app/core/design_system.dart';
import 'package:mobile_app/core/app_dimensions.dart';
import 'package:mobile_app/widgets/glass_widgets.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final user = auth.user;
    final bool isProvider = auth.isProvider;
    final bool isAdmin = auth.isAdmin;

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(child: Container(decoration: const BoxDecoration(gradient: AppGradients.bgGlow))),
          CustomScrollView(
            slivers: [
              _buildAppBar(context, user?.fullName ?? "Profile"),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(AppDimensions.s24),
                  child: Column(
                    children: [
                      _buildHeader(user),
                      const SizedBox(height: AppDimensions.s32),
                      if (isAdmin) _buildAdminSections()
                      else if (isProvider) _buildProviderSections()
                      else _buildUserSections(),
                      const SizedBox(height: AppDimensions.s32),
                      _buildDangerZone(auth),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, String title) {
    return SliverAppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary),
      ),
      title: Text(title, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
      centerTitle: true,
      floating: true,
    );
  }

  Widget _buildHeader(dynamic user) {
    return FadeInDown(
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AppGradients.primary,
                ),
                child: const CircleAvatar(
                  radius: 50,
                  backgroundColor: AppColors.surface,
                  child: Icon(Icons.person, size: 50, color: AppColors.primary),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                  child: const Icon(Icons.edit_rounded, color: Colors.white, size: 16),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(user?.fullName ?? "User Name", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          Text(user?.email ?? "email@example.com", style: const TextStyle(color: AppColors.textSecondary)),
        ],
      ),
    );
  }

  Widget _buildUserSections() {
    return Column(
      children: [
        _buildSection("Account Settings", [
          _ProfileItem(Icons.location_on_outlined, "Saved Addresses", "Manage your service locations", onTap: () => Navigator.pushNamed(context, '/search')),
          _ProfileItem(Icons.payment_rounded, "Payment Methods", "Cards, UPI, and Wallets", onTap: () => _showComingSoon(context, "Payment Methods")),
          _ProfileItem(Icons.notifications_none_rounded, "Notifications", "Alerts and message settings", onTap: () => Navigator.pushNamed(context, '/notifications')),
        ]),
        const SizedBox(height: 24),
        _buildSection("Experience", [
          _ProfileItem(Icons.favorite_border_rounded, "Favorites", "Your most loved services", onTap: () => Navigator.pushNamed(context, '/userFavorites')),
          _ProfileItem(Icons.history_rounded, "Booking History", "Review your past orders", onTap: () => Navigator.pushNamed(context, '/userBookings')),
          _ProfileItem(Icons.help_outline_rounded, "Help & Support", "FAQs and contact us", onTap: () => _showComingSoon(context, "Help & Support")),
        ]),
      ],
    );
  }

  Widget _buildProviderSections() {
    return Column(
      children: [
        _buildSection("Business Profile", [
          _ProfileItem(Icons.business_rounded, "Business Name", "Update your brand identity", onTap: () => _showComingSoon(context, "Business Profile")),
          _ProfileItem(Icons.category_outlined, "Skills & Categories", "Manage your listed services", onTap: () => Navigator.pushNamed(context, '/providerServices')),
          _ProfileItem(Icons.map_outlined, "Service Areas", "Define where you work", onTap: () => _showComingSoon(context, "Service Areas")),
        ]),
        const SizedBox(height: 24),
        _buildSection("Finance", [
          _ProfileItem(Icons.account_balance_rounded, "Bank Details", "UPI and Payout settings", onTap: () => _showComingSoon(context, "Bank Details")),
          _ProfileItem(Icons.payments_outlined, "Earnings Summary", "View your performance logs", onTap: () => Navigator.pushNamed(context, '/earnings')),
        ]),
        const SizedBox(height: 24),
        _buildSection("Settings", [
          _ProfileItem(Icons.online_prediction_rounded, "Availability", "Toggle your online status", isSwitch: true),
          _ProfileItem(Icons.star_outline_rounded, "Reviews", "What your customers say", onTap: () => _showComingSoon(context, "Reviews")),
        ]),
      ],
    );
  }

  Widget _buildAdminSections() {
    return Column(
      children: [
        _buildSection("Security", [
          _ProfileItem(Icons.security_rounded, "Admin Permissions", "Manage system access", onTap: () => _showComingSoon(context, "Admin Permissions")),
          _ProfileItem(Icons.lock_outline_rounded, "Two-Factor Auth", "Highly secure login", onTap: () => _showComingSoon(context, "2FA")),
        ]),
        const SizedBox(height: 24),
        _buildSection("Preferences", [
          _ProfileItem(Icons.dark_mode_outlined, "Theme Settings", "Dark & Light mode controls", onTap: () => _showComingSoon(context, "Theme Settings")),
          _ProfileItem(Icons.language_rounded, "Language", "System localization", onTap: () => _showComingSoon(context, "Language")),
        ]),
      ],
    );
  }

  Widget _buildSection(String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 12),
          child: Text(title.toUpperCase(), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary, letterSpacing: 1.5)),
        ),
        GlassCard(
          padding: EdgeInsets.zero,
          child: Column(children: items),
        ),
      ],
    );
  }

  Widget _buildDangerZone(AuthProvider auth) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 8, bottom: 12),
          child: Text("DANGER ZONE", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.error, letterSpacing: 1.5)),
        ),
        GlassCard(
          padding: EdgeInsets.zero,
          color: AppColors.error.withValues(alpha: 0.05),
          child: Column(
            children: [
              _ProfileItem(
                Icons.logout_rounded, 
                "Logout", 
                "Sign out of your account", 
                isDestructive: true,
                onTap: () => auth.logout().then((_) => Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false)),
              ),
              _ProfileItem(Icons.delete_forever_rounded, "Delete Account", "Permanently remove your data", isDestructive: true),
            ],
          ),
        ),
      ],
    );
  }
}

class _ProfileItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isDestructive;
  final bool isSwitch;
  final VoidCallback? onTap;

  const _ProfileItem(this.icon, this.title, this.subtitle, {
    this.isDestructive = false, 
    this.isSwitch = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap ?? () => _showComingSoon(context, title),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: (isDestructive ? AppColors.error : AppColors.primary).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: isDestructive ? AppColors.error : AppColors.primary, size: 20),
      ),
      title: Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: isDestructive ? AppColors.error : AppColors.textPrimary)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
      trailing: isSwitch 
        ? Switch(value: true, onChanged: (v) {}, activeColor: AppColors.primary)
        : const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: AppColors.textTertiary),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }

  void _showComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("$feature feature is coming soon in the next update! ✨"),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.primary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

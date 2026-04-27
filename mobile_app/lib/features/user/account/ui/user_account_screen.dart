import 'package:flutter/material.dart';
import 'package:mobile_app/core/app_routes.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import 'package:mobile_app/core/design_system.dart';
import 'package:mobile_app/core/app_dimensions.dart';
import 'package:mobile_app/widgets/glass_widgets.dart';
import 'package:mobile_app/providers/auth_provider.dart';
import 'package:mobile_app/providers/user_account_provider.dart';
import 'tabs/account_dashboard_tab.dart';
import 'tabs/my_bookings_tab.dart';
import 'tabs/favorites_tab.dart';
import 'tabs/payments_tab.dart';
import 'tabs/notifications_tab.dart';
import 'tabs/profile_settings_tab.dart';
import 'tabs/support_tab.dart';

class UserAccountScreen extends StatefulWidget {
  const UserAccountScreen({super.key});

  @override
  State<UserAccountScreen> createState() => _UserAccountScreenState();
}

class _UserAccountScreenState extends State<UserAccountScreen> {
  @override
  void initState() {
    super.initState();
    // Initial fetch
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<UserAccountProvider>(context, listen: false);
      provider.fetchDashboard();
      provider.fetchProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final user = auth.user;
    final accountProvider = Provider.of<UserAccountProvider>(context);


    return Scaffold(
      backgroundColor: AppColors.bgLight,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(user),
          
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
              child: _buildQuickStats(accountProvider),
            ),
          ),


          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const SizedBox(height: 10),
                _buildMenuSection("ACTIVITY", [
                  _buildMenuItem(Icons.calendar_month_outlined, "My Bookings", "View your service history", () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => Scaffold(appBar: AppBar(title: const Text("My Bookings")), body: const MyBookingsTab())));
                  }),
                  _buildMenuItem(Icons.favorite_outline_rounded, "Favorites", "Your saved providers", () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => Scaffold(appBar: AppBar(title: const Text("Favorites")), body: const FavoritesTab())));
                  }),
                ]),

                _buildMenuSection("WALLET & ALERTS", [
                  _buildMenuItem(Icons.account_balance_wallet_outlined, "Payments", "Manage your cards & billing", () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => Scaffold(appBar: AppBar(title: const Text("Payments")), body: const PaymentsTab())));
                  }),
                  _buildMenuItem(Icons.notifications_none_rounded, "Alerts", "Notification center", () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => Scaffold(appBar: AppBar(title: const Text("Alerts")), body: const NotificationsTab())));
                  }),
                ]),

                _buildMenuSection("ACCOUNT SETTINGS", [
                  _buildMenuItem(Icons.person_outline_rounded, "Profile Details", "Edit your information", () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => Scaffold(appBar: AppBar(title: const Text("Profile Settings")), body: const ProfileSettingsTab())));
                  }),
                  _buildMenuItem(Icons.support_agent_rounded, "Help & Support", "Get assistance & contact us", () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => Scaffold(appBar: AppBar(title: const Text("Support")), body: const SupportTab())));
                  }),

                  _buildMenuItem(Icons.logout_rounded, "Logout", "Sign out of your account", () => _showLogoutDialog(context), color: Colors.redAccent),
                ]),
                
                const SizedBox(height: 100),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(user) {
    return SliverAppBar(
      expandedHeight: 180,
      pinned: true,
      backgroundColor: AppColors.primary,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(gradient: AppGradients.primary),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 30),
              CircleAvatar(
                radius: 35,
                backgroundColor: Colors.white.withValues(alpha: 0.2),
                backgroundImage: user?.profileImage != null ? NetworkImage(user!.profileImage!) : null,
                child: user?.profileImage == null ? const Icon(Icons.person, size: 30, color: Colors.white) : null,
              ),
              const SizedBox(height: 8),
              Text(
                user?.fullName ?? "Guest User",
                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                user?.email ?? "",
                style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickStats(stats) {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem("Bookings", "${stats?.activeCount ?? 0}"),
          _buildStatDivider(),
          _buildStatItem("Spent", "₹${stats?.totalSpent.toInt() ?? 0}"),
          _buildStatDivider(),
          _buildStatItem("Reviews", "0"),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary)),
        Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
      ],
    );
  }

  Widget _buildStatDivider() {
    return Container(width: 1, height: 30, color: AppColors.divider);
  }

  Widget _buildMenuSection(String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12, top: 20),
          child: Text(title, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textTertiary, letterSpacing: 1.2)),
        ),
        GlassCard(
          padding: EdgeInsets.zero,
          child: Column(children: items),
        ),
      ],
    );
  }

  Widget _buildMenuItem(IconData icon, String title, String subtitle, VoidCallback onTap, {Color? color}) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: (color ?? AppColors.primary).withValues(alpha: 0.08), borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, color: color ?? AppColors.primary, size: 20),
      ),
      title: Text(title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: color ?? AppColors.textPrimary)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
      trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textTertiary, size: 20),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Logout"),
        content: const Text("Are you sure you want to sign out?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              final auth = context.read<AuthProvider>();
              final navigator = Navigator.of(context, rootNavigator: true);
              navigator.pop(); // Close dialog
              
              await auth.logout();
              
              // Direct navigation using captured navigator
              navigator.pushNamedAndRemoveUntil(AppRoutes.splash, (route) => false);
            }, 
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text("Logout"),
          ),
        ],
      ),
    );
  }
}




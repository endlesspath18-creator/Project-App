import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import 'package:mobile_app/providers/auth_provider.dart';
import 'package:mobile_app/core/api_client.dart';
import 'package:mobile_app/core/constants.dart';
import 'package:mobile_app/core/design_system.dart';
import 'package:mobile_app/core/app_dimensions.dart';
import 'package:mobile_app/widgets/glass_widgets.dart';
import 'package:mobile_app/features/profile/ui/profile_screen.dart';
import 'package:mobile_app/features/admin/ui/admin_banners_screen.dart';



class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _currentIndex = 0;
  bool _isLoading = true;
  Map<String, dynamic>? _stats;

  @override
  void initState() {
    super.initState();
    _checkAccess();
    _loadStats();
  }

  void _checkAccess() {
    final user = context.read<AuthProvider>().user;
    if (user?.email != "endlesspath18@gmail.com") {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Access Denied: Admin Only")));
        Navigator.pop(context);
      });
    }
  }

  Future<void> _loadStats() async {
    setState(() => _isLoading = true);
    try {
      final response = await ApiClient.get(AppConstants.adminStats);
      setState(() => _stats = response.data['data']);
    } catch (e) {
      debugPrint('Failed to load admin stats: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(child: Container(decoration: const BoxDecoration(gradient: AppGradients.bgGlow))),
          SafeArea(
            child: _buildBody(),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBody() {
    if (_currentIndex == 0) return _buildOverview();
    if (_currentIndex == 1) return const AdminBannersScreen();
    if (_currentIndex == 2) return const ProfileScreen();
    return const Center(child: Text("Error"));
  }

  Widget _buildOverview() {
    return RefreshIndicator(
      onRefresh: _loadStats,
      color: AppColors.primary,
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppDimensions.s24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("ADMIN PANEL", style: TextStyle(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 2)),
                      SizedBox(height: 4),
                      Text("Control Center", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  _buildProfileAvatar(),
                ],
              ),
            ),
          ),

          if (_isLoading)
            const SliverFillRemaining(child: Center(child: CircularProgressIndicator()))
          else if (_stats != null)
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 1.3,
                ),
                delegate: SliverChildListDelegate([
                  _buildStatCard("Users", "${_stats!['totalUsers']}", Icons.people_outline_rounded, Colors.blue),
                  _buildStatCard("Providers", "${_stats!['totalProviders']}", Icons.business_center_outlined, Colors.purple),
                  _buildStatCard("Bookings", "${_stats!['totalBookings']}", Icons.calendar_today_rounded, Colors.orange),
                  _buildStatCard("Revenue", "₹${_stats!['totalRevenue'].toInt()}", Icons.account_balance_wallet_outlined, Colors.green),
                ]),

              ),
            ),
          
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  Widget _buildProfileAvatar() {
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = 2),
      child: Container(
        width: 45, height: 45,
        decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), shape: BoxShape.circle),
        child: const Icon(Icons.admin_panel_settings_rounded, color: AppColors.primary),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return FadeInUp(
      child: GlassCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 12),
            Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      height: 70 + MediaQuery.of(context).padding.bottom,
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: const Border(top: BorderSide(color: AppColors.border, width: 0.5)),
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(Icons.analytics_outlined, Icons.analytics_rounded, "Stats", 0),
            _buildNavItem(Icons.photo_library_outlined, Icons.photo_library, "Pics", 1),
            _buildNavItem(Icons.person_outline, Icons.person, "Profile", 2),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData outline, IconData filled, String label, int index) {
    final isActive = _currentIndex == index;
    return InkWell(
      onTap: () => setState(() => _currentIndex = index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(isActive ? filled : outline, color: isActive ? AppColors.primary : AppColors.textTertiary),
          Text(label, style: TextStyle(color: isActive ? AppColors.primary : AppColors.textTertiary, fontSize: 10)),
        ],
      ),
    );
  }
}




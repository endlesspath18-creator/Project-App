import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import 'package:mobile_app/providers/auth_provider.dart';
import 'package:mobile_app/providers/service_provider.dart';
import 'package:mobile_app/providers/booking_provider.dart';
import 'package:mobile_app/providers/dashboard_provider.dart';
import 'package:mobile_app/core/app_routes.dart';
import 'package:mobile_app/core/design_system.dart';
import 'package:mobile_app/core/app_dimensions.dart';
import 'package:mobile_app/features/profile/ui/profile_screen.dart';
import 'package:mobile_app/widgets/glass_widgets.dart';
import 'package:mobile_app/features/provider/ui/update_bank_details_screen.dart';

class ProviderDashboard extends StatefulWidget {
  const ProviderDashboard({super.key});

  @override
  State<ProviderDashboard> createState() => _ProviderDashboardState();
}

class _ProviderDashboardState extends State<ProviderDashboard> {
  int _currentIndex = 0;
  final PageController _pageController = PageController();

  final List<Widget> _pages = [
    const _DashboardOverviewTab(),
    const _JobsManageTab(),
    const _EarningsTab(),
    const ProfileScreen(),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onTabTapped(int index) {
    setState(() => _currentIndex = index);
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _currentIndex == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (_currentIndex != 0) _onTabTapped(0);
      },
      child: Scaffold(
        body: PageView(
          controller: _pageController,
          onPageChanged: (index) => setState(() => _currentIndex = index),
          children: _pages,
        ),
        bottomNavigationBar: _buildBottomNav(context),
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    return Container(
      height: 70 + MediaQuery.of(context).padding.bottom,
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: const Border(top: BorderSide(color: AppColors.border, width: 0.5)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -5))
        ],
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(Icons.dashboard_outlined, Icons.dashboard_rounded, "Overview", 0),
            _buildNavItem(Icons.calendar_today_outlined, Icons.calendar_today_rounded, "Schedule", 1),
            _buildNavItem(Icons.account_balance_wallet_outlined, Icons.account_balance_wallet_rounded, "Earnings", 2),
            _buildNavItem(Icons.person_outline_rounded, Icons.person_rounded, "Profile", 3),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData outline, IconData filled, String label, int index) {
    final isActive = _currentIndex == index;
    return InkWell(
      onTap: () => _onTabTapped(index),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isActive ? filled : outline, 
              color: isActive ? AppColors.primary : AppColors.textTertiary, 
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label, 
              style: TextStyle(
                color: isActive ? AppColors.primary : AppColors.textTertiary, 
                fontSize: 10, 
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── DASHBOARD OVERVIEW TAB ──────────────────────────────────────────────────

class _DashboardOverviewTab extends StatefulWidget {
  const _DashboardOverviewTab();

  @override
  State<_DashboardOverviewTab> createState() => _DashboardOverviewTabState();
}

class _DashboardOverviewTabState extends State<_DashboardOverviewTab> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  Future<void> _loadData() async {
    await Future.wait([
      context.read<AuthProvider>().refreshUser(),
      context.read<DashboardProvider>().fetchStats(force: true),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final dashProvider = Provider.of<DashboardProvider>(context);
    final stats = dashProvider.stats;

    return Stack(
      children: [
        Positioned.fill(child: Container(decoration: const BoxDecoration(gradient: AppGradients.bgGlow))),
        SafeArea(
          child: RefreshIndicator(
            onRefresh: _loadData,
            color: AppColors.primary,
            child: CustomScrollView(
              slivers: [
                // 1. Header
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        FadeInDown(
                          child: Row(
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("HELLO 👋", style: TextStyle(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 2)),
                                  const SizedBox(height: 4),
                                  Text(authProvider.user?.fullName?.split(' ')[0].toUpperCase() ?? "PROVIDER", 
                                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                                ],
                              ),
                              const Spacer(),
                              _buildStatusToggle(dashProvider),
                            ],
                          ),
                        ),
                        if (stats?.requiresBankUpdate ?? false) ...[
                          const SizedBox(height: 24),
                          FadeInLeft(
                            child: _buildStrictBankPrompt(),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                // 2. Earnings Card
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: FadeInUp(
                      child: GlassCard(
                        padding: const EdgeInsets.all(24),
                        color: AppColors.primary.withValues(alpha: 0.05),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text("TODAY'S EARNINGS", style: TextStyle(color: AppColors.textSecondary, fontSize: 10, fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 4),
                                    Text("₹${stats?.todayEarnings.toInt() ?? 0}", style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), shape: BoxShape.circle),
                                  child: const Icon(Icons.account_balance_wallet_rounded, color: AppColors.primary),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            const Divider(color: AppColors.border),
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _buildMiniStat("Total Jobs", "${stats?.completedJobs ?? 0}"),
                                _buildMiniStat("Lifetime", "₹${stats?.totalEarnings.toInt() ?? 0}"),
                                _buildMiniStat("Rating", "4.8 ⭐"),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // 3. Quick Actions
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Row(
                        children: [
                          _buildActionChip(context, Icons.add_business_rounded, "Add Service", AppRoutes.addService),
                          const SizedBox(width: 12),
                          _buildActionChip(context, Icons.history_rounded, "Job History", null),
                          const SizedBox(width: 12),
                          _buildActionChip(context, Icons.verified_user_rounded, "Verify Account", null),
                        ],
                      ),
                    ),
                  ),
                ),

                // 4. Upcoming Jobs Section
                SliverToBoxAdapter(child: AppSectionLabel(label: "Confirmed Upcoming Jobs")),
                
                if (dashProvider.isLoading)
                  const SliverToBoxAdapter(child: Center(child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator())))
                else if (stats == null || stats.upcomingBookings.isEmpty)
                  SliverToBoxAdapter(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(48),
                        child: Column(
                          children: [
                            Opacity(opacity: 0.3, child: Icon(Icons.event_busy_rounded, size: 64, color: AppColors.textTertiary)),
                            const SizedBox(height: 16),
                            const Text("No upcoming jobs yet", style: TextStyle(color: AppColors.textSecondary)),
                          ],
                        ),
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => _EnhancedJobCard(booking: stats.upcomingBookings[index]),
                        childCount: stats.upcomingBookings.length,
                      ),
                    ),
                  ),
                
                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMiniStat(String label, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 10)),
      ],
    );
  }

  Widget _buildActionChip(BuildContext context, IconData icon, String label, String? route) {
    return GestureDetector(
      onTap: route != null ? () => Navigator.pushNamed(context, route) : null,
      child: GlassCard(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(icon, size: 18, color: AppColors.primary),
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusToggle(DashboardProvider dashProv) {
    final isOnline = dashProv.stats?.isOnline ?? true;
    return GestureDetector(
      onTap: () => dashProv.toggleOnline(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isOnline ? Colors.green.withValues(alpha: 0.1) : Colors.red.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isOnline ? Colors.green.withValues(alpha: 0.2) : Colors.red.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            CircleAvatar(radius: 4, backgroundColor: isOnline ? Colors.green : Colors.red),
            const SizedBox(width: 8),
            Text(isOnline ? "ONLINE" : "OFFLINE", style: TextStyle(color: isOnline ? Colors.green : Colors.red, fontSize: 10, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildStrictBankPrompt() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.red[900],
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.red.withValues(alpha: 0.3), blurRadius: 15, offset: const Offset(0, 8))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.white, size: 28),
              SizedBox(width: 12),
              Text(
                "ACTION REQUIRED",
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 1),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            "Update your banking details to receive payments for your services. This is mandatory for all providers.",
            style: TextStyle(color: Colors.white, fontSize: 13, height: 1.4),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context, 
                MaterialPageRoute(builder: (_) => const UpdateBankDetailsScreen())
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.red[900],
              minimumSize: const Size(double.infinity, 45),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              elevation: 0,
            ),
            child: const Text("UPDATE NOW", style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

// ─── ENHANCED JOB CARD (SaaS GRADE) ──────────────────────────────────────────

class _EnhancedJobCard extends StatelessWidget {
  final dynamic booking;
  const _EnhancedJobCard({required this.booking});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: GlassCard(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.person_rounded, color: AppColors.primary, size: 20),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(booking['user']['fullName'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      Text(booking['service']['title'], style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                    ],
                  ),
                ),
                Text("₹${booking['amount']}", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary)),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                _buildInfoTag(Icons.access_time_rounded, booking['slot'] ?? "Anytime"),
                const SizedBox(width: 12),
                _buildInfoTag(Icons.location_on_rounded, "Current Address"),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {}, 
                    icon: const Icon(Icons.phone_rounded, size: 18),
                    label: const Text("Call User"),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.blue,
                      side: const BorderSide(color: Colors.blue),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      // Logic to mark as completed
                      final success = await context.read<BookingProvider>().updateStatus(booking['id'], 'complete');
                      if (success && context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Job Completed! 🎊"), backgroundColor: Colors.green));
                        context.read<DashboardProvider>().fetchStats(force: true);
                      }
                    }, 
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text("Mark Done"),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTag(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(6), border: Border.all(color: AppColors.border)),
      child: Row(
        children: [
          Icon(icon, size: 12, color: AppColors.textTertiary),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}

// ─── PLACEHOLDER TABS ────────────────────────────────────────────────────────

class _JobsManageTab extends StatelessWidget {
  const _JobsManageTab();
  @override
  Widget build(BuildContext context) => const Scaffold(body: Center(child: Text("Full Schedule View")));
}

class _EarningsTab extends StatelessWidget {
  const _EarningsTab();
  @override
  Widget build(BuildContext context) => const Scaffold(body: Center(child: Text("Detailed Wallet View")));
}

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
import 'package:mobile_app/widgets/glass_widgets.dart';

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
    const _ProviderAccountTab(),
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
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) => setState(() => _currentIndex = index),
        children: _pages,
      ),
      bottomNavigationBar: _buildBottomNav(context),
      floatingActionButton: _currentIndex == 1 ? FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, AppRoutes.addService),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text("Add Service", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ) : null,
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
            _buildNavItem(Icons.dashboard_outlined, Icons.dashboard_rounded, "Stats", 0),
            _buildNavItem(Icons.business_center_outlined, Icons.business_center_rounded, "Jobs", 1),
            _buildNavItem(Icons.wallet_outlined, Icons.account_balance_wallet_rounded, "Earnings", 2),
            _buildNavItem(Icons.settings_outlined, Icons.settings_rounded, "Settings", 3),
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
      context.read<ServiceProvider>().fetchProviderServices(),
      context.read<BookingProvider>().fetchProviderRequests(),
      context.read<DashboardProvider>().fetchStats(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final dashProvider = Provider.of<DashboardProvider>(context);
    final user = authProvider.user;

    return Stack(
      children: [
        Positioned.fill(child: Container(decoration: const BoxDecoration(gradient: AppGradients.bgGlow))),
        SafeArea(
          child: RefreshIndicator(
            onRefresh: _loadData,
            color: AppColors.primary,
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(AppDimensions.s24),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("WELCOME BACK,", style: TextStyle(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 2)),
                              const SizedBox(height: 4),
                              Text(user?.businessName ?? "Business Name", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                        _buildStatusToggle(dashProvider),
                      ],
                    ),
                  ),
                ),

                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: FadeInUp(
                      child: GlassCard(
                        padding: const EdgeInsets.all(24),
                        color: AppColors.primary.withValues(alpha: 0.03),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("TOTAL EARNINGS", style: TextStyle(color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Text("₹${dashProvider.stats?.earnings.toInt() ?? 0}", style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
                                const Spacer(),
                                const Icon(Icons.arrow_upward_rounded, color: Colors.green, size: 20),
                                const Text(" 12%", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                SliverPadding(
                  padding: const EdgeInsets.all(24),
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 1.5,
                    ),
                    delegate: SliverChildListDelegate([
                      _buildQuickStat("Total Jobs", "${dashProvider.stats?.completedJobs ?? 0}", Icons.task_alt_rounded),
                      _buildQuickStat("AVG. Rating", "${dashProvider.stats?.rating ?? 0.0}", Icons.star_rounded),
                    ]),
                  ),
                ),

                const SliverToBoxAdapter(child: AppSectionLabel(label: "Recent Activity")),
                
                Consumer<BookingProvider>(
                  builder: (context, prov, _) {
                    if (prov.isLoading) return const SliverToBoxAdapter(child: Center(child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator())));
                    if (prov.incomingRequests.isEmpty) return const SliverToBoxAdapter(child: Center(child: Padding(padding: EdgeInsets.all(48), child: Text("No recent requests", style: TextStyle(color: AppColors.textSecondary)))));
                    
                    return SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) => _SmallJobCard(booking: prov.incomingRequests[index]),
                          childCount: prov.incomingRequests.length > 3 ? 3 : prov.incomingRequests.length,
                        ),
                      ),
                    );
                  }
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickStat(String label, String value, IconData icon) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 10)),
        ],
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
}

// ─── JOBS MANAGEMENT TAB ────────────────────────────────────────────────────

class _JobsManageTab extends StatefulWidget {
  const _JobsManageTab();

  @override
  State<_JobsManageTab> createState() => _JobsManageTabState();
}

class _JobsManageTabState extends State<_JobsManageTab> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Jobs Management", style: TextStyle(fontWeight: FontWeight.bold)),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          tabs: const [
            Tab(text: "Requests"),
            Tab(text: "Active"),
            Tab(text: "History"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _RequestListView(),
          PlaceholderScreen(title: "Active Jobs"),
          PlaceholderScreen(title: "Job History"),
        ],
      ),
    );
  }
}

class _RequestListView extends StatelessWidget {
  const _RequestListView();

  @override
  Widget build(BuildContext context) {
     final bookingProvider = Provider.of<BookingProvider>(context);
     if (bookingProvider.incomingRequests.isEmpty) return const Center(child: Text("No pending requests"));
     
     return ListView.builder(
       padding: const EdgeInsets.all(24),
       itemCount: bookingProvider.incomingRequests.length,
       itemBuilder: (context, index) => _FullJobCard(booking: bookingProvider.incomingRequests[index]),
     );
  }
}

// ─── EARNINGS TAB ────────────────────────────────────────────────────────────

class _EarningsTab extends StatelessWidget {
  const _EarningsTab();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Earnings")),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            GlassCard(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const Text("AVAILABLE FOR WITHDRAWAL", style: TextStyle(color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  const Text("₹12,450.00", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  GlassButton(onPressed: () {}, text: "Withdraw to Bank"),
                ],
              ),
            ),
            const SizedBox(height: 32),
            const AppSectionLabel(label: "Recent Transactions"),
            Expanded(
              child: ListView.builder(
                itemCount: 5,
                itemBuilder: (context, index) => _TransactionItem(index: index),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TransactionItem extends StatelessWidget {
  final int index;
  const _TransactionItem({required this.index});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const CircleAvatar(backgroundColor: Color(0xFFE8F5E9), child: Icon(Icons.arrow_downward_rounded, color: Colors.green)),
      title: const Text("Payment for Home Cleaning"),
      subtitle: const Text("24 April 2026"),
      trailing: const Text("+₹450", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
      contentPadding: const EdgeInsets.symmetric(vertical: 8),
    );
  }
}

// ─── PROFILE TAB ────────────────────────────────────────────────────────────

class _ProviderAccountTab extends StatelessWidget {
  const _ProviderAccountTab();

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    return Scaffold(
      appBar: AppBar(title: const Text("Business Profile")),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 24),
            CircleAvatar(radius: 50, backgroundColor: AppColors.primary.withValues(alpha: 0.1), child: const Icon(Icons.business_rounded, size: 50, color: AppColors.primary)),
            const SizedBox(height: 16),
            Text(user?.businessName ?? "Business Name", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            Text(user?.email ?? "", style: const TextStyle(color: AppColors.textSecondary)),
            const SizedBox(height: 32),
            Padding(
               padding: const EdgeInsets.symmetric(horizontal: 24),
               child: Column(
                 children: [
                   _AccountItem(Icons.edit_note_rounded, "Edit Business Info", () {}),
                   _AccountItem(Icons.notifications_outlined, "Notifications", () {}),
                   _AccountItem(Icons.security_rounded, "Privacy & Security", () {}),
                   _AccountItem(Icons.help_center_outlined, "Help Center", () {}),
                   const Divider(height: 48),
                   _AccountItem(Icons.logout_rounded, "Logout", () {
                     authProvider.logout().then((_) => Navigator.pushReplacementNamed(context, AppRoutes.welcome));
                   }, isDestructive: true),
                 ],
               ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── CARDS ──────────────────────────────────────────────────────────────────

class _SmallJobCard extends StatelessWidget {
  final dynamic booking;
  const _SmallJobCard({required this.booking});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: GlassCard(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.circle, size: 10, color: AppColors.primary),
            const SizedBox(width: 12),
            Expanded(child: Text(booking['user']['fullName'], style: const TextStyle(fontWeight: FontWeight.w600))),
            Text("₹${booking['totalAmount']}", style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}

class _FullJobCard extends StatelessWidget {
  final dynamic booking;
  const _FullJobCard({required this.booking});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(backgroundColor: AppColors.primary.withValues(alpha: 0.1), child: const Icon(Icons.person, color: AppColors.primary)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(booking['user']['fullName'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    Text(booking['service']['title'], style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                  ],
                ),
              ),
              Text("₹${booking['totalAmount']}", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(child: GlassButton(onPressed: () {}, text: "Reject", isPrimary: false)),
              const SizedBox(width: 12),
              Expanded(child: GlassButton(onPressed: () {}, text: "Accept")),
            ],
          ),
        ],
      ),
    );
  }
}

class _AccountItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool isDestructive;

  const _AccountItem(this.icon, this.title, this.onTap, {this.isDestructive = false});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: isDestructive ? AppColors.error : AppColors.primary),
      title: Text(title, style: TextStyle(fontWeight: FontWeight.w500, color: isDestructive ? AppColors.error : AppColors.textPrimary)),
      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
      contentPadding: EdgeInsets.zero,
    );
  }
}

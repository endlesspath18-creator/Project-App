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
    _loadStats();
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
    if (_currentIndex == 4) return const ProfileScreen();
    return _buildManagementView();
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
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("ADMIN PANEL", style: TextStyle(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 2)),
                      const SizedBox(height: 4),
                      const Text("Control Center", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
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
                  _buildStatCard("Services", "${_stats!['totalServices']}", Icons.home_repair_service_outlined, Colors.teal),
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
      onTap: () => setState(() => _currentIndex = 4),
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

  Widget _buildManagementView() {
    switch (_currentIndex) {
      case 1: return const _UserManagementList(role: 'USER');
      case 2: return const _UserManagementList(role: 'PROVIDER');
      case 3: return const _BookingManagementList();
      default: return const Center(child: Text("Coming Soon"));
    }
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
            _buildNavItem(Icons.people_outline_rounded, Icons.people_alt_rounded, "Users", 1),
            _buildNavItem(Icons.business_center_outlined, Icons.business_center_rounded, "Pros", 2),
            _buildNavItem(Icons.receipt_long_outlined, Icons.receipt_long_rounded, "Logs", 3),
            _buildNavItem(Icons.person_outline, Icons.person, "Profile", 4),
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

class _UserManagementList extends StatefulWidget {
  final String role;
  const _UserManagementList({required this.role});

  @override
  State<_UserManagementList> createState() => _UserManagementListState();
}

class _UserManagementListState extends State<_UserManagementList> {
  List<dynamic> _users = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    setState(() => _loading = true);
    try {
      final endpoint = widget.role == 'USER' ? '/admin/users' : '/admin/providers';
      final response = await ApiClient.get(endpoint);
      setState(() => _users = response.data['data']);
    } catch (e) {
      debugPrint('Error: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _toggleStatus(String id) async {
    try {
      await ApiClient.patch('/admin/users/$id/toggle-status', {});
      _fetch();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Action failed: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(24),
          child: Text("${widget.role} MANAGEMENT", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        ),
        Expanded(
          child: _loading 
            ? const Center(child: CircularProgressIndicator()) 
            : ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                itemCount: _users.length,
                itemBuilder: (context, index) {
                  final u = _users[index];
                  final isActive = u['isActive'] ?? true;
                  return GlassCard(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                          child: Text(u['fullName'][0]),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(u['fullName'], style: const TextStyle(fontWeight: FontWeight.bold)),
                              Text(u['email'], style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                            ],
                          ),
                        ),
                        Switch(
                          value: isActive, 
                          onChanged: (_) => _toggleStatus(u['id']),
                          activeColor: AppColors.primary,
                        ),
                      ],
                    ),
                  );
                },
              ),
        ),
      ],
    );
  }
}

class _BookingManagementList extends StatefulWidget {
  const _BookingManagementList();

  @override
  State<_BookingManagementList> createState() => _BookingManagementListState();
}

class _BookingManagementListState extends State<_BookingManagementList> {
  List<dynamic> _bookings = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    setState(() => _loading = true);
    try {
      final response = await ApiClient.get('/admin/bookings');
      setState(() => _bookings = response.data['data']);
    } catch (e) {
      debugPrint('Error: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.all(24),
          child: Text("GLOBAL BOOKING LOGS", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        ),
        Expanded(
          child: _loading 
            ? const Center(child: CircularProgressIndicator()) 
            : ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                itemCount: _bookings.length,
                itemBuilder: (context, index) {
                  final b = _bookings[index];
                  return GlassCard(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(b['service']['title'], style: const TextStyle(fontWeight: FontWeight.bold)),
                            Text("₹${b['amount']}", style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const Divider(height: 20),
                        Row(
                          children: [
                            const Icon(Icons.person, size: 12, color: AppColors.textSecondary),
                            Text(" ${b['user']['fullName']}", style: const TextStyle(fontSize: 11)),
                            const Spacer(),
                            const Icon(Icons.business_center, size: 12, color: AppColors.textSecondary),
                            Text(" ${b['provider']['fullName']}", style: const TextStyle(fontSize: 11)),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
        ),
      ],
    );
  }
}

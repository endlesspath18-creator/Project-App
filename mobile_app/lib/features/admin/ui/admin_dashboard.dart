import 'package:flutter/material.dart';
import 'package:mobile_app/core/api_client.dart';
import 'package:mobile_app/core/constants.dart';
import 'package:mobile_app/core/design_system.dart';
import 'package:mobile_app/widgets/glass_widgets.dart';
import 'package:mobile_app/features/admin/ui/admin_banners_screen.dart';


class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {

  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLight,
      body: SafeArea(
        child: IndexedStack(
          index: _currentIndex,
          children: [
            const _AdminHomeTab(),
            const Center(child: Text("Admin Panel Overview")),
            const Center(child: Text("General Settings")),
            const Center(child: Text("Provider Accounts Controller")),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textTertiary,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.admin_panel_settings_outlined), label: "Admin"),
          BottomNavigationBarItem(icon: Icon(Icons.settings_outlined), label: "Settings"),
          BottomNavigationBarItem(icon: Icon(Icons.people_outline), label: "Providers"),
        ],
      ),
    );
  }
}

class _AdminHomeTab extends StatefulWidget {
  const _AdminHomeTab();
  @override
  State<_AdminHomeTab> createState() => _AdminHomeTabState();
}

class _AdminHomeTabState extends State<_AdminHomeTab> {
  bool _isLoading = true;
  Map<String, dynamic>? _stats;
  List<dynamic> _bookings = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final statsRes = await ApiClient.get(AppConstants.adminStats);
      final bookingsRes = await ApiClient.get('/admin/bookings');
      setState(() {
        _stats = statsRes.data['data'];
        _bookings = bookingsRes.data['data'] ?? [];
      });
    } catch (e) {
      debugPrint('Admin load error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());

    return RefreshIndicator(
      onRefresh: _loadData,
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("DASHBOARD", style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, letterSpacing: 1.5, fontSize: 12)),
                  const SizedBox(height: 8),
                  const Text("Home Control", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  
                  // No. of Orders Section
                  _buildOrderStatsSection(),
                  const SizedBox(height: 24),
                  
                  // Banners Section
                  _buildBannerManagementCard(),
                  const SizedBox(height: 24),
                  
                  const Text("ORDER DETAILS", style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
          
          // Orders List Section
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => _buildOrderTile(_bookings[index]),
                childCount: _bookings.length,
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  Widget _buildOrderStatsSection() {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.blue.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.shopping_bag_outlined, color: Colors.blue),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("${_stats?['totalBookings'] ?? 0}", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const Text("Total Orders", style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
            ],
          ),
          const Spacer(),
          const Icon(Icons.trending_up, color: Colors.green, size: 20),
        ],
      ),
    );
  }

  Widget _buildBannerManagementCard() {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminBannersScreen())),
      child: GlassCard(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.pink.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.photo_library_outlined, color: Colors.pink),
            ),
            const SizedBox(width: 16),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Scrolling Pics", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Text("Add/Manage Banners", style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.textTertiary),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderTile(dynamic booking) {
    final status = booking['status'] ?? 'PENDING';
    final paymentStatus = booking['paymentStatus'] ?? 'PENDING';
    
    return GlassCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(booking['service']['title'] ?? 'Service', style: const TextStyle(fontWeight: FontWeight.bold)),
              Text("₹${booking['amount']}", style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.person_outline, size: 14, color: AppColors.textSecondary),
              const SizedBox(width: 4),
              Text(booking['user']['fullName'] ?? 'User', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            ],
          ),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildBadge(status, _getStatusColor(status)),
              _buildBadge("PAYMENT: $paymentStatus", paymentStatus == 'PAID' ? Colors.green : Colors.orange),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
      child: Text(label, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'COMPLETED': return Colors.green;
      case 'CANCELLED': return Colors.red;
      case 'CONFIRMED': return Colors.blue;
      default: return Colors.orange;
    }
  }
}







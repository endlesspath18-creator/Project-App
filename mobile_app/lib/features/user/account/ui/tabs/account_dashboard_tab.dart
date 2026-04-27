import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import 'package:mobile_app/core/design_system.dart';
import 'package:mobile_app/core/app_dimensions.dart';
import 'package:mobile_app/providers/user_account_provider.dart';
import 'package:mobile_app/widgets/glass_widgets.dart';

class AccountDashboardTab extends StatelessWidget {
  const AccountDashboardTab({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<UserAccountProvider>(context);
    final data = provider.dashboardData;
    final isLoading = provider.isLoading && data == null;

    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (data == null) {
      return const Center(child: Text("Failed to load dashboard data"));
    }

    final upcoming = data['upcomingBookings'] as List?;
    final stats = data['stats'];
    final activity = data['recentActivity'] as List?;

    return RefreshIndicator(
      onRefresh: () => provider.fetchDashboard(),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.s20),
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatsGrid(stats),
            const SizedBox(height: AppDimensions.s24),
            _buildUpcomingSection(context, upcoming),
            const SizedBox(height: AppDimensions.s24),
            _buildQuickActions(context),
            const SizedBox(height: AppDimensions.s24),
            _buildRecentActivity(activity),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsGrid(dynamic stats) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        _buildStatCard("Total Bookings", stats?['totalBookings']?.toString() ?? "0", Icons.calendar_today_rounded, Colors.blue),
        _buildStatCard("Active Jobs", stats?['activeBookings']?.toString() ?? "0", Icons.bolt_rounded, Colors.orange),
        _buildStatCard("Saved", stats?['savedProviders']?.toString() ?? "0", Icons.favorite_rounded, Colors.red),
        _buildStatCard("Support", "0", Icons.support_agent_rounded, Colors.green),
      ],
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
            const SizedBox(height: 8),
            Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            Text(label, style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildUpcomingSection(BuildContext context, List? upcoming) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Upcoming Bookings", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        if (upcoming == null || upcoming.isEmpty)
          GlassCard(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    Icon(Icons.calendar_month_outlined, size: 48, color: AppColors.textTertiary),
                    const SizedBox(height: 8),
                    const Text("No upcoming bookings", style: TextStyle(color: AppColors.textSecondary)),
                    TextButton(onPressed: () {}, child: const Text("Book Now")),
                  ],
                ),
              ),
            ),
          )
        else
          ...upcoming.map((b) => _buildBookingCard(context, b)).toList(),
      ],
    );
  }

  Widget _buildBookingCard(BuildContext context, dynamic booking) {
    return FadeInLeft(
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        child: GlassCard(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.cleaning_services_rounded, color: AppColors.primary),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(booking['service']['title'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    Text(booking['provider']['fullName'], style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.access_time, size: 14, color: AppColors.primary),
                        const SizedBox(width: 4),
                        Text(booking['slot'] ?? "TBD", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  booking['status'],
                  style: const TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Quick Actions", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _actionButton(Icons.add_circle_outline_rounded, "Book New", () {}),
            _actionButton(Icons.refresh_rounded, "Rebook", () {}),
            _actionButton(Icons.support_agent_rounded, "Support", () {}),
            _actionButton(Icons.star_outline_rounded, "Review", () {}),
          ],
        ),
      ],
    );
  }

  Widget _actionButton(IconData icon, String label, VoidCallback onTap) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))],
            ),
            child: Icon(icon, color: AppColors.primary),
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildRecentActivity(List? activity) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Recent Activity", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        if (activity == null || activity.isEmpty)
          const Text("No recent activity", style: TextStyle(color: AppColors.textSecondary))
        else
          GlassCard(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              children: activity.map((a) => ListTile(
                leading: const CircleAvatar(
                  radius: 16,
                  backgroundColor: AppColors.bgLight,
                  child: Icon(Icons.history, size: 16, color: AppColors.textTertiary),
                ),
                title: Text("Booking ${a['toStatus'].toString().toLowerCase()}", style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                subtitle: Text(a['booking']['service']['title'], style: const TextStyle(fontSize: 12)),
                trailing: Text(_formatDate(a['createdAt']), style: TextStyle(fontSize: 10, color: AppColors.textTertiary)),
              )).toList(),
            ),
          ),
      ],
    );
  }

  String _formatDate(String dateStr) {
    final date = DateTime.parse(dateStr);
    return "${date.day}/${date.month}";
  }
}

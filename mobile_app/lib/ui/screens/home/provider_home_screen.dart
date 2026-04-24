import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/service_provider.dart';
import '../../../providers/booking_provider.dart';
import '../../../providers/dashboard_provider.dart';
import '../../../core/app_routes.dart';
import '../../../core/design_system.dart';
import '../../../widgets/glass_widgets.dart';

class ProviderHomeScreen extends StatefulWidget {
  const ProviderHomeScreen({super.key});

  @override
  State<ProviderHomeScreen> createState() => _ProviderHomeScreenState();
}

class _ProviderHomeScreenState extends State<ProviderHomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    final serviceProv = context.read<ServiceProvider>();
    final bookingProv = context.read<BookingProvider>();
    final dashProv = context.read<DashboardProvider>();

    await Future.wait([
      serviceProv.fetchProviderServices(),
      bookingProv.fetchProviderRequests(),
      bookingProv.fetchActiveJobs(),
      dashProv.fetchStats(),
    ]);
  }

  Future<void> _handleRefresh() async {
    await _loadData();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final dashProvider = Provider.of<DashboardProvider>(context);
    final bookingProvider = Provider.of<BookingProvider>(context);
    final user = authProvider.user;

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(child: Container(decoration: const BoxDecoration(gradient: GlacierGradients.bgGlow))),
          SafeArea(
            child: RefreshIndicator(
              onRefresh: _handleRefresh,
              color: GlacierColors.primary,
              backgroundColor: GlacierColors.surface,
              child: CustomScrollView(
                slivers: [
                  // ─── Header ──────────────────────────────────────────
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("Business Dashboard", style: TextStyle(color: GlacierColors.primary, fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                              const SizedBox(height: 4),
                              Text(user?.businessName ?? "Service Expert", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                            ],
                          ),
                           _buildStatusToggle(dashProvider),
                        ],
                      ),
                    ),
                  ),

                  // ─── Stats Card ──────────────────────────────────────────
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: FadeInUp(
                        child: GlassCard(
                          padding: const EdgeInsets.all(24),
                          color: GlacierColors.primary.withOpacity(0.05),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("ESTIMATED EARNINGS", style: TextStyle(color: Colors.white38, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Text("₹${dashProvider.stats?.earnings.toInt() ?? 0}", style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold)),
                                  const Spacer(),
                                  const Icon(Icons.show_chart, color: Colors.greenAccent),
                                ],
                              ),
                              const SizedBox(height: 24),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  _buildStatItem("Completed", "${dashProvider.stats?.completedJobs ?? 0}"),
                                  _buildStatItem("Rating", "${dashProvider.stats?.rating ?? 0.0}"),
                                  _buildStatItem("Requests", "${dashProvider.stats?.pendingRequests ?? 0}"),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  // ─── New Requests ──────────────────────────────────────────
                  const SliverToBoxAdapter(child: SizedBox(height: 32)),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("New Requests", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                          if (bookingProvider.incomingRequests.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(color: GlacierColors.primary, borderRadius: BorderRadius.circular(10)),
                              child: Text("${bookingProvider.incomingRequests.length}", style: const TextStyle(color: GlacierColors.background, fontSize: 12, fontWeight: FontWeight.bold)),
                            ),
                        ],
                      ),
                    ),
                  ),

                  if (bookingProvider.incomingRequests.isEmpty)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(48.0),
                        child: Center(child: Text("No pending requests", style: TextStyle(color: Colors.white.withOpacity(0.3)))),
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.all(24),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) => _RequestCard(
                            booking: bookingProvider.incomingRequests[index],
                            onAccept: () => _handleStatusUpdate(bookingProvider.incomingRequests[index]['id'], 'accept'),
                            onReject: () => _handleStatusUpdate(bookingProvider.incomingRequests[index]['id'], 'reject'),
                          ),
                          childCount: bookingProvider.incomingRequests.length,
                        ),
                      ),
                    ),

                  const SliverToBoxAdapter(child: SizedBox(height: 80)),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, AppRoutes.addService),
        backgroundColor: GlacierColors.primary,
        child: const Icon(Icons.add, color: GlacierColors.background),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(color: Colors.white38, fontSize: 11)),
      ],
    );
  }

  Widget _buildStatusToggle(DashboardProvider dashProv) {
    final isOnline = dashProv.stats?.isOnline ?? true;
    return GestureDetector(
      onTap: () => dashProv.toggleOnline(),
      child: GlassCard(
        borderRadius: 12,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        color: isOnline ? Colors.greenAccent.withOpacity(0.1) : Colors.redAccent.withOpacity(0.1),
        border: Border.all(color: isOnline ? Colors.greenAccent.withOpacity(0.2) : Colors.redAccent.withOpacity(0.2)),
        child: Row(
          children: [
            CircleAvatar(radius: 4, backgroundColor: isOnline ? Colors.greenAccent : Colors.redAccent),
            const SizedBox(width: 8),
            Text(isOnline ? "ONLINE" : "OFFLINE", style: TextStyle(color: isOnline ? Colors.greenAccent : Colors.redAccent, fontSize: 11, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Future<void> _handleStatusUpdate(String id, String action) async {
    await context.read<BookingProvider>().updateStatus(id, action);
    await context.read<DashboardProvider>().fetchStats();
  }
}

class _RequestCard extends StatelessWidget {
  final dynamic booking;
  final VoidCallback onAccept;
  final VoidCallback onReject;

  const _RequestCard({required this.booking, required this.onAccept, required this.onReject});

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
                const CircleAvatar(backgroundColor: Colors.white10, child: Icon(Icons.person, color: GlacierColors.primary)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(booking['user']['fullName'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      Text(booking['service']['title'], style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 12)),
                    ],
                  ),
                ),
                Text("₹${booking['totalAmount']}", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: GlassButton(onPressed: onReject, text: "Reject", isPrimary: false),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GlassButton(onPressed: onAccept, text: "Accept"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

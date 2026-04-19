import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/service_provider.dart';
import '../../../providers/booking_provider.dart';
import '../../../providers/dashboard_provider.dart';
import '../../../core/app_routes.dart';
import '../../../core/motion_utils.dart';
import '../../../widgets/animated_background.dart';
import '../../../widgets/auth_card.dart';

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
      backgroundColor: const Color(0xFFF8FAFC),
      body: AnimatedBackground(
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: _handleRefresh,
            color: Theme.of(context).primaryColor,
            child: CustomScrollView(
              slivers: [
                // ─── Header & Profile ────────────────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        FadeInDown(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Business Dashboard',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Theme.of(context).primaryColor,
                                  letterSpacing: 1.2,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                user?.businessName ?? user?.fullName ?? 'Service Expert',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1E293B),
                                ),
                              ),
                            ],
                          ),
                        ),
                        FadeInRight(
                          child: Row(
                            children: [
                              _buildStatusToggle(dashProvider),
                              const SizedBox(width: 12),
                              _buildLogoutButton(authProvider),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // ─── Earnings & Stats ────────────────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: dashProvider.isLoading && dashProvider.stats == null
                      ? _buildShimmerStats()
                      : FadeInUp(
                          child: Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF1E293B).withValues(alpha: 0.2),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text('Estimated Earnings', style: TextStyle(color: Colors.white70, fontSize: 14)),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.green.withValues(alpha: 0.2),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Text('Live', style: TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold)),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Text(
                                      '₹${dashProvider.stats?.earnings.toInt() ?? 0}',
                                      style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
                                    ),
                                    const Spacer(),
                                    const Icon(Icons.trending_up, color: Colors.green, size: 24),
                                  ],
                                ),
                                const SizedBox(height: 24),
                                const Divider(color: Colors.white10),
                                const SizedBox(height: 20),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    _buildSmallStat('Completed', '${dashProvider.stats?.completedJobs ?? 0}', Icons.check_circle_outline),
                                    _buildSmallStat('Rating', '${dashProvider.stats?.rating ?? 0.0}', Icons.star_outline),
                                    _buildSmallStat('Pending', '${dashProvider.stats?.pendingRequests ?? 0}', Icons.hourglass_empty),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                  ),
                ),

                // ─── Incoming Requests ──────────────────────────────────────
                const SliverToBoxAdapter(child: SizedBox(height: 32)),
                _buildSectionHeader('New Requests', bookingProvider.incomingRequests.length),
                
                if (bookingProvider.isLoading && bookingProvider.incomingRequests.isEmpty)
                  const SliverToBoxAdapter(child: Center(child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator())))
                else if (bookingProvider.incomingRequests.isEmpty)
                  _buildEmptyState('No new requests right now.', Icons.notifications_none_rounded)
                else
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
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

                // ─── Active Jobs ────────────────────────────────────────────
                const SliverToBoxAdapter(child: SizedBox(height: 32)),
                _buildSectionHeader('Active Jobs', bookingProvider.providerBookings.length),

                if (bookingProvider.providerBookings.isEmpty)
                  _buildEmptyState('No jobs in progress.', Icons.work_outline_rounded)
                else
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final job = bookingProvider.providerBookings[index];
                          return _ActiveJobCard(
                            job: job,
                            onStart: () => _handleStatusUpdate(job['id'], 'start'),
                            onComplete: () => _handleStatusUpdate(job['id'], 'complete'),
                          );
                        },
                        childCount: bookingProvider.providerBookings.length,
                      ),
                    ),
                  ),

                const SliverToBoxAdapter(child: SizedBox(height: 40)),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, AppRoutes.addService),
        backgroundColor: const Color(0xFF1E293B),
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text('New Service', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildSectionHeader(String title, int count) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8),
        child: Row(
          children: [
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
            const SizedBox(width: 8),
            if (count > 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(color: const Color(0xFF2563EB), borderRadius: BorderRadius.circular(10)),
                child: Text('$count', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(String message, IconData icon) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          children: [
            Icon(icon, size: 48, color: Colors.grey[300]),
            const SizedBox(height: 12),
            Text(message, style: TextStyle(color: Colors.grey[400], fontSize: 13)),
          ],
        ),
      ),
    );
  }

  Widget _buildSmallStat(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white38, size: 16),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(color: Colors.white38, fontSize: 10)),
      ],
    );
  }

  Widget _buildStatusToggle(DashboardProvider dashProv) {
    final isOnline = dashProv.stats?.isOnline ?? true;
    return MotionUtils.tapScale(
      onTap: () => dashProv.toggleOnline(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isOnline ? Colors.green.withValues(alpha: 0.1) : Colors.red.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: (isOnline ? Colors.green : Colors.red).withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            CircleAvatar(radius: 4, backgroundColor: isOnline ? Colors.green : Colors.red),
            const SizedBox(width: 6),
            Text(
              isOnline ? 'Online' : 'Offline',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isOnline ? Colors.green : Colors.red),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutButton(AuthProvider auth) {
    return MotionUtils.tapScale(
      onTap: () async {
        await auth.logout();
        if (mounted) Navigator.pushReplacementNamed(context, AppRoutes.login);
      },
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.black12)),
        child: const Icon(Icons.logout_rounded, color: Colors.redAccent, size: 20),
      ),
    );
  }

  Widget _buildShimmerStats() {
    return Container(
      height: 200,
      decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(24)),
    );
  }

  Future<void> _handleStatusUpdate(String id, String action) async {
    final success = await context.read<BookingProvider>().updateStatus(id, action);
    if (success && mounted) {
      await context.read<DashboardProvider>().fetchStats();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Job updated: $action')));
    }
  }
}

class _RequestCard extends StatelessWidget {
  final dynamic booking;
  final VoidCallback onAccept;
  final VoidCallback onReject;

  const _RequestCard({required this.booking, required this.onAccept, required this.onReject});

  @override
  Widget build(BuildContext context) {
    return FadeInRight(
      child: AuthCard(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(backgroundColor: Colors.blue[50], child: const Icon(Icons.person, color: Colors.blue)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(booking['user']['fullName'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      Text(booking['service']['title'], style: TextStyle(color: Colors.grey[500], fontSize: 13)),
                    ],
                  ),
                ),
                Text('₹${booking['totalAmount']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.location_on_outlined, size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Expanded(child: Text(booking['address'], style: const TextStyle(color: Colors.grey, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis)),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onReject,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.redAccent),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Reject'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onAccept,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Accept Request'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ActiveJobCard extends StatelessWidget {
  final dynamic job;
  final VoidCallback onStart;
  final VoidCallback onComplete;

  const _ActiveJobCard({required this.job, required this.onStart, required this.onComplete});

  @override
  Widget build(BuildContext context) {
    final bool isAccepted = job['status'] == 'ACCEPTED';
    
    return FadeInUp(
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFF2563EB).withValues(alpha: 0.1)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(12)),
                    child: const Icon(Icons.engineering_rounded, color: Color(0xFF2563EB), size: 24),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(job['service']['title'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        Text('Customer: ${job['user']['fullName']}', style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                      ],
                    ),
                  ),
                  _buildStatusChip(job['status']),
                ],
              ),
              const SizedBox(height: 20),
              if (isAccepted)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: onStart,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Start Work'),
                  ),
                )
              else
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: onComplete,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Mark as Completed'),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    final Color color = status == 'ACCEPTED' ? Colors.blue : Colors.orange;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
      child: Text(status, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color)),
    );
  }
}

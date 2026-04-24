import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import 'package:mobile_app/providers/booking_provider.dart';
import 'package:mobile_app/providers/auth_provider.dart';
import 'package:mobile_app/core/design_system.dart';
import 'package:mobile_app/core/app_dimensions.dart';
import 'package:mobile_app/widgets/glass_widgets.dart';

class BookingsView extends StatefulWidget {
  final bool isStandalone;
  const BookingsView({super.key, this.isStandalone = false});

  @override
  State<BookingsView> createState() => _BookingsViewState();
}

class _BookingsViewState extends State<BookingsView> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      if (auth.isAuthenticated && !auth.isProvider && !auth.isAdmin) {
        context.read<BookingProvider>().fetchUserBookings();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final bookingProvider = Provider.of<BookingProvider>(context);

    Widget content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.isStandalone) ...[
          const SizedBox(height: 16),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Text("My Bookings", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
          ),
        ],
        Expanded(
          child: RefreshIndicator(
            onRefresh: () => bookingProvider.fetchUserBookings(),
            color: AppColors.primary,
            child: _buildBookingList(bookingProvider),
          ),
        ),
      ],
    );

    if (widget.isStandalone) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary),
          ),
        ),
        extendBodyBehindAppBar: true,
        body: Stack(
          children: [
            Positioned.fill(child: Container(decoration: const BoxDecoration(gradient: AppGradients.bgGlow))),
            SafeArea(child: content),
          ],
        ),
      );
    }

    return content;
  }

  Widget _buildBookingList(BookingProvider prov) {
    if (prov.isLoading && prov.userBookings.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (prov.userBookings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.calendar_today_outlined, size: 64, color: AppColors.textTertiary.withValues(alpha: 0.2)),
            const SizedBox(height: 16),
            const Text("No bookings found", style: TextStyle(color: AppColors.textSecondary)),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => prov.fetchUserBookings(),
              child: const Text("Refresh"),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      itemCount: prov.userBookings.length,
      itemBuilder: (context, index) {
        final booking = prov.userBookings[index];
        final isPaid = booking['paymentStatus'] == 'PAID';
        
        return FadeInUp(
          delay: Duration(milliseconds: 50 * index),
          child: GlassCard(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 50, height: 50,
                      decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                      child: const Icon(Icons.home_repair_service, color: AppColors.primary),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(booking['service']['title'], style: const TextStyle(fontWeight: FontWeight.bold)),
                          Text("by ${booking['provider']['businessName']}", style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text("₹${booking['amount']}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        Text(booking['paymentMethod'] ?? 'COD', style: const TextStyle(fontSize: 9, color: AppColors.textTertiary)),
                      ],
                    ),
                  ],
                ),
                const Divider(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _statusBadge(booking['status'] ?? 'PENDING'),
                    Row(
                      children: [
                        Icon(Icons.check_circle, size: 12, color: isPaid ? Colors.green : AppColors.textTertiary),
                        const SizedBox(width: 4),
                        Text(isPaid ? "Paid Online" : "Payment Pending", style: TextStyle(fontSize: 10, color: isPaid ? Colors.green : AppColors.textTertiary)),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _statusBadge(String status) {
    Color color;
    switch (status.toUpperCase()) {
      case 'ACCEPTED': color = Colors.blue; break;
      case 'COMPLETED': color = Colors.green; break;
      case 'REJECTED': color = Colors.red; break;
      case 'IN_PROGRESS': color = Colors.orange; break;
      default: color = Colors.grey;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
      child: Text(status, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }
}

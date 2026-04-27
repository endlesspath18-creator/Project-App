import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile_app/core/design_system.dart';
import 'package:mobile_app/core/app_dimensions.dart';
import 'package:mobile_app/providers/user_account_provider.dart';
import 'package:mobile_app/widgets/glass_widgets.dart';
import 'package:animate_do/animate_do.dart';

class MyBookingsTab extends StatefulWidget {
  const MyBookingsTab({super.key});

  @override
  State<MyBookingsTab> createState() => _MyBookingsTabState();
}

class _MyBookingsTabState extends State<MyBookingsTab> {
  String? _selectedStatus;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<UserAccountProvider>(context, listen: false).fetchBookings();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<UserAccountProvider>(context);
    final bookings = provider.bookings;
    final isLoading = provider.isLoading;

    return Column(
      children: [
        _buildFilterBar(),
        Expanded(
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : bookings.isEmpty
                  ? _buildEmptyState()
                  : RefreshIndicator(
                      onRefresh: () => provider.fetchBookings(status: _selectedStatus),
                      child: ListView.builder(
                        padding: const EdgeInsets.all(AppDimensions.s16),
                        itemCount: bookings.length,
                        itemBuilder: (context, index) {
                          final booking = bookings[index];
                          return _BookingItem(booking: booking);
                        },
                      ),
                    ),
        ),
      ],
    );
  }

  Widget _buildFilterBar() {
    final filters = [
      {'label': 'All', 'value': null},
      {'label': 'Upcoming', 'value': 'CONFIRMED'},
      {'label': 'Completed', 'value': 'COMPLETED'},
      {'label': 'Cancelled', 'value': 'CANCELLED'},
    ];

    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = _selectedStatus == filter['value'];
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(filter['label'] as String),
              selected: isSelected,
              onSelected: (selected) {
                setState(() => _selectedStatus = filter['value'] as String?);
                Provider.of<UserAccountProvider>(context, listen: false).fetchBookings(status: _selectedStatus);
              },
              selectedColor: AppColors.primary,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : AppColors.textPrimary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.calendar_today_outlined, size: 64, color: AppColors.textTertiary),
          const SizedBox(height: 16),
          const Text("No bookings found", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text("Book your first service today!", style: TextStyle(color: AppColors.textSecondary)),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text("Explore Services", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class _BookingItem extends StatelessWidget {
  final dynamic booking;
  const _BookingItem({required this.booking});

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(booking['status']);
    
    return FadeInUp(
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        child: GlassCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: AppColors.bgLight,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.handyman_outlined, color: AppColors.primary),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(booking['service']['title'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          Text(booking['provider']['fullName'], style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.event, size: 14, color: AppColors.textTertiary),
                              const SizedBox(width: 4),
                              Text(_formatDate(booking['dateTime']), style: const TextStyle(fontSize: 12)),
                              const SizedBox(width: 12),
                              const Icon(Icons.access_time, size: 14, color: AppColors.textTertiary),
                              const SizedBox(width: 4),
                              Text(booking['slot'] ?? "N/A", style: const TextStyle(fontSize: 12)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text("\u20B9${booking['amount']}", style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: statusColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            booking['status'],
                            style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (booking['status'] == 'CONFIRMED' || booking['status'] == 'PENDING') ...[
                      TextButton(
                        onPressed: () => _showCancelDialog(context),
                        child: const Text("Cancel", style: TextStyle(color: AppColors.error)),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                        ),
                        child: const Text("Reschedule", style: TextStyle(fontSize: 12)),
                      ),
                    ] else if (booking['status'] == 'COMPLETED') ...[
                      OutlinedButton(
                        onPressed: () {},
                        child: const Text("Download Invoice", style: TextStyle(fontSize: 12)),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
                        child: const Text("Rebook", style: TextStyle(fontSize: 12)),
                      ),
                    ] else if (booking['status'] == 'PAYMENT_FAILED' || booking['status'] == 'PAYMENT_PENDING') ...[
                       ElevatedButton(
                        onPressed: () {
                           Provider.of<UserAccountProvider>(context, listen: false).retryPayment(booking['id']);
                        },
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, foregroundColor: Colors.white),
                        child: const Text("Retry Payment", style: TextStyle(fontSize: 12)),
                      ),
                    ]
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'CONFIRMED': return Colors.blue;
      case 'COMPLETED': return Colors.green;
      case 'CANCELLED':
      case 'REJECTED': return Colors.red;
      case 'PENDING': return Colors.orange;
      default: return Colors.grey;
    }
  }

  String _formatDate(String dateStr) {
    final date = DateTime.parse(dateStr);
    return "${date.day}/${date.month}/${date.year}";
  }

  void _showCancelDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Cancel Booking?"),
        content: const Text("Are you sure you want to cancel this booking? This action cannot be undone."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("No")),
          TextButton(
            onPressed: () {
              Provider.of<UserAccountProvider>(context, listen: false).cancelBooking(booking['id'], "User cancelled");
              Navigator.pop(context);
            },
            child: const Text("Yes, Cancel", style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}

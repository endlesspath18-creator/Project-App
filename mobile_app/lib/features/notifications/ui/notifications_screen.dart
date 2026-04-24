import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:mobile_app/core/design_system.dart';
import 'package:mobile_app/core/app_dimensions.dart';
import 'package:mobile_app/widgets/glass_widgets.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(child: Container(decoration: const BoxDecoration(gradient: AppGradients.bgGlow))),
          CustomScrollView(
            slivers: [
              _buildAppBar(context),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => FadeInLeft(
                      delay: Duration(milliseconds: 100 * index),
                      child: _NotificationCard(index: index),
                    ),
                    childCount: 5,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary),
      ),
      title: const Text("Notifications", style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
      centerTitle: true,
      actions: [
        TextButton(onPressed: () {}, child: const Text("Clear All", style: TextStyle(color: AppColors.primary))),
      ],
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final int index;
  const _NotificationCard({required this.index});

  @override
  Widget build(BuildContext context) {
    final titles = ["Booking Confirmed", "Payment Received", "New Message", "Service Started", "Review Request"];
    final subtitles = [
      "Your booking for AC repair has been accepted.",
      "Successfully received ₹1,200 for Cleaning Service.",
      "John: Hey, I am on my way to your location.",
      "The technician has started the work.",
      "How was your experience with Urban Company?"
    ];
    final times = ["2 min ago", "1 hour ago", "Yesterday", "2 days ago", "Weekly"];

    return GlassCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.notifications_active_outlined, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(titles[index % titles.length], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    Text(times[index % times.length], style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                  ],
                ),
                const SizedBox(height: 4),
                Text(subtitles[index % subtitles.length], style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

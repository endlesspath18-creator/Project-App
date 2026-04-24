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
      appBar: AppBar(
        title: const Text("Notifications", style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: () {},
            child: const Text("Mark all read", style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 8),
        ],
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          Positioned.fill(child: Container(decoration: const BoxDecoration(gradient: AppGradients.bgGlow))),
          SafeArea(
            child: ListView.builder(
              padding: AppDimensions.screenPadding(context).copyWith(top: AppDimensions.s24),
              itemCount: 3,
              itemBuilder: (context, index) {
                final notifications = [
                  {
                    'title': 'Booking Confirmed',
                    'desc': 'Your Plumber service is scheduled for tomorrow 10 AM.',
                    'time': '2 mins ago',
                    'icon': Icons.check_circle_rounded,
                    'color': Colors.green
                  },
                  {
                    'title': 'New Message',
                    'desc': 'John Doe sent you a message regarding the AC repair.',
                    'time': '1 hour ago',
                    'icon': Icons.message_rounded,
                    'color': AppColors.primary
                  },
                  {
                    'title': 'Payment Success',
                    'desc': 'Payment of ₹999 for Cleaning service was successful.',
                    'time': '5 hours ago',
                    'icon': Icons.payment_rounded,
                    'color': Colors.blue
                  },
                ];
                final n = notifications[index];
                return FadeInUp(
                  delay: Duration(milliseconds: 100 * index),
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: GlassCard(
                      padding: const EdgeInsets.all(AppDimensions.s16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: (n['color'] as Color).withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(n['icon'] as IconData, color: n['color'] as Color, size: 20),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(n['title'] as String, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                                    Text(n['time'] as String, style: const TextStyle(color: AppColors.textTertiary, fontSize: 11)),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(n['desc'] as String, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13, height: 1.4)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

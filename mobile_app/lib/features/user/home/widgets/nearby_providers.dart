import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile_app/core/design_system.dart';
import 'package:mobile_app/core/app_dimensions.dart';
import 'package:mobile_app/providers/user_dashboard_provider.dart';


class NearbyProviders extends StatelessWidget {
  const NearbyProviders({super.key});

  @override
  Widget build(BuildContext context) {
    final dashProvider = Provider.of<UserDashboardProvider>(context);
    final providers = dashProvider.topProviders;

    if (providers.isEmpty) {
      return const SizedBox.shrink();
    }


    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),

        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: providers.length,
          itemBuilder: (context, index) {
            final p = providers[index];
            return GestureDetector(
              onTap: () => Navigator.pushNamed(context, '/search'),
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4)),
                  ],
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 25,
                      backgroundImage: p['profileImage'] != null 
                        ? NetworkImage(p['profileImage']) 
                        : NetworkImage("https://ui-avatars.com/api/?name=${p['fullName']}&background=0D8ABC&color=fff"),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(p['fullName'] ?? 'N/A', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                          Text(p['providerProfile']?['businessName'] ?? 'Service Provider', style: TextStyle(color: AppColors.textTertiary, fontSize: 12)),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.amber.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.star_rounded, color: Colors.amber, size: 16),
                          const SizedBox(width: 4),
                          Text(p['providerProfile']?['rating']?.toString() ?? '0.0', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.orange)),
                        ],
                      ),
                    ),

                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:mobile_app/core/design_system.dart';
import 'package:mobile_app/core/app_dimensions.dart';

class NearbyProviders extends StatelessWidget {
  const NearbyProviders({super.key});

  @override
  Widget build(BuildContext context) {
    // Dummy data for top providers
    final providers = [
      {'name': 'Urban Fix', 'rating': '4.8', 'type': 'All Rounder', 'image': 'https://ui-avatars.com/api/?name=Urban+Fix&background=0D8ABC&color=fff'},
      {'name': 'Mega Clean', 'rating': '4.9', 'type': 'Cleaning', 'image': 'https://ui-avatars.com/api/?name=Mega+Clean&background=4CAF50&color=fff'},
      {'name': 'Sparky Elec', 'rating': '4.7', 'type': 'Electrician', 'image': 'https://ui-avatars.com/api/?name=Sparky+Elec&background=FFC107&color=fff'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: AppDimensions.s20),
          child: Text(
            "Top Rated Providers",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
          ),
        ),
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
                      backgroundImage: NetworkImage(p['image']!),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(p['name']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                          Text(p['type']!, style: const TextStyle(color: AppColors.textTertiary, fontSize: 12)),
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
                          Text(p['rating']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.orange)),
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

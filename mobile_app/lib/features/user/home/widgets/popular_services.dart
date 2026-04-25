import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile_app/core/design_system.dart';
import 'package:mobile_app/core/app_dimensions.dart';
import 'package:mobile_app/core/app_routes.dart';
import 'package:mobile_app/providers/service_provider.dart';
import 'package:mobile_app/data/service_model.dart';

class PopularServices extends StatelessWidget {
  const PopularServices({super.key});

  @override
  Widget build(BuildContext context) {
    final serviceProv = context.watch<ServiceProvider>();
    final services = serviceProv.services;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppDimensions.s24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Popular Services",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  fontFamily: 'Outfit',
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pushNamed(context, AppRoutes.search),
                child: const Text(
                  "See All", 
                  style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontFamily: 'Outfit')
                ),
              ),
            ],
          ),
        ),
        if (serviceProv.isLoading)
          const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator()))
        else if (services.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Text("No services available right now.", style: TextStyle(color: AppColors.textTertiary)),
          )
        else
          SizedBox(
            height: 265,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: services.length > 5 ? 5 : services.length,
              itemBuilder: (context, index) {
                return PopularServiceCard(service: services[index]);
              },
            ),
          ),
      ],
    );
  }
}

class PopularServiceCard extends StatelessWidget {
  final ServiceModel service;
  const PopularServiceCard({super.key, required this.service});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, AppRoutes.providerDetails, arguments: service),
      child: Container(
        width: 230,
        margin: const EdgeInsets.only(right: 14, bottom: 12, top: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [AppShadows.card],
          border: Border.all(color: AppColors.divider, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Section
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      "https://img.freepik.com/free-photo/plumber-fixing-sink_23-2147772358.jpg", // Placeholder
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: AppColors.primaryContainer,
                        child: const Icon(Icons.broken_image_rounded, color: AppColors.primary),
                      ),
                    ),
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Consumer<ServiceProvider>(
                        builder: (context, prov, _) {
                          final isFav = prov.isFavorite(service.id);
                          return GestureDetector(
                            onTap: () => prov.toggleFavorite(service.id),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.9),
                                shape: BoxShape.circle,
                                boxShadow: const [AppShadows.soft],
                              ),
                              child: Icon(
                                isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                                color: isFav ? Colors.red : AppColors.textTertiary,
                                size: 18,
                              ),
                            ),
                          );
                        }
                      ),
                    ),
                    Positioned(
                      top: 12,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.95),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: const [AppShadows.soft],
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.star_rounded, color: Color(0xFFFBBF24), size: 14),
                            Text(
                              " ${service.rating}",
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: AppColors.textPrimary),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    service.title,
                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: AppColors.textPrimary, fontFamily: 'Outfit'),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    service.providerName,
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 12, fontFamily: 'Outfit'),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Starting from", style: TextStyle(color: AppColors.textTertiary, fontSize: 10)),
                          Text(
                            "₹${service.price.toInt()}",
                            style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w900, fontSize: 18, fontFamily: 'Outfit'),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.15),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Text(
                          "Book",
                          style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold, fontFamily: 'Outfit'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:mobile_app/core/design_system.dart';
import 'package:mobile_app/core/app_dimensions.dart';
import 'package:mobile_app/widgets/glass_widgets.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  final List<Map<String, dynamic>> categories = const [
    {'name': 'AC Repair', 'icon': Icons.ac_unit_rounded, 'color': Color(0xFF0EA5E9)},
    {'name': 'Plumbing', 'icon': Icons.plumbing_rounded, 'color': Color(0xFF3B82F6)},
    {'name': 'Electrical', 'icon': Icons.electrical_services_rounded, 'color': Color(0xFFF59E0B)},
    {'name': 'Cleaning', 'icon': Icons.cleaning_services_rounded, 'color': Color(0xFF10B981)},
    {'name': 'Painting', 'icon': Icons.format_paint_rounded, 'color': Color(0xFF6366F1)},
    {'name': 'Carpentry', 'icon': Icons.handyman_rounded, 'color': Color(0xFF8B5CF6)},
    {'name': 'Appliance', 'icon': Icons.kitchen_rounded, 'color': Color(0xFFEC4899)},
    {'name': 'Gardening', 'icon': Icons.grass_rounded, 'color': Color(0xFF22C55E)},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("All Categories", style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(child: Container(decoration: const BoxDecoration(gradient: AppGradients.bgGlow))),
          SafeArea(
            child: GridView.builder(
              padding: AppDimensions.screenPadding(context).copyWith(top: AppDimensions.s24, bottom: AppDimensions.s40),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: AppResponsive.isDesktop(context) ? 4 : (AppResponsive.isTablet(context) ? 3 : 2),
                mainAxisSpacing: AppDimensions.s20,
                crossAxisSpacing: AppDimensions.s20,
                childAspectRatio: 0.9,
              ),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final cat = categories[index];
                return FadeInUp(
                  delay: Duration(milliseconds: 50 * index),
                  child: GestureDetector(
                    onTap: () {},
                    child: GlassCard(
                      padding: const EdgeInsets.all(AppDimensions.s16),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(AppDimensions.s16),
                            decoration: BoxDecoration(
                              color: (cat['color'] as Color).withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(cat['icon'], color: cat['color'], size: 32),
                          ),
                          const SizedBox(height: AppDimensions.s16),
                          Text(
                            cat['name'],
                            style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 16),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            "24 Services",
                            style: TextStyle(color: AppColors.textTertiary, fontSize: 12),
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

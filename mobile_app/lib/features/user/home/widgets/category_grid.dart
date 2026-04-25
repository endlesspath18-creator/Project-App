import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile_app/core/design_system.dart';
import 'package:mobile_app/core/app_dimensions.dart';
import 'package:mobile_app/core/app_routes.dart';
import 'package:mobile_app/providers/service_provider.dart';

class CategoryGrid extends StatelessWidget {
  final Function(String)? onCategoryTap;
  const CategoryGrid({super.key, this.onCategoryTap});

  @override
  Widget build(BuildContext context) {
    // Professional, curated palette matching the Teal brand
    final List<Map<String, dynamic>> categories = [
      {'name': 'Electrician', 'icon': Icons.electrical_services_rounded, 'color': const Color(0xFF045F56)},
      {'name': 'Plumbing', 'icon': Icons.plumbing_rounded, 'color': const Color(0xFF0EA5E9)},
      {'name': 'AC Repair', 'icon': Icons.ac_unit_rounded, 'color': const Color(0xFF0D9488)},
      {'name': 'Cleaning', 'icon': Icons.cleaning_services_rounded, 'color': const Color(0xFF059669)},
      {'name': 'Beauty', 'icon': Icons.face_retouching_natural_rounded, 'color': const Color(0xFFDB2777)},
      {'name': 'Tutor', 'icon': Icons.school_rounded, 'color': const Color(0xFFD97706)},
      {'name': 'Carpenter', 'icon': Icons.handyman_rounded, 'color': const Color(0xFF4B5563)},
      {'name': 'Delivery', 'icon': Icons.delivery_dining_rounded, 'color': const Color(0xFFDC2626)},
      {'name': 'More', 'icon': Icons.grid_view_rounded, 'color': AppColors.primary},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppDimensions.s24),
          child: const Text(
            "Quick Categories",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              fontFamily: 'Outfit',
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 110,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final cat = categories[index];
              return _buildCategoryItem(context, cat);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryItem(BuildContext context, Map<String, dynamic> cat) {
    return GestureDetector(
      onTap: () {
        if (onCategoryTap != null) {
          onCategoryTap!(cat['name'] as String);
          return;
        }
        if (cat['name'] == 'More') {
          Navigator.pushNamed(context, AppRoutes.categories);
        } else {
          context.read<ServiceProvider>().fetchAllServices(category: cat['name']);
          Navigator.pushNamed(context, AppRoutes.search, arguments: cat['name']);
        }
      },
      child: Container(
        width: 85,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        child: Column(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: (cat['color'] as Color).withValues(alpha: 0.1),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
                border: Border.all(
                  color: AppColors.border.withValues(alpha: 0.5),
                  width: 1,
                ),
              ),
              child: Icon(cat['icon'] as IconData, color: (cat['color'] as Color), size: 26),
            ),
            const SizedBox(height: 10),
            Text(
              cat['name'] as String,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
                fontFamily: 'Outfit',
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

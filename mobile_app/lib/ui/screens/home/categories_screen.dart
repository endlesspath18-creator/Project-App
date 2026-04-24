import 'package:flutter/material.dart';
import '../../../core/design_system.dart';
import '../../../widgets/glass_widgets.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final categories = [
      {'icon': Icons.ac_unit, 'label': 'AC Repair'},
      {'icon': Icons.plumbing, 'label': 'Plumbing'},
      {'icon': Icons.electrical_services, 'label': 'Electrical'},
      {'icon': Icons.cleaning_services, 'label': 'Cleaning'},
      {'icon': Icons.home_repair_service, 'label': 'Appliance'},
      {'icon': Icons.local_car_wash, 'label': 'Car Wash'},
      {'icon': Icons.pest_control, 'label': 'Pest Control'},
      {'icon': Icons.format_paint, 'label': 'Painting'},
    ];

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(child: Container(decoration: const BoxDecoration(gradient: GlacierGradients.bgGlow))),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                      ),
                      const Text("Categories", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                    ],
                  ),
                ),
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 20,
                      mainAxisSpacing: 20,
                      childAspectRatio: 1.1,
                    ),
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      return GlassCard(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(categories[index]['icon'] as IconData, color: GlacierColors.primary, size: 40),
                            const SizedBox(height: 12),
                            Text(categories[index]['label'] as String, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

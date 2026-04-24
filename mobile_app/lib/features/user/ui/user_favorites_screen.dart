import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:mobile_app/core/design_system.dart';
import 'package:mobile_app/core/app_dimensions.dart';
import 'package:mobile_app/widgets/glass_widgets.dart';

class UserFavoritesScreen extends StatelessWidget {
  const UserFavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Favorites", style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          Positioned.fill(child: Container(decoration: const BoxDecoration(gradient: AppGradients.bgGlow))),
          SafeArea(
            child: ListView.builder(
              padding: AppDimensions.screenPadding(context).copyWith(top: AppDimensions.s24),
              itemCount: 0, // Empty for now
              itemBuilder: (context, index) => const SizedBox(),
            ),
          ),
          // Empty State
          Center(
            child: FadeInUp(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.favorite_border_rounded, size: 100, color: AppColors.primary.withValues(alpha: 0.1)),
                  const SizedBox(height: 24),
                  const Text("No Favorites Yet", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                  const SizedBox(height: 12),
                  const Text(
                    "Service providers you love will appear here.",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: 200,
                    child: GlassButton(
                      onPressed: () => Navigator.pop(context),
                      text: "Explore Services",
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

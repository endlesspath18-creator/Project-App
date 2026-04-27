import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:mobile_app/core/design_system.dart';
import 'package:mobile_app/widgets/glass_widgets.dart';

class PremiumStatusScreen extends StatelessWidget {
  const PremiumStatusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(child: Container(decoration: const BoxDecoration(gradient: AppGradients.bgGlow))),
          SafeArea(
            child: Column(
              children: [
                _buildHeader(context),
                Expanded(child: _buildContent()),
                _buildFooter(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary),
          ),
          const Spacer(),
          const Text("Premium Account", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          const Spacer(),
          const SizedBox(width: 48), // Balancing
        ],
      ),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        children: [
          const SizedBox(height: 40),
          FadeInDown(
            child: Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.1),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.blue.withValues(alpha: 0.2), width: 2),
              ),
              child: const Icon(Icons.verified_rounded, size: 80, color: Colors.blue),
            ),
          ),
          const SizedBox(height: 32),
          FadeInUp(
            child: const Text(
              "Premium Already Activated",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, letterSpacing: -0.5),
            ),
          ),
          const SizedBox(height: 16),
          FadeInUp(
            delay: const Duration(milliseconds: 100),
            child: const Text(
              "Congratulations! You have full access to all professional tools and unlimited service publishing.",
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 15, height: 1.5),
            ),
          ),
          const SizedBox(height: 48),
          _buildFeatureItem(Icons.all_inclusive_rounded, "Unlimited Service Publishing", "List as many services as you want without restrictions."),
          _buildFeatureItem(Icons.auto_graph_rounded, "Priority Search Results", "Your profile appears higher in user searches."),
          _buildFeatureItem(Icons.badge_rounded, "Verified Badge", "Build trust with a verified professional badge."),
          _buildFeatureItem(Icons.analytics_outlined, "Advanced Analytics", "Deep insights into your business performance."),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String title, String subtitle) {
    return FadeInLeft(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 24),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: Colors.blue.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: Colors.blue, size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13, height: 1.3)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: GlassButton(
        onPressed: () => Navigator.pop(context),
        text: "Back to Dashboard",
      ),
    );
  }
}

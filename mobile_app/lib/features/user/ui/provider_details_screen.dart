import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:mobile_app/core/design_system.dart';
import 'package:mobile_app/core/app_dimensions.dart';
import 'package:mobile_app/widgets/glass_widgets.dart';
import 'package:mobile_app/data/service_model.dart';
import 'package:mobile_app/core/app_routes.dart';

class ProviderDetailsScreen extends StatelessWidget {
  const ProviderDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // In a real app, you'd get this from arguments
    final ServiceModel service = ModalRoute.of(context)!.settings.arguments as ServiceModel;

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(child: Container(decoration: const BoxDecoration(gradient: AppGradients.bgGlow))),
          
          CustomScrollView(
            slivers: [
              // ─── App Bar / Hero Image ──────────────────────────────────────────
              SliverAppBar(
                expandedHeight: 300,
                backgroundColor: Colors.transparent,
                elevation: 0,
                pinned: true,
                leading: IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: AppColors.surface.withValues(alpha: 0.8), shape: BoxShape.circle),
                    child: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary, size: 18),
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      Container(
                        color: AppColors.primary.withValues(alpha: 0.12),
                        child: const Icon(Icons.home_repair_service_rounded, color: AppColors.primary, size: 120),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.transparent, AppColors.background.withValues(alpha: 0.8), AppColors.background],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ─── Content ──────────────────────────────────────────
              SliverPadding(
                padding: AppDimensions.screenPadding(context).copyWith(bottom: 120),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    FadeInUp(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                                ),
                                child: Text(service.category, style: const TextStyle(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.bold)),
                              ),
                              const Spacer(),
                              const Icon(Icons.star_rounded, color: Colors.amber, size: 20),
                              const Text(" 4.8 (48 Reviews)", style: TextStyle(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const SizedBox(height: AppDimensions.s16),
                          Text(
                            service.title,
                            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                          ),
                          const SizedBox(height: AppDimensions.s8),
                          Text(
                            "by ${service.providerName}",
                            style: TextStyle(color: AppColors.primary.withValues(alpha: 0.8), fontSize: 16, fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: AppDimensions.s32),
                          
                          const Text("Service Perks", style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: AppDimensions.s16),
                          _buildPerksRow(),
                          
                          const SizedBox(height: AppDimensions.s32),
                          const Text("About this Service", style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: AppDimensions.s12),
                          Text(
                            service.description,
                            style: const TextStyle(color: AppColors.textSecondary, fontSize: 15, height: 1.6),
                          ),
                          
                          const SizedBox(height: AppDimensions.s32),
                          const Text("Provider Portfolio", style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: AppDimensions.s16),
                          _buildPortfolioGrid(),
                        ],
                      ),
                    ),
                  ]),
                ),
              ),
            ],
          ),

          // ─── Floating Action Button / Bottom CTA ──────────────────────────────────────────
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(AppDimensions.s24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [AppColors.background.withValues(alpha: 0), AppColors.background],
                ),
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 500),
                child: GlassCard(
                  padding: const EdgeInsets.all(AppDimensions.s16),
                  borderRadius: AppDimensions.r24,
                  child: Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text("Price starts from", style: TextStyle(color: AppColors.textTertiary, fontSize: 11)),
                          Text("₹${service.price.toInt()}", style: const TextStyle(color: AppColors.textPrimary, fontSize: 24, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(width: AppDimensions.s24),
                      Expanded(
                        child: GlassButton(
                          onPressed: () => Navigator.pushNamed(context, AppRoutes.booking, arguments: service),
                          text: "Book Now",
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPerksRow() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          const _PerkChip(Icons.timer_outlined, "60 Mins"),
          const _PerkChip(Icons.verified_outlined, "Expert"),
          const _PerkChip(Icons.shield_outlined, "Warranty"),
          const _PerkChip(Icons.support_agent_rounded, "24/7"),
        ],
      ),
    );
  }

  Widget _buildPortfolioGrid() {
    return GridView.builder(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
      ),
      itemCount: 6,
      itemBuilder: (context, index) => Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
          boxShadow: const [AppShadows.soft],
        ),
        child: Icon(Icons.image_outlined, color: AppColors.primary.withValues(alpha: 0.1)),
      ),
    );
  }
}

class _PerkChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _PerkChip(this.icon, this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: const [AppShadows.soft],
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 16),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

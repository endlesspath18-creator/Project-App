import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import 'package:mobile_app/providers/service_provider.dart';
import 'package:mobile_app/providers/auth_provider.dart';
import 'package:mobile_app/core/design_system.dart';
import 'package:mobile_app/core/app_dimensions.dart';
import 'package:mobile_app/core/app_routes.dart';
import 'package:mobile_app/widgets/glass_widgets.dart';

class ProviderServicesScreen extends StatefulWidget {
  const ProviderServicesScreen({super.key});

  @override
  State<ProviderServicesScreen> createState() => _ProviderServicesScreenState();
}

class _ProviderServicesScreenState extends State<ProviderServicesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ServiceProvider>().fetchProviderServices();
    });
  }

  @override
  Widget build(BuildContext context) {
    final serviceProvider = Provider.of<ServiceProvider>(context);

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(child: Container(decoration: const BoxDecoration(gradient: AppGradients.bgGlow))),
          CustomScrollView(
            slivers: [
              _buildAppBar(context),
              SliverPadding(
                padding: const EdgeInsets.all(AppDimensions.s24),
                sliver: serviceProvider.isLoading 
                  ? const SliverFillRemaining(child: Center(child: CircularProgressIndicator()))
                  : serviceProvider.providerServices.isEmpty
                    ? const SliverFillRemaining(child: Center(child: Text("No services listed yet", style: TextStyle(color: AppColors.textSecondary))))
                    : SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final service = serviceProvider.providerServices[index];
                            return FadeInUp(
                              delay: Duration(milliseconds: 50 * index),
                              child: _ServiceCard(service: service),
                            );
                          },
                          childCount: serviceProvider.providerServices.length,
                        ),
                      ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
        ],
      ),
      floatingActionButton: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          final isPaid = auth.user?.hasPaidPublishingFee == true;
          return FloatingActionButton.extended(
            onPressed: () async {
              // Instant access if state is already verified
              if (isPaid) {
                Navigator.pushNamed(context, AppRoutes.addService);
                return;
              }

              // Silent verification before showing activation screen
              try {
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
                );
                await auth.refreshUser();
                if (context.mounted) Navigator.pop(context); // Close loader

                if (auth.user?.hasPaidPublishingFee == true) {
                  if (context.mounted) Navigator.pushNamed(context, AppRoutes.addService);
                } else {
                  if (context.mounted) Navigator.pushNamed(context, AppRoutes.providerActivation);
                }
              } catch (e) {
                if (context.mounted) Navigator.pop(context);
                if (context.mounted) Navigator.pushNamed(context, AppRoutes.providerActivation);
              }
            },
            backgroundColor: isPaid ? AppColors.primary : Colors.amber,
            icon: Icon(isPaid ? Icons.add_rounded : Icons.bolt_rounded, color: Colors.white),
            label: Text(
              isPaid ? "New Service" : "Activate Premium",
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary),
      ),
      title: const Text("My Services", style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
      centerTitle: true,
    );
  }
}

class _ServiceCard extends StatelessWidget {
  final dynamic service;
  const _ServiceCard({required this.service});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 60, height: 60,
            decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.home_repair_service_rounded, color: AppColors.primary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(service.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text(service.category, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                const SizedBox(height: 4),
                Text("₹${service.price}", style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textTertiary),
        ],
      ),
    );
  }
}

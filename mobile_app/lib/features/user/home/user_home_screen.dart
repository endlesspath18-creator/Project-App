import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import 'package:mobile_app/core/design_system.dart';
import 'package:mobile_app/core/app_dimensions.dart';
import 'package:mobile_app/core/app_routes.dart';
import 'package:mobile_app/providers/auth_provider.dart';
import 'package:mobile_app/providers/service_provider.dart';
import 'package:mobile_app/providers/user_dashboard_provider.dart';
import 'package:mobile_app/widgets/glass_widgets.dart';

import 'widgets/promo_banner.dart';
import 'widgets/category_grid.dart';
import 'widgets/popular_services.dart';
import 'widgets/home_header.dart';
import 'widgets/search_bar.dart';
import 'widgets/nearby_providers.dart';
import 'widgets/recent_bookings.dart';

class UserHomeScreen extends StatefulWidget {
  const UserHomeScreen({super.key});

  @override
  State<UserHomeScreen> createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends State<UserHomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    await Future.wait([
      context.read<ServiceProvider>().fetchAllServices(force: true),
      context.read<UserDashboardProvider>().fetchDashboard(force: true),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final dashProvider = Provider.of<UserDashboardProvider>(context);
    final stats = dashProvider.stats;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          Positioned.fill(child: Container(decoration: const BoxDecoration(gradient: AppGradients.bgGlow))),
          SafeArea(
            child: RefreshIndicator(
              onRefresh: _loadData,
              color: AppColors.primary,
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  const SliverToBoxAdapter(child: HomeHeader()),
                  
                  // Technical Activity Tracker (Premium SaaS Card)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                      child: FadeInDown(
                        child: GlassCard(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text("ACTIVE BOOKINGS", style: TextStyle(color: AppColors.textSecondary, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                                      const SizedBox(height: 4),
                                      Text("${stats?.activeBookings.length ?? 0} In Progress", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), shape: BoxShape.circle),
                                    child: const Icon(Icons.speed_rounded, color: AppColors.primary, size: 20),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  _buildMiniStat("Total Spent", "₹${stats?.totalSpent.toInt() ?? 0}"),
                                  const SizedBox(width: 24),
                                  _buildMiniStat("Completed", "${stats?.completedCount ?? 0}"),
                                  const SizedBox(width: 24),
                                  _buildMiniStat("Savings", "₹450"),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      child: HomeSearchBar(),
                    ),
                  ),
                  
                  SliverToBoxAdapter(
                    child: FadeIn(child: const PromoBanner()),
                  ),
                  
                  const SliverToBoxAdapter(child: SizedBox(height: 16)),
                  
                  SliverToBoxAdapter(
                    child: CategoryGrid(
                      onCategoryTap: (cat) {
                        if (cat == 'More') {
                          Navigator.pushNamed(context, AppRoutes.categories);
                        } else {
                          Navigator.pushNamed(context, AppRoutes.search, arguments: cat);
                        }
                      },
                    ),
                  ),
                  
                  const SliverToBoxAdapter(child: AppSectionLabel(label: "Your Recent Activity")),
                  const SliverToBoxAdapter(child: RecentBookings()),
                  
                  const SliverToBoxAdapter(child: AppSectionLabel(label: "Popular Services")),
                  const SliverToBoxAdapter(child: PopularServices()),
                  
                  const SliverToBoxAdapter(child: AppSectionLabel(label: "Top Rated Pros")),
                  const SliverToBoxAdapter(child: NearbyProviders()),

                  
                  const SliverToBoxAdapter(child: SizedBox(height: 100)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        Text(label, style: const TextStyle(color: AppColors.textTertiary, fontSize: 10)),
      ],
    );
  }
}

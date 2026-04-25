import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import 'package:mobile_app/core/design_system.dart';
import 'package:mobile_app/core/app_dimensions.dart';
import 'package:mobile_app/core/app_routes.dart';
import 'package:mobile_app/providers/auth_provider.dart';
import 'package:mobile_app/providers/service_provider.dart';
import 'package:mobile_app/providers/booking_provider.dart';

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
    final serviceProv = context.read<ServiceProvider>();
    final bookingProv = context.read<BookingProvider>();
    
    await Future.wait([
      serviceProv.fetchAllServices(force: true),
      bookingProv.fetchUserBookings(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Background Glow
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: AppGradients.bgGlow,
              ),
            ),
          ),
          
          SafeArea(
            child: RefreshIndicator(
              onRefresh: _loadData,
              color: AppColors.primary,
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  // Top Header Section
                  const SliverToBoxAdapter(
                    child: HomeHeader(),
                  ),
                  
                  // Search Section
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.s24),
                      child: HomeSearchBar(),
                    ),
                  ),
                  
                  const SliverToBoxAdapter(child: SizedBox(height: AppDimensions.s24)),
                  
                  // Promo Banner
                  SliverToBoxAdapter(
                    child: FadeIn(
                      duration: const Duration(milliseconds: 800),
                      child: const PromoBanner(),
                    ),
                  ),
                  
                  const SliverToBoxAdapter(child: SizedBox(height: AppDimensions.s24)),
                  
                  // Categories Grid
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
                  
                  const SliverToBoxAdapter(child: SizedBox(height: AppDimensions.s24)),
                  
                  // Recent Bookings (Horizontal scroll)
                  const SliverToBoxAdapter(
                    child: RecentBookings(),
                  ),
                  
                  const SliverToBoxAdapter(child: SizedBox(height: AppDimensions.s24)),
                  
                  // Popular Services (Horizontal scroll)
                  const SliverToBoxAdapter(
                    child: PopularServices(),
                  ),
                  
                  const SliverToBoxAdapter(child: SizedBox(height: AppDimensions.s24)),
                  
                  // Nearby Providers (Vertical list)
                  const SliverToBoxAdapter(
                    child: NearbyProviders(),
                  ),
                  
                  // Bottom spacing
                  const SliverToBoxAdapter(child: SizedBox(height: 100)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

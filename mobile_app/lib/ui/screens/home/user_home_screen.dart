import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/service_provider.dart';
import '../../../providers/booking_provider.dart';
import '../../../core/app_routes.dart';
import '../../../core/design_system.dart';
import '../../../widgets/glass_widgets.dart';
import '../../../data/service_model.dart';

class UserHomeScreen extends StatefulWidget {
  const UserHomeScreen({super.key});

  @override
  State<UserHomeScreen> createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends State<UserHomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'All';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ServiceProvider>().fetchAllServices();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _handleRefresh() async {
    await context.read<ServiceProvider>().fetchAllServices();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final serviceProvider = Provider.of<ServiceProvider>(context);
    final user = authProvider.user;

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(child: Container(decoration: const BoxDecoration(gradient: GlacierGradients.bgGlow))),
          SafeArea(
            child: RefreshIndicator(
              onRefresh: _handleRefresh,
              color: GlacierColors.primary,
              backgroundColor: GlacierColors.surface,
              child: CustomScrollView(
                slivers: [
                  // ─── Header ──────────────────────────────────────────
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Evening, ${user?.fullName.split(' ')[0] ?? 'Guest'}",
                                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.location_on, size: 14, color: GlacierColors.primary),
                                  const SizedBox(width: 4),
                                  Text("New York, USA", style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 13)),
                                ],
                              ),
                            ],
                          ),
                          IconButton(
                            onPressed: () => authProvider.logout().then((_) => Navigator.pushReplacementNamed(context, AppRoutes.welcome)),
                            icon: const Icon(Icons.logout_rounded, color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // ─── Search ──────────────────────────────────────────
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: FadeInDown(
                        child: GlassInput(
                          controller: _searchController,
                          hintText: "Search services...",
                          prefixIcon: Icons.search,
                        ),
                      ),
                    ),
                  ),

                  // ─── Categories ──────────────────────────────────────────
                  const SliverToBoxAdapter(child: SizedBox(height: 32)),
                  SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 24.0),
                          child: Text("Categories", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 100,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            children: [
                              _CategoryItem(Icons.grid_view_rounded, 'All', _selectedCategory == 'All', () => setState(() => _selectedCategory = 'All')),
                              _CategoryItem(Icons.ac_unit_rounded, 'AC Repair', _selectedCategory == 'AC Repair', () => setState(() => _selectedCategory = 'AC Repair')),
                              _CategoryItem(Icons.plumbing_rounded, 'Plumbing', _selectedCategory == 'Plumbing', () => setState(() => _selectedCategory = 'Plumbing')),
                              _CategoryItem(Icons.electrical_services_rounded, 'Electrical', _selectedCategory == 'Electrical', () => setState(() => _selectedCategory = 'Electrical')),
                              _CategoryItem(Icons.cleaning_services_rounded, 'Cleaning', _selectedCategory == 'Cleaning', () => setState(() => _selectedCategory = 'Cleaning')),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ─── Services ──────────────────────────────────────────
                  const SliverToBoxAdapter(child: SizedBox(height: 16)),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Recommended", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                          TextButton(onPressed: () {}, child: const Text("View All", style: TextStyle(color: GlacierColors.primary))),
                        ],
                      ),
                    ),
                  ),

                  if (serviceProvider.isLoading)
                    const SliverFillRemaining(child: Center(child: CircularProgressIndicator(color: GlacierColors.primary)))
                  else
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final service = serviceProvider.services[index];
                            if (_selectedCategory != 'All' && service.category != _selectedCategory) {
                              return const SizedBox.shrink();
                            }
                            return FadeInUp(
                              delay: Duration(milliseconds: 100 * index),
                              child: _ServiceCard(service: service),
                            );
                          },
                          childCount: serviceProvider.services.length,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        height: 90,
        decoration: BoxDecoration(
          color: GlacierColors.background,
          border: Border(top: BorderSide(color: Colors.white.withOpacity(0.05))),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(Icons.home_filled, "Home", true),
            _buildNavItem(Icons.calendar_today_rounded, "Bookings", false),
            _buildNavItem(Icons.notifications_outlined, "Alerts", false),
            _buildNavItem(Icons.person_outline, "Account", false),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool isActive) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: isActive ? GlacierColors.primary : Colors.white24, size: 26),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(color: isActive ? GlacierColors.primary : Colors.white24, fontSize: 11)),
      ],
    );
  }
}

class _CategoryItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryItem(this.icon, this.label, this.isSelected, this.onTap);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 16),
        child: Column(
          children: [
            GlassCard(
              width: 64,
              height: 64,
              borderRadius: 16,
              color: isSelected ? GlacierColors.primary.withOpacity(0.2) : null,
              border: isSelected ? Border.all(color: GlacierColors.primary, width: 1.5) : null,
              child: Center(child: Icon(icon, color: isSelected ? GlacierColors.primary : Colors.white60)),
            ),
            const SizedBox(height: 8),
            Text(label, style: TextStyle(color: isSelected ? GlacierColors.primary : Colors.white38, fontSize: 11, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
          ],
        ),
      ),
    );
  }
}

class _ServiceCard extends StatelessWidget {
  final ServiceModel service;
  const _ServiceCard({required this.service});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: GlassCard(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: GlacierColors.primary.withOpacity(0.1),
              ),
              child: const Icon(Icons.home_repair_service, color: GlacierColors.primary, size: 40),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(service.title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text("by ${service.providerName}", style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 13)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 16),
                      Text(" ${service.rating}", style: const TextStyle(color: Colors.amber, fontSize: 13, fontWeight: FontWeight.bold)),
                      const Spacer(),
                      Text("₹${service.price.toInt()}", style: const TextStyle(color: GlacierColors.primary, fontSize: 18, fontWeight: FontWeight.bold)),
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

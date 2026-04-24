import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import 'package:mobile_app/providers/auth_provider.dart';
import 'package:mobile_app/providers/service_provider.dart';
import 'package:mobile_app/core/app_routes.dart';
import 'package:mobile_app/core/design_system.dart';
import 'package:mobile_app/core/app_dimensions.dart';
import 'package:mobile_app/widgets/glass_widgets.dart';
import 'package:mobile_app/data/service_model.dart';

class UserMainScreen extends StatefulWidget {
  const UserMainScreen({super.key});

  @override
  State<UserMainScreen> createState() => _UserMainScreenState();
}

class _UserMainScreenState extends State<UserMainScreen> {
  int _currentIndex = 0;
  final PageController _pageController = PageController();

  final List<Widget> _pages = [
    const _HomeTab(),
    const PlaceholderScreen(title: "My Bookings"),
    const PlaceholderScreen(title: "Notifications"),
    const _AccountTab(),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onTabTapped(int index) {
    setState(() => _currentIndex = index);
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) => setState(() => _currentIndex = index),
        children: _pages,
      ),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    if (AppResponsive.isDesktop(context)) return const SizedBox.shrink();
    
    return Container(
      height: 70 + MediaQuery.of(context).padding.bottom,
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: const Border(top: BorderSide(color: AppColors.border, width: 0.5)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -5))
        ],
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(Icons.home_filled, "Home", 0),
            _buildNavItem(Icons.calendar_today_rounded, "Bookings", 1),
            _buildNavItem(Icons.notifications_none_rounded, "Alerts", 2),
            _buildNavItem(Icons.person_outline_rounded, "Account", 3),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isActive = _currentIndex == index;
    return InkWell(
      onTap: () => _onTabTapped(index),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon, 
              color: isActive ? AppColors.primary : AppColors.textTertiary, 
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label, 
              style: TextStyle(
                color: isActive ? AppColors.primary : AppColors.textTertiary, 
                fontSize: 10, 
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── HOME TAB ───────────────────────────────────────────────────────────────

class _HomeTab extends StatefulWidget {
  const _HomeTab();

  @override
  State<_HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<_HomeTab> {
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

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final serviceProvider = Provider.of<ServiceProvider>(context);
    final user = authProvider.user;

    return Stack(
      children: [
        Positioned.fill(child: Container(decoration: const BoxDecoration(gradient: AppGradients.bgGlow))),
        SafeArea(
          child: RefreshIndicator(
            onRefresh: () async => await context.read<ServiceProvider>().fetchAllServices(),
            color: AppColors.primary,
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: AppDimensions.screenPadding(context).copyWith(top: AppDimensions.s24, bottom: AppDimensions.s16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Hello, ${user?.fullName.split(' ')[0] ?? 'Guest'}",
                                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                              ),
                              const SizedBox(height: 4),
                              const Row(
                                children: [
                                  Icon(Icons.location_on, size: 14, color: AppColors.primary),
                                  SizedBox(width: 4),
                                  Text("New York, USA", style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                                ],
                              ),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.pushNamed(context, AppRoutes.userProfile),
                          child: Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                            ),
                            child: const Icon(Icons.person, color: AppColors.primary),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                SliverToBoxAdapter(
                  child: Padding(
                    padding: AppDimensions.screenPadding(context),
                    child: FadeInDown(
                      child: GlassInput(
                        controller: _searchController,
                        hintText: "Search services...",
                        prefixIcon: Icons.search,
                      ),
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: AppDimensions.s24)),
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const AppSectionLabel(label: "Categories"),
                      SizedBox(
                        height: 105,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: AppDimensions.s24),
                          children: [
                            _CategoryItem(Icons.grid_view_rounded, 'All', _selectedCategory == 'All', () => setState(() => _selectedCategory = 'All')),
                            _CategoryItem(Icons.ac_unit_rounded, 'AC', _selectedCategory == 'AC', () => setState(() => _selectedCategory = 'AC')),
                            _CategoryItem(Icons.plumbing_rounded, 'Pipe', _selectedCategory == 'Pipe', () => setState(() => _selectedCategory = 'Pipe')),
                            _CategoryItem(Icons.electrical_services_rounded, 'Electric', _selectedCategory == 'Electric', () => setState(() => _selectedCategory = 'Electric')),
                            _CategoryItem(Icons.cleaning_services_rounded, 'Clean', _selectedCategory == 'Clean', () => setState(() => _selectedCategory = 'Clean')),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                SliverToBoxAdapter(
                  child: AppSectionLabel(
                    label: "Recommended",
                    onAction: () => Navigator.pushNamed(context, AppRoutes.categories),
                  ),
                ),

                if (serviceProvider.isLoading)
                  SliverPadding(
                    padding: AppDimensions.screenPadding(context),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => const Padding(
                          padding: EdgeInsets.only(bottom: AppDimensions.s20),
                          child: LoadingSkeleton(height: 120, borderRadius: AppDimensions.r12),
                        ),
                        childCount: 3,
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: AppDimensions.screenPadding(context).copyWith(bottom: 100),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final service = serviceProvider.services[index];
                          return FadeInUp(
                            delay: Duration(milliseconds: 50 * index),
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: _ServiceCard(service: service),
                            ),
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
    );
  }
}

// ─── ACCOUNT TAB ────────────────────────────────────────────────────────────

class _AccountTab extends StatelessWidget {
  const _AccountTab();

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                gradient: AppGradients.bgGlow,
                borderRadius: BorderRadius.only(bottomLeft: Radius.circular(32), bottomRight: Radius.circular(32)),
              ),
              child: SafeArea(
                child: Column(
                  children: [
                    const CircleAvatar(
                      radius: 50,
                      backgroundColor: AppColors.primary,
                      child: Icon(Icons.person, size: 50, color: Colors.white),
                    ),
                    const SizedBox(height: 16),
                    Text(user?.fullName ?? "Guest User", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                    Text(user?.email ?? "", style: const TextStyle(color: AppColors.textSecondary)),
                    const SizedBox(height: 16),
                    GlassButton(
                      onPressed: () {},
                      text: "Edit Profile",
                      width: 150,
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  _AccountItem(Icons.favorite_border_rounded, "Favorites", () => Navigator.pushNamed(context, AppRoutes.userFavorites)),
                  _AccountItem(Icons.history_rounded, "Booking History", () => Navigator.pushNamed(context, AppRoutes.userBookings)),
                  _AccountItem(Icons.settings_outlined, "Settings", () => Navigator.pushNamed(context, AppRoutes.userSettings)),
                  _AccountItem(Icons.help_outline_rounded, "Help & Support", () => Navigator.pushNamed(context, AppRoutes.userHelp)),
                  _AccountItem(Icons.info_outline_rounded, "About Us", () {}),
                  const Divider(height: 48),
                  _AccountItem(Icons.logout_rounded, "Logout", () {
                    authProvider.logout().then((_) => Navigator.pushReplacementNamed(context, AppRoutes.welcome));
                  }, isDestructive: true),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AccountItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool isDestructive;

  const _AccountItem(this.icon, this.title, this.onTap, {this.isDestructive = false});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: isDestructive ? AppColors.error : AppColors.primary),
      title: Text(title, style: TextStyle(fontWeight: FontWeight.w500, color: isDestructive ? AppColors.error : AppColors.textPrimary)),
      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
      contentPadding: EdgeInsets.zero,
    );
  }
}

// ─── UTILS ──────────────────────────────────────────────────────────────────

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
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: isSelected ? [
                  BoxShadow(color: AppColors.primary.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 4))
                ] : [AppShadows.soft],
              ),
              child: Icon(icon, color: isSelected ? Colors.white : AppColors.textSecondary, size: 24),
            ),
            const SizedBox(height: 8),
            Text(label, style: TextStyle(color: isSelected ? AppColors.primary : AppColors.textSecondary, fontSize: 11, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
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
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, AppRoutes.providerDetails, arguments: service),
      child: GlassCard(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: AppColors.primary.withValues(alpha: 0.05),
              ),
              child: const Icon(Icons.home_repair_service_rounded, color: AppColors.primary, size: 30),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(service.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16), maxLines: 1, overflow: TextOverflow.ellipsis),
                  Text("by ${service.providerName}", style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.star_rounded, color: Colors.amber, size: 16),
                          Text(" ${service.rating}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                        ],
                      ),
                      Text("₹${service.price.toInt()}", style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 16)),
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

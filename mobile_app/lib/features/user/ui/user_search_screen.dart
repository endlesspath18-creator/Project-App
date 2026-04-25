import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import 'package:mobile_app/core/design_system.dart';
import 'package:mobile_app/core/app_dimensions.dart';
import 'package:mobile_app/widgets/glass_widgets.dart';
import 'package:mobile_app/providers/service_provider.dart';
import 'package:mobile_app/core/app_routes.dart';

class UserSearchScreen extends StatefulWidget {
  const UserSearchScreen({super.key});

  @override
  State<UserSearchScreen> createState() => _UserSearchScreenState();
}

class _UserSearchScreenState extends State<UserSearchScreen> {
  final _searchController = TextEditingController();
  final List<String> _recentSearches = ["AC Repair", "Cleaning", "Plumbing", "Home Painting"];
  Timer? _debounce;
  bool _isFirstLoad = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final category = ModalRoute.of(context)!.settings.arguments as String?;
      if (category != null) {
        _searchController.text = category;
        _onSearchChanged(category);
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (mounted) {
        context.read<ServiceProvider>().fetchAllServices(query: query);
        setState(() => _isFirstLoad = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final serviceProv = Provider.of<ServiceProvider>(context);
    
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(child: Container(decoration: const BoxDecoration(gradient: AppGradients.bgGlow))),
          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: serviceProv.isLoading 
                    ? const Center(child: CircularProgressIndicator())
                    : _buildContent(serviceProv),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(ServiceProvider serviceProv) {
    if (_searchController.text.isEmpty && _isFirstLoad) {
      return SingleChildScrollView(
        padding: AppDimensions.screenPadding(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AppSectionLabel(label: "Recent Searches"),
            const SizedBox(height: AppDimensions.s12),
            _buildRecentSearches(),
            const SizedBox(height: AppDimensions.s32),
            const AppSectionLabel(label: "Popular Categories"),
            const SizedBox(height: AppDimensions.s16),
            _buildPopularCategories(),
          ],
        ),
      );
    }

    if (serviceProv.services.isEmpty) {
      return _buildNoResults();
    }

    return ListView.builder(
      padding: AppDimensions.screenPadding(context),
      itemCount: serviceProv.services.length,
      itemBuilder: (context, index) {
        final service = serviceProv.services[index];
        return FadeInUp(
          delay: Duration(milliseconds: 50 * index),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: GestureDetector(
              onTap: () => Navigator.pushNamed(context, AppRoutes.providerDetails, arguments: service),
              child: GlassCard(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Container(
                      width: 80, height: 80,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.home_repair_service_rounded, color: AppColors.primary, size: 32),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(service.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          const SizedBox(height: 4),
                          Text(service.providerName, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.star_rounded, color: Colors.amber, size: 16),
                              const Text(" 4.5", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                              const Spacer(),
                              Text("₹${service.price.toInt()}", style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(AppDimensions.s24),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: FadeInDown(
              child: GlassInput(
                controller: _searchController,
                hintText: "Search for services...",
                prefixIcon: Icons.search_rounded,
                onChanged: _onSearchChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentSearches() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _recentSearches.map((s) => _buildChip(s)).toList(),
    );
  }

  Widget _buildChip(String label) {
    return GestureDetector(
      onTap: () {
        _searchController.text = label;
        _onSearchChanged(label);
      },
      child: FadeIn(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.border),
            boxShadow: const [AppShadows.soft],
          ),
          child: Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w500)),
        ),
      ),
    );
  }

  Widget _buildPopularCategories() {
    final cats = [
      {'icon': Icons.ac_unit_rounded, 'label': 'AC Repair'},
      {'icon': Icons.cleaning_services_rounded, 'label': 'Cleaning'},
      {'icon': Icons.plumbing_rounded, 'label': 'Plumbing'},
      {'icon': Icons.electrical_services_rounded, 'label': 'Electrical'},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 2.5,
      ),
      itemCount: cats.length,
      itemBuilder: (context, index) => FadeInUp(
        delay: Duration(milliseconds: 100 * index),
        child: GestureDetector(
          onTap: () {
            final label = cats[index]['label'] as String;
            _searchController.text = label;
            _onSearchChanged(label);
          },
          child: GlassCard(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Icon(cats[index]['icon'] as IconData, color: AppColors.primary, size: 20),
                const SizedBox(width: 12),
                Text(cats[index]['label'] as String, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNoResults() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 100),
        child: Column(
          children: [
            Icon(Icons.search_off_rounded, size: 80, color: AppColors.primary.withValues(alpha: 0.1)),
            const SizedBox(height: 24),
            const Text("No results found", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
            const SizedBox(height: 8),
            const Text("Try searching for something else", style: TextStyle(color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}

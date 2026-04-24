import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:mobile_app/core/design_system.dart';
import 'package:mobile_app/core/app_dimensions.dart';
import 'package:mobile_app/widgets/glass_widgets.dart';

class UserSearchScreen extends StatefulWidget {
  const UserSearchScreen({super.key});

  @override
  State<UserSearchScreen> createState() => _UserSearchScreenState();
}

class _UserSearchScreenState extends State<UserSearchScreen> {
  final _searchController = TextEditingController();
  final List<String> _recentSearches = ["AC Repair", "Cleaning", "Plumbing", "Home Painting"];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(child: Container(decoration: const BoxDecoration(gradient: AppGradients.bgGlow))),
          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: AppDimensions.screenPadding(context),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (_searchController.text.isEmpty) ...[
                          const AppSectionLabel(label: "Recent Searches"),
                          const SizedBox(height: AppDimensions.s12),
                          _buildRecentSearches(),
                          const SizedBox(height: AppDimensions.s32),
                          const AppSectionLabel(label: "Popular Categories"),
                          const SizedBox(height: AppDimensions.s16),
                          _buildPopularCategories(),
                        ] else ...[
                           _buildSearchResults(),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
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
                onChanged: (v) => setState(() {}),
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
    return FadeIn(
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
    );
  }

  Widget _buildSearchResults() {
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

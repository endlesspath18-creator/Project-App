import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile_app/core/design_system.dart';
import 'package:mobile_app/core/app_dimensions.dart';
import 'package:mobile_app/providers/user_account_provider.dart';
import 'package:mobile_app/widgets/glass_widgets.dart';
import 'package:animate_do/animate_do.dart';

class FavoritesTab extends StatefulWidget {
  const FavoritesTab({super.key});

  @override
  State<FavoritesTab> createState() => _FavoritesTabState();
}

class _FavoritesTabState extends State<FavoritesTab> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<UserAccountProvider>(context, listen: false).fetchFavorites();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<UserAccountProvider>(context);
    final favorites = provider.favorites;
    final isLoading = provider.isLoading;

    if (isLoading && favorites.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (favorites.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.favorite_border_rounded, size: 64, color: AppColors.textTertiary),
            const SizedBox(height: 16),
            const Text("No favorites yet", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text("Save your favorite services here", style: TextStyle(color: AppColors.textSecondary)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: favorites.length,
      itemBuilder: (context, index) {
        final fav = favorites[index];
        final service = fav['service'];
        final providerData = fav['provider'];

        return FadeInUp(
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            child: GlassCard(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: AppColors.bgLight,
                      borderRadius: BorderRadius.circular(12),
                      image: service != null && service['images'] != null && service['images'].isNotEmpty
                          ? DecorationImage(image: NetworkImage(service['images'][0]), fit: BoxFit.cover)
                          : null,
                    ),
                    child: service == null || service['images'] == null || service['images'].isEmpty
                        ? const Icon(Icons.business, color: AppColors.primary)
                        : null,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          service != null ? service['title'] : providerData['fullName'],
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        if (service != null)
                          Text(service['provider']['fullName'], style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.star, size: 14, color: Colors.amber),
                            const SizedBox(width: 4),
                            Text(
                              service != null ? service['rating'].toString() : providerData['providerProfile']['rating'].toString(),
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.favorite, color: Colors.red),
                    onPressed: () {
                      provider.removeFavorite(fav['id']);
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile_app/providers/auth_provider.dart';
import 'package:mobile_app/core/design_system.dart';
import 'package:mobile_app/core/app_dimensions.dart';
import 'package:mobile_app/core/app_routes.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final fullName = user?.fullName ?? 'Friend';
    final firstName = fullName.split(' ')[0];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.s24, vertical: 20),
      child: Row(
        children: [
          // Greeting & Location
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Hi, $firstName",
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.5,
                    fontFamily: 'Outfit',
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  "What are you looking for today?",
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                    fontFamily: 'Outfit',
                  ),
                ),
              ],
            ),
          ),
          
          // Notification Icon
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.border),
              boxShadow: const [AppShadows.soft],
            ),
            child: Stack(
              children: [
                IconButton(
                  onPressed: () => Navigator.pushNamed(context, AppRoutes.notifications),
                  icon: const Icon(Icons.notifications_none_rounded, color: AppColors.textPrimary, size: 24),
                ),
                Positioned(
                  right: 14,
                  top: 14,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.accent,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(width: 12),
          
          // Profile Avatar
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, AppRoutes.userProfile),
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primary, width: 2),
                image: DecorationImage(
                  image: NetworkImage("https://ui-avatars.com/api/?name=$fullName&background=E6F2F1&color=045F56&bold=true"),
                  fit: BoxFit.cover,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

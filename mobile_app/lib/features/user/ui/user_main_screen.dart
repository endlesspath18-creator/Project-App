import 'package:flutter/material.dart';
import 'package:mobile_app/core/design_system.dart';
import 'package:mobile_app/core/app_dimensions.dart';
import 'package:mobile_app/features/user/home/user_home_screen.dart';
import 'package:mobile_app/features/user/ui/bookings_view.dart';
import 'package:mobile_app/features/user/ui/user_search_screen.dart';
import 'package:mobile_app/features/user/ui/user_favorites_screen.dart';
import 'package:mobile_app/features/user/account/ui/user_account_screen.dart';

class UserMainScreen extends StatefulWidget {
  const UserMainScreen({super.key});

  @override
  State<UserMainScreen> createState() => _UserMainScreenState();
}

class _UserMainScreenState extends State<UserMainScreen> {
  int _currentIndex = 0;
  final PageController _pageController = PageController();

  final List<Widget> _pages = [
    const UserHomeScreen(),
    const UserSearchScreen(),
    const BookingsView(isStandalone: true),
    const UserFavoritesScreen(),
    const UserAccountScreen(),
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
    return PopScope(
      canPop: _currentIndex == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (_currentIndex != 0) {
          _onTabTapped(0);
        }
      },
      child: Scaffold(
        body: PageView(
          controller: _pageController,
          physics: const NeverScrollableScrollPhysics(),
          onPageChanged: (index) => setState(() => _currentIndex = index),
          children: _pages,
        ),
        bottomNavigationBar: _buildBottomNav(context),
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    if (AppResponsive.isDesktop(context)) return const SizedBox.shrink();
    
    return Container(
      height: 75 + MediaQuery.of(context).padding.bottom,
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(top: BorderSide(color: AppColors.divider, width: 1.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 20,
            offset: const Offset(0, -8),
          )
        ],
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(Icons.home_rounded, Icons.home_outlined, "Home", 0),
              _buildNavItem(Icons.search_rounded, Icons.search_outlined, "Search", 1),
              _buildNavItem(Icons.calendar_today_rounded, Icons.calendar_today_outlined, "Bookings", 2),
              _buildNavItem(Icons.favorite_rounded, Icons.favorite_border, "Favorites", 3),
              _buildNavItem(Icons.person_rounded, Icons.person_outline_rounded, "Profile", 4),
            ],
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData activeIcon, IconData inactiveIcon, String label, int index) {
    final isActive = _currentIndex == index;
    return InkWell(
      onTap: () => _onTabTapped(index),
      borderRadius: BorderRadius.circular(25),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary.withValues(alpha: 0.08) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isActive ? activeIcon : inactiveIcon, 
              color: isActive ? AppColors.primary : AppColors.textTertiary, 
              size: 26,
            ),
            const SizedBox(height: 4),
            Text(
              label, 
              style: TextStyle(
                color: isActive ? AppColors.primary : AppColors.textTertiary, 
                fontSize: 10, 
                fontWeight: isActive ? FontWeight.w800 : FontWeight.w500,
                fontFamily: 'Outfit',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

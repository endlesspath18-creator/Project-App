import 'package:flutter/material.dart';

class AppDimensions {
  // Spacing Scale
  static const double s4 = 4.0;
  static const double s8 = 8.0;
  static const double s12 = 12.0;
  static const double s16 = 16.0;
  static const double s20 = 20.0;
  static const double s24 = 24.0;
  static const double s32 = 32.0;
  static const double s40 = 40.0;
  static const double s48 = 48.0;

  // Border Radius
  static const double r8 = 8.0;
  static const double r12 = 12.0;
  static const double r16 = 16.0;
  static const double r24 = 24.0;
  static const double r32 = 32.0;

  // Common Constraints
  static const double maxContentWidth = 1200.0;
  static const double mobileBreakpoint = 600.0;
  static const double tabletBreakpoint = 900.0;

  // Utility to get responsive horizontal padding
  static EdgeInsets screenPadding(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    if (width > 1200) return const EdgeInsets.symmetric(horizontal: 120);
    if (width > 800) return const EdgeInsets.symmetric(horizontal: 60);
    return const EdgeInsets.symmetric(horizontal: 24);
  }
}

class AppResponsive {
  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < AppDimensions.mobileBreakpoint;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= AppDimensions.mobileBreakpoint &&
      MediaQuery.of(context).size.width < AppDimensions.tabletBreakpoint;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= AppDimensions.tabletBreakpoint;

  static double screenWidth(BuildContext context) => MediaQuery.of(context).size.width;
  static double screenHeight(BuildContext context) => MediaQuery.of(context).size.height;
}

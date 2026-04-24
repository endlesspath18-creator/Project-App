import 'package:flutter/material.dart';

class AppColors {
  // Brand Color
  static const Color primary = Color(0xFFDB2383);
  static const Color primaryLight = Color(0xFFFFE6F2);
  static const Color primaryDark = Color(0xFFB01C69);
  static const Color primaryContainer = Color(0xFFFFE6F2); // Added as fallback
  
  // Base Colors
  static const Color background = Color(0xFFFBFBFE);
  static const Color surface = Colors.white;
  static const Color surfaceVariant = Color(0xFFF1F5F9);
  
  // Text Colors
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textTertiary = Color(0xFF94A3B8);
  
  // Interaction Colors
  static const Color secondary = Color(0xFF6366F1); // Indigo accent
  static const Color tertiary = Color(0xFF10B981);  // Emerald accent
  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);
  
  // Grays / Borders
  static const Color border = Color(0xFFE2E8F0);
  static const Color divider = Color(0xFFF1F5F9);

  // Utility
  static const Color glassBackground = Color.fromRGBO(255, 255, 255, 0.8);
  static const Color glassBorder = Color.fromRGBO(219, 35, 131, 0.1);
}

class AppGradients {
  static const LinearGradient primary = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFDB2383),
      Color(0xFFFF4D9C),
    ],
  );

  static const LinearGradient soft = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFFFBFBFE),
      Color(0xFFF1F5F9),
    ],
  );

  static const RadialGradient bgGlow = RadialGradient(
    center: Alignment(0.8, -0.6),
    radius: 1.2,
    colors: [
      Color(0xFFFFE6F2),
      Color(0xFFFBFBFE),
    ],
  );
}

class AppShadows {
  static const BoxShadow soft = BoxShadow(
    color: Color.fromRGBO(0, 0, 0, 0.05),
    blurRadius: 20,
    offset: Offset(0, 10),
  );
  
  static const BoxShadow card = BoxShadow(
    color: Color.fromRGBO(219, 35, 131, 0.08),
    blurRadius: 30,
    offset: Offset(0, 4),
  );
}


import 'package:flutter/material.dart';

class AppColors {
  // Brand Color
  static const Color primary = Color(0xFFBAE6D8);
  static const Color primaryLight = Color(0xFFE2F5EE);
  static const Color primaryDark = Color(0xFF8BBFA9);
  static const Color primaryContainer = Color(0xFFE2F5EE);
  
  // Base Colors
  static const Color background = Color(0xFFF7FBFA);
  static const Color surface = Colors.white;
  static const Color surfaceVariant = Color(0xFFEFF7F4);
  
  // Text Colors
  static const Color textPrimary = Color(0xFF1E293B);
  static const Color textSecondary = Color(0xFF475569);
  static const Color textTertiary = Color(0xFF94A3B8);
  
  // Interaction Colors
  static const Color secondary = Color(0xFF475569); 
  static const Color tertiary = Color(0xFF0D9488);  
  static const Color error = Color(0xFFE11D48);
  static const Color warning = Color(0xFFD97706);
  
  // Grays / Borders
  static const Color border = Color(0xFFE2E8F0);
  static const Color divider = Color(0xFFF1F5F9);

  // Utility
  static const Color glassBackground = Color.fromRGBO(255, 255, 255, 0.85);
  static const Color glassBorder = Color.fromRGBO(186, 230, 216, 0.2);
}

class AppGradients {
  static const LinearGradient primary = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFBAE6D8),
      Color(0xFF94D1B9),
    ],
  );

  static const LinearGradient soft = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFFF7FBFA),
      Color(0xFFEFF7F4),
    ],
  );

  static const RadialGradient bgGlow = RadialGradient(
    center: Alignment(0.8, -0.6),
    radius: 1.2,
    colors: [
      Color(0xFFE2F5EE),
      Color(0xFFF7FBFA),
    ],
  );
}

class AppShadows {
  static const BoxShadow soft = BoxShadow(
    color: Color.fromRGBO(0, 0, 0, 0.04),
    blurRadius: 20,
    offset: Offset(0, 8),
  );
  
  static const BoxShadow card = BoxShadow(
    color: Color.fromRGBO(186, 230, 216, 0.1),
    blurRadius: 30,
    offset: Offset(0, 8),
  );
}


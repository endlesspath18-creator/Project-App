import 'package:flutter/material.dart';

class AppColors {
  // Core Brand Identity - Deep Teal
  static const Color primary = Color(0xFF045F56);
  static const Color primaryLight = Color(0xFFE6F2F1); // Light Teal Tint
  static const Color primaryDark = Color(0xFF03443D);
  static const Color primaryContainer = Color(0xFFF0F7F6);
  
  // Clean Premium Palette
  static const Color background = Color(0xFFFAFAFA); // Soft warm white
  static const Color surface = Colors.white;
  static const Color surfaceVariant = Color(0xFFF5F8F8);
  
  // Typography - High Contrast & Readability
  static const Color textPrimary = Color(0xFF1A1A1A);   // Deep Charcoal
  static const Color textSecondary = Color(0xFF666666); // Muted Gray
  static const Color textTertiary = Color(0xFF999999);
  
  // Status Colors
  static const Color success = Color(0xFF10B981);
  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);
  
  // Accent & Borders
  static const Color accent = Color(0xFF019FAD); // Secondary Teal
  static const Color border = Color(0xFFE5E7EB);
  static const Color divider = Color(0xFFF3F4F6);

  // Design Tokens
  static const Color glassBackground = Color.fromRGBO(255, 255, 255, 0.95);
  static const Color glassBorder = Color.fromRGBO(4, 95, 86, 0.1);
  static const Color bgLight = Color(0xFFF3F4F6);
}


class AppGradients {
  static const LinearGradient primary = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF045F56),
      Color(0xFF067D71),
    ],
  );

  static const LinearGradient soft = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFFFAFAFA),
      Color(0xFFF5F8F8),
    ],
  );

  static const RadialGradient bgGlow = RadialGradient(
    center: Alignment(0.8, -0.6),
    radius: 1.2,
    colors: [
      Color(0xFFE6F2F1),
      Color(0xFFFAFAFA),
    ],
  );
  
  static const LinearGradient premium = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF045F56),
      Color(0xFF019FAD),
    ],
  );
}

class AppShadows {
  static const BoxShadow soft = BoxShadow(
    color: Color.fromRGBO(0, 0, 0, 0.04),
    blurRadius: 20,
    offset: Offset(0, 4),
  );
  
  static const BoxShadow premium = BoxShadow(
    color: Color.fromRGBO(4, 95, 86, 0.08),
    blurRadius: 30,
    offset: Offset(0, 10),
  );

  static const BoxShadow card = BoxShadow(
    color: Color.fromRGBO(0, 0, 0, 0.03),
    blurRadius: 15,
    offset: Offset(0, 6),
  );
}

import 'package:flutter/material.dart';

class GlacierColors {
  // Base Colors
  static const Color background = Color(0xFF0A0E1A);
  static const Color primary = Color(0xFF7DD3FC);
  static const Color primaryContainer = Color(0xFF0E4D6E);
  static const Color onPrimaryContainer = Color(0xFFC8EAFF);
  
  static const Color secondary = Color(0xFF88B4CC);
  static const Color tertiary = Color(0xFFC8A0F0);
  
  static const Color surface = Color(0xFF0F1524);
  static const Color surfaceVariant = Color(0xFF1A2438);
  static const Color onSurface = Color(0xFFE0E8F0);
  static const Color onSurfaceVariant = Color(0xFFA0B4C4);
  
  static const Color error = Color(0xFFFF6B6B);
  
  // Glass Constants
  static const Color glassBackground = Color.fromRGBO(15, 21, 36, 0.6);
  static const Color glassBorder = Color.fromRGBO(125, 211, 252, 0.15);
  static const Color glassLuminousBorder = Color.fromRGBO(255, 255, 255, 0.1);
}

class GlacierGradients {
  static const LinearGradient ice = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF7DD3FC),
      Color(0xFF38BDF8),
    ],
  );

  static const LinearGradient glass = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color.fromRGBO(255, 255, 255, 0.1),
      Color.fromRGBO(255, 255, 255, 0.05),
    ],
  );

  static const RadialGradient bgGlow = RadialGradient(
    center: Alignment(-0.8, -0.6),
    radius: 1.5,
    colors: [
      Color(0xFF0E4D6E),
      Color(0xFF0A0E1A),
    ],
  );
}

class GlacierShadows {
  static const BoxShadow softGlow = BoxShadow(
    color: Color.fromRGBO(125, 211, 252, 0.05),
    blurRadius: 30,
    spreadRadius: 2,
  );
}

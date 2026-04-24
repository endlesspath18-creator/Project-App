import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'design_system.dart';

class AppTheme {
  static ThemeData get dark {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: GlacierColors.primary,
        secondary: GlacierColors.secondary,
        tertiary: GlacierColors.tertiary,
        surface: GlacierColors.surface,
        onSurface: GlacierColors.onSurface,
        background: GlacierColors.background,
        onBackground: GlacierColors.onSurface,
        error: GlacierColors.error,
      ),
      scaffoldBackgroundColor: GlacierColors.background,
      
      // Modern Typography using Inter
      textTheme: GoogleFonts.interTextTheme().copyWith(
        displayLarge: GoogleFonts.inter(fontWeight: FontWeight.bold, color: GlacierColors.onSurface),
        headlineLarge: GoogleFonts.inter(fontWeight: FontWeight.bold, color: GlacierColors.onSurface),
        headlineMedium: GoogleFonts.inter(fontWeight: FontWeight.bold, color: GlacierColors.onSurface),
        titleLarge: GoogleFonts.inter(fontWeight: FontWeight.w600, color: GlacierColors.onSurface),
        bodyLarge: GoogleFonts.inter(color: GlacierColors.onSurface),
        bodyMedium: GoogleFonts.inter(color: GlacierColors.onSurfaceVariant),
      ),

      // Card Theme
      cardTheme: CardTheme(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        color: GlacierColors.surface,
      ),

      // Input Decoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: GlacierColors.glassBackground.withOpacity(0.3),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: GlacierColors.glassBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: GlacierColors.glassBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: GlacierColors.primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      ),

      // Button Themes
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: GlacierColors.primary,
          foregroundColor: GlacierColors.background,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 0,
          textStyle: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
    );
  }

  // Keep light getter for backward compatibility or future use, but point to dark for now
  static ThemeData get light => dark;
}

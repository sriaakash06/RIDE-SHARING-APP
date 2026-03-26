import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color background = Color(0xFF0B1326);
  static const Color surface = Color(0xFF0B1326);
  static const Color surfaceContainerLow = Color(0xFF131B2E);
  static const Color surfaceContainerHigh = Color(0xFF222A3D);
  static const Color surfaceContainerHighest = Color(0xFF2D3449);
  
  static const Color primary = Color(0xFFBEC6E0);
  static const Color secondary = Color(0xFF4AE176);
  static const Color secondaryContainer = Color(0xFF00B954);
  
  static const Color onSurface = Color(0xFFDAE2FD);
  static const Color outlineVariant = Color(0xFF45464D);
  
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      primaryColor: primary,
      colorScheme: const ColorScheme.dark(
        primary: primary,
        secondary: secondary,
        surface: surface,
        background: background,
        onSurface: onSurface,
      ),
      fontFamily: GoogleFonts.inter().fontFamily,
      textTheme: TextTheme(
        displayLarge: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, color: onSurface, fontSize: 56),
        headlineMedium: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, color: onSurface, fontSize: 28),
        bodyLarge: GoogleFonts.inter(color: onSurface, fontSize: 16),
        bodyMedium: GoogleFonts.inter(color: onSurface, fontSize: 14),
        labelSmall: GoogleFonts.inter(color: onSurface, fontSize: 11),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: secondary, // Will use gradient in custom widget
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(48), // 3rem
          ),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceContainerHighest,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: secondary, width: 2),
        ),
      ),
    );
  }
}

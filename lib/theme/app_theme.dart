import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color background = Color(0xFF0A0E1A);
  static const Color surface = Color(0xFF111827);
  static const Color accentCyan = Color(0xFF00F5D4);
  static const Color accentAmber = Color(0xFFF59E0B);
  static const Color accentGreen = Color(0xFF10B981);
  static const Color accentRed = Color(0xFFEF4444);
  static const Color borderColor = Color(0xFF1F2937);
  static const Color textPrimary = Color(0xFFE5E7EB);
  static const Color textSecondary = Color(0xFF9CA3AF);

  static ThemeData get darkTheme {
    return ThemeData.dark().copyWith(
      scaffoldBackgroundColor: background,
      colorScheme: const ColorScheme.dark(
        primary: accentCyan,
        secondary: accentAmber,
        tertiary: accentGreen,
        error: accentRed,
        surface: surface,
        onSurface: textPrimary,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: surface,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.rajdhani(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: textPrimary,
        ),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: borderColor, width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accentCyan,
          foregroundColor: background,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: accentCyan,
          side: const BorderSide(color: accentCyan),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: background,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: accentCyan, width: 2),
        ),
        labelStyle: GoogleFonts.rajdhani(color: textSecondary),
        hintStyle: GoogleFonts.jetBrainsMono(color: textSecondary),
      ),
      textTheme: TextTheme(
        displayLarge: GoogleFonts.rajdhani(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: textPrimary,
        ),
        displayMedium: GoogleFonts.rajdhani(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: textPrimary,
        ),
        displaySmall: GoogleFonts.rajdhani(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: textPrimary,
        ),
        headlineMedium: GoogleFonts.rajdhani(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        bodyLarge: GoogleFonts.rajdhani(
          fontSize: 16,
          color: textPrimary,
        ),
        bodyMedium: GoogleFonts.rajdhani(
          fontSize: 14,
          color: textSecondary,
        ),
        labelLarge: GoogleFonts.jetBrainsMono(
          fontSize: 14,
          color: textPrimary,
        ),
        labelMedium: GoogleFonts.jetBrainsMono(
          fontSize: 12,
          color: textSecondary,
        ),
      ),
    );
  }

  static BoxDecoration get glowCyan => BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accentCyan, width: 2),
        boxShadow: [
          BoxShadow(
            color: accentCyan.withOpacity(0.5),
            spreadRadius: 4,
            blurRadius: 12,
          ),
        ],
      );

  static BoxDecoration get glowAmber => BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accentAmber, width: 2),
        boxShadow: [
          BoxShadow(
            color: accentAmber.withOpacity(0.5),
            spreadRadius: 4,
            blurRadius: 12,
          ),
        ],
      );

  static BoxDecoration get glowGreen => BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accentGreen, width: 2),
        boxShadow: [
          BoxShadow(
            color: accentGreen.withOpacity(0.5),
            spreadRadius: 4,
            blurRadius: 12,
          ),
        ],
      );

  static BoxDecoration get glowRed => BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accentRed, width: 2),
        boxShadow: [
          BoxShadow(
            color: accentRed.withOpacity(0.5),
            spreadRadius: 4,
            blurRadius: 12,
          ),
        ],
      );

  static BoxDecoration get panelDecoration => BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: 1),
      );
}
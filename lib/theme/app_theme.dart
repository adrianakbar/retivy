import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Light Palette
  static const Color primaryLight = Color(0xFF4648D4);
  static const Color primaryContainerLight = Color(0xFF6063EE);
  static const Color onPrimaryLight = Color(0xFFFFFFFF);
  static const Color onPrimaryContainerLight = Color(0xFFFFFFFF);
  
  static const Color secondaryLight = Color(0xFF006C49);
  static const Color secondaryContainerLight = Color(0xFF6CF8BB);
  static const Color onSecondaryContainerLight = Color(0xFF00714D);
  
  static const Color tertiaryLight = Color(0xFF825100);
  static const Color tertiaryContainerLight = Color(0xFFA36700);
  
  static const Color backgroundLight = Color(0xFFF7F9FB);
  static const Color onBackgroundLight = Color(0xFF191C1E);
  
  static const Color surfaceLight = Color(0xFFF7F9FB);
  static const Color onSurfaceLight = Color(0xFF191C1E);
  static const Color surfaceVariantLight = Color(0xFFE0E3E5);
  static const Color onSurfaceVariantLight = Color(0xFF464554);
  
  static const Color surfaceContainerLowestLight = Color(0xFFFFFFFF);
  static const Color surfaceContainerLowLight = Color(0xFFF2F4F6);
  static const Color surfaceContainerLight = Color(0xFFECEEF0);
  static const Color surfaceContainerHighLight = Color(0xFFE6E8EA);
  static const Color surfaceContainerHighestLight = Color(0xFFE0E3E5);
  
  static const Color outlineLight = Color(0xFF767586);
  static const Color outlineVariantLight = Color(0xFFC7C4D7);
  static const Color errorLight = Color(0xFFBA1A1A);

  // Dark Palette
  static const Color primaryDark = Color(0xFFC0C1FF);
  static const Color primaryContainerDark = Color(0xFF4648D4);
  static const Color onPrimaryDark = Color(0xFF07006C);
  static const Color onPrimaryContainerDark = Color(0xFFE1E0FF);
  
  static const Color secondaryDark = Color(0xFF4EDEA3);
  static const Color secondaryContainerDark = Color(0xFF005236);
  static const Color onSecondaryContainerDark = Color(0xFF6CF8BB);
  
  static const Color tertiaryDark = Color(0xFFFFB95F);
  static const Color tertiaryContainerDark = Color(0xFF653E00);
  
  static const Color backgroundDark = Color(0xFF191C1E);
  static const Color onBackgroundDark = Color(0xFFECEEF0);
  
  static const Color surfaceDark = Color(0xFF191C1E);
  static const Color onSurfaceDark = Color(0xFFECEEF0);
  static const Color surfaceVariantDark = Color(0xFF2D3133);
  static const Color onSurfaceVariantDark = Color(0xFFC7C4D7);
  
  static const Color surfaceContainerLowestDark = Color(0xFF0F1113);
  static const Color surfaceContainerLowDark = Color(0xFF1F2225);
  static const Color surfaceContainerDark = Color(0xFF25292C);
  static const Color surfaceContainerHighDark = Color(0xFF2D3135);
  static const Color surfaceContainerHighestDark = Color(0xFF383D41);
  
  static const Color outlineDark = Color(0xFF8A8897);
  static const Color outlineVariantDark = Color(0xFF464554);
  static const Color errorDark = Color(0xFFFFDAD6);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: primaryLight,
        primaryContainer: primaryContainerLight,
        onPrimary: onPrimaryLight,
        onPrimaryContainer: onPrimaryContainerLight,
        secondary: secondaryLight,
        secondaryContainer: secondaryContainerLight,
        onSecondaryContainer: onSecondaryContainerLight,
        tertiary: tertiaryLight,
        tertiaryContainer: tertiaryContainerLight,
        surface: surfaceLight,
        onSurface: onSurfaceLight,
        onSurfaceVariant: onSurfaceVariantLight,
        surfaceContainerLowest: surfaceContainerLowestLight,
        surfaceContainerLow: surfaceContainerLowLight,
        surfaceContainer: surfaceContainerLight,
        surfaceContainerHigh: surfaceContainerHighLight,
        surfaceContainerHighest: surfaceContainerHighestLight,
        outline: outlineLight,
        outlineVariant: outlineVariantLight,
        error: errorLight,
      ),
      fontFamily: GoogleFonts.inter().fontFamily,
      textTheme: TextTheme(
        headlineLarge: GoogleFonts.outfit(
          fontSize: 32,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.64,
          height: 1.25,
        ),
        headlineMedium: GoogleFonts.outfit(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          height: 1.4,
        ),
        titleLarge: GoogleFonts.outfit(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.24,
          height: 1.33,
        ),
        bodyLarge: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          height: 1.5,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          height: 1.4,
        ),
        labelLarge: GoogleFonts.plusJakartaSans(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.6,
          height: 1.33,
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: primaryDark,
        primaryContainer: primaryContainerDark,
        onPrimary: onPrimaryDark,
        onPrimaryContainer: onPrimaryContainerDark,
        secondary: secondaryDark,
        secondaryContainer: secondaryContainerDark,
        onSecondaryContainer: onSecondaryContainerDark,
        tertiary: tertiaryDark,
        tertiaryContainer: tertiaryContainerDark,
        surface: surfaceDark,
        onSurface: onSurfaceDark,
        onSurfaceVariant: onSurfaceVariantDark,
        surfaceContainerLowest: surfaceContainerLowestDark,
        surfaceContainerLow: surfaceContainerLowDark,
        surfaceContainer: surfaceContainerDark,
        surfaceContainerHigh: surfaceContainerHighDark,
        surfaceContainerHighest: surfaceContainerHighestDark,
        outline: outlineDark,
        outlineVariant: outlineVariantDark,
        error: errorDark,
      ),
      fontFamily: GoogleFonts.inter().fontFamily,
      textTheme: TextTheme(
        headlineLarge: GoogleFonts.outfit(
          fontSize: 32,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.64,
          height: 1.25,
          color: Colors.white,
        ),
        headlineMedium: GoogleFonts.outfit(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          height: 1.4,
          color: Colors.white,
        ),
        titleLarge: GoogleFonts.outfit(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.24,
          height: 1.33,
          color: Colors.white,
        ),
        bodyLarge: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          height: 1.5,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          height: 1.4,
        ),
        labelLarge: GoogleFonts.plusJakartaSans(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.6,
          height: 1.33,
        ),
      ),
    );
  }
}

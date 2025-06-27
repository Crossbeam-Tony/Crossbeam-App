import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DesignSystem {
  // Spacing
  static const double globalSpacing = 4.0;
  static const double borderRadius = 4.0;
  static const double smallSpacing = 4.0;
  static const double largeSpacing = 4.0;
  static const double extraLargeSpacing = 4.0;

  // Colors
  static const Color charcoal = Color(0xFF232323);
  static const Color mutedTangerine = Color(0xFFFF7300);
  static const Color pureBlack = Color(0xFF000000);
  static const Color pureWhite = Color(0xFFFFFFFF);
  static const Color lightGrey = Color(0xFFF5F5F5);
  static const Color mediumGrey = Color(0xFF9E9E9E);
  static const Color darkGrey = Color(0xFF424242);

  // Font Families
  static const String primaryFont = 'Manrope';
  static const String secondaryFont = 'IBM Plex Sans';

  // Font Sizes
  static const double minFontSize = 12.0;
  static const double bodyFontSize = 14.0;
  static const double titleFontSize = 16.0;
  static const double headerFontSize = 20.0;

  // Card Design
  static const double cardBorderRadius = 4.0;
  static const double cardPadding = 4.0;
  static const double cardMargin = 4.0;
  static const double screenEdgeSpacing = 4.0;

  // Theme Data
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.light(
      primary: mutedTangerine,
      secondary: mutedTangerine.withAlpha((0.8 * 255).toInt()),
      surface: pureWhite,
      error: const Color(0xFFE53935),
      onPrimary: pureWhite,
      onSecondary: pureWhite,
      onSurface: charcoal,
      onError: pureWhite,
    ),
    scaffoldBackgroundColor: lightGrey,
    textTheme: GoogleFonts.interTextTheme().copyWith(
      bodyLarge: const TextStyle(color: charcoal),
      bodyMedium: const TextStyle(color: charcoal),
      titleLarge: const TextStyle(color: charcoal),
      headlineMedium: const TextStyle(color: charcoal),
    ),
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      elevation: 0,
      backgroundColor: pureWhite,
      foregroundColor: charcoal,
    ),
    cardTheme: CardThemeData(
      elevation: 2,
      color: pureWhite,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: charcoal,
      selectedItemColor: mutedTangerine,
      unselectedItemColor: pureWhite,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: mutedTangerine,
        foregroundColor: pureWhite,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    ),
  );

  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.dark(
      primary: mutedTangerine,
      secondary: mutedTangerine.withAlpha((0.8 * 255).toInt()),
      surface: charcoal,
      error: const Color(0xFFE53935),
      onPrimary: pureWhite,
      onSecondary: pureWhite,
      onSurface: pureWhite,
      onError: pureWhite,
    ),
    scaffoldBackgroundColor: const Color(0xFF181A20),
    textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme).copyWith(
      bodyLarge: const TextStyle(color: pureWhite),
      bodyMedium: const TextStyle(color: pureWhite),
      titleLarge: const TextStyle(color: pureWhite),
      headlineMedium: const TextStyle(color: pureWhite),
    ),
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      elevation: 0,
      backgroundColor: charcoal,
      foregroundColor: pureWhite,
    ),
    cardTheme: CardThemeData(
      elevation: 2,
      color: charcoal,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: charcoal,
      selectedItemColor: mutedTangerine,
      unselectedItemColor: pureWhite,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: mutedTangerine,
        foregroundColor: pureWhite,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    ),
  );
}

import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: Color(0xFFFF9800), // Brand accent (orange)
        onPrimary: Color(0xFFFFFFFF), // Main canvas
        surface: Color(0xFFF5F5F5), // Cards, sheets
        onSurface: Color(0xFF23262B), // Default text/icons
        error: Color(0xFFE53935), // Error/warning
        onError: Color(0xFFFFFFFF), // Text/icons on error
        secondary: Color(0xFF2196F3), // Secondary actions
        onSecondary: Color(0xFFFFFFFF), // Text/icons on secondary
        tertiary: Color(0xFF4CAF50), // Tertiary actions
        onTertiary: Color(0xFFFFFFFF), // Text/icons on tertiary
        outline: Color(0xFFE0E0E0), // Outlines
        outlineVariant: Color(0xFFCCCCCC), // Variant outlines
        shadow: Color(0xFF000000), // Shadows
        scrim: Color(0xFF000000), // Scrims
        inverseSurface: Color(0xFF121212), // Inverse surface
        onInverseSurface: Color(0xFFFFFFFF), // Text on inverse surface
        inversePrimary: Color(0xFFFFB74D), // Inverse primary
        surfaceTint: Color(0xFFFF9800), // Surface tint
      ),
      dividerColor: const Color(0xFFE0E0E0), // Borders/separators
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme(
        brightness: Brightness.dark,
        primary: Color(0xFFFF9800), // Brand accent (orange)
        onPrimary: Color(0xFF000000), // Main canvas
        surface: Color(0xFF1E1E1E), // Cards, sheets
        onSurface: Color(0xFFFFFFFF), // Default text/icons
        error: Color(0xFFE53935), // Error/warning
        onError: Color(0xFFFFFFFF), // Text/icons on error
        secondary: Color(0xFF2196F3), // Secondary actions
        onSecondary: Color(0xFFFFFFFF), // Text/icons on secondary
        tertiary: Color(0xFF4CAF50), // Tertiary actions
        onTertiary: Color(0xFFFFFFFF), // Text/icons on tertiary
        outline: Color(0xFF424242), // Outlines
        outlineVariant: Color(0xFF616161), // Variant outlines
        shadow: Color(0xFF000000), // Shadows
        scrim: Color(0xFF000000), // Scrims
        inverseSurface: Color(0xFFFFFFFF), // Inverse surface
        onInverseSurface: Color(0xFF000000), // Text on inverse surface
        inversePrimary: Color(0xFFFFB74D), // Inverse primary
        surfaceTint: Color(0xFFFF9800), // Surface tint
      ),
      dividerColor: const Color(0xFF424242), // Borders/separators
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';

class ThemeManager {
  static Future<ThemeData> loadPromptTheme(
      {String themeName = 'default'}) async {
    // 1) Load JSON stub
    final jsonStr =
        await rootBundle.loadString('assets/themes/custom_colors.json');
    final map = jsonDecode(jsonStr) as Map<String, dynamic>;

    // Get the specific theme or fallback to default
    final themeData = map[themeName] ?? map['default'] ?? map.values.first;

    // 2) Parse seven roles (TODO: replace stub values once JSON is provided)
    final colors = {
      'background': themeData['background'] ?? '#FFFFFF',
      'surface': themeData['surface'] ?? '#F2F2F2',
      'primary': themeData['primary'] ?? '#0066FF',
      'onPrimary': themeData['onPrimary'] ?? '#FFFFFF',
      'onSurface': themeData['onSurface'] ?? '#212121',
      'divider': themeData['divider'] ?? '#E0E0E0',
      'error': themeData['error'] ?? '#B00020',
    };

    // 3) Build ThemeData
    return ThemeData(
      useMaterial3: true,
      textTheme: TextTheme(
        displayLarge:
            GoogleFonts.firaCode(fontSize: 32, fontWeight: FontWeight.bold),
        displayMedium:
            GoogleFonts.firaCode(fontSize: 28, fontWeight: FontWeight.bold),
        displaySmall:
            GoogleFonts.firaCode(fontSize: 24, fontWeight: FontWeight.bold),
        headlineLarge:
            GoogleFonts.firaCode(fontSize: 22, fontWeight: FontWeight.w600),
        headlineMedium:
            GoogleFonts.firaCode(fontSize: 20, fontWeight: FontWeight.w600),
        headlineSmall:
            GoogleFonts.firaCode(fontSize: 18, fontWeight: FontWeight.w600),
        titleLarge: GoogleFonts.sourceCodePro(
            fontSize: 16, fontWeight: FontWeight.w600),
        titleMedium: GoogleFonts.sourceCodePro(
            fontSize: 14, fontWeight: FontWeight.w600),
        titleSmall: GoogleFonts.sourceCodePro(
            fontSize: 12, fontWeight: FontWeight.w600),
        bodyLarge: GoogleFonts.sourceCodePro(fontSize: 16),
        bodyMedium: GoogleFonts.sourceCodePro(fontSize: 14),
        bodySmall: GoogleFonts.sourceCodePro(fontSize: 12),
        labelLarge:
            GoogleFonts.courierPrime(fontSize: 14, fontWeight: FontWeight.w600),
        labelMedium:
            GoogleFonts.courierPrime(fontSize: 12, fontWeight: FontWeight.w600),
        labelSmall:
            GoogleFonts.courierPrime(fontSize: 10, fontWeight: FontWeight.w600),
      ),
      colorScheme: ColorScheme(
        brightness: Brightness.light,
        surface: Color(_hexToInt(colors['surface']!)),
        primary: Color(_hexToInt(colors['primary']!)),
        onPrimary: Color(_hexToInt(colors['onPrimary']!)),
        onSurface: Color(_hexToInt(colors['onSurface']!)),
        error: Color(_hexToInt(colors['error']!)),
        onError: Colors.white,
        secondary: Color(_hexToInt(colors['primary']!)).withOpacity(0.8),
        onSecondary: Color(_hexToInt(colors['onPrimary']!)),
        tertiary: Color(_hexToInt(colors['primary']!)).withOpacity(0.6),
        onTertiary: Color(_hexToInt(colors['onPrimary']!)),
        outline: Color(_hexToInt(colors['divider']!)),
        outlineVariant: Color(_hexToInt(colors['divider']!)).withOpacity(0.5),
        shadow: Colors.black,
        scrim: Colors.black,
        inverseSurface: Color(_hexToInt(colors['onSurface']!)),
        onInverseSurface: Color(_hexToInt(colors['background']!)),
        inversePrimary: Color(_hexToInt(colors['primary']!)).withOpacity(0.8),
        surfaceTint: Color(_hexToInt(colors['primary']!)),
      ),
      dividerColor: Color(_hexToInt(colors['divider']!)),
      // TODO: apply scanline overlay in your Scaffold or via a global decorator
    );
  }

  static Future<ThemeData> loadPromptThemeDark(
      {String themeName = 'default'}) async {
    // 1) Load JSON stub
    final jsonStr =
        await rootBundle.loadString('assets/themes/custom_colors.json');
    final map = jsonDecode(jsonStr) as Map<String, dynamic>;

    // Get the specific theme or fallback to default
    final themeData = map[themeName] ?? map['default'] ?? map.values.first;

    // 2) Parse seven roles for dark mode (TODO: replace stub values once JSON is provided)
    final colors = {
      'background': themeData['background'] ?? '#121212',
      'surface': themeData['surface'] ?? '#1E1E1E',
      'primary': themeData['primary'] ?? '#0066FF',
      'onPrimary': themeData['onPrimary'] ?? '#000000',
      'onSurface': themeData['onSurface'] ?? '#FFFFFF',
      'divider': themeData['divider'] ?? '#424242',
      'error': themeData['error'] ?? '#CF6679',
    };

    // 3) Build ThemeData for dark mode
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      textTheme: TextTheme(
        displayLarge:
            GoogleFonts.firaCode(fontSize: 32, fontWeight: FontWeight.bold),
        displayMedium:
            GoogleFonts.firaCode(fontSize: 28, fontWeight: FontWeight.bold),
        displaySmall:
            GoogleFonts.firaCode(fontSize: 24, fontWeight: FontWeight.bold),
        headlineLarge:
            GoogleFonts.firaCode(fontSize: 22, fontWeight: FontWeight.w600),
        headlineMedium:
            GoogleFonts.firaCode(fontSize: 20, fontWeight: FontWeight.w600),
        headlineSmall:
            GoogleFonts.firaCode(fontSize: 18, fontWeight: FontWeight.w600),
        titleLarge: GoogleFonts.sourceCodePro(
            fontSize: 16, fontWeight: FontWeight.w600),
        titleMedium: GoogleFonts.sourceCodePro(
            fontSize: 14, fontWeight: FontWeight.w600),
        titleSmall: GoogleFonts.sourceCodePro(
            fontSize: 12, fontWeight: FontWeight.w600),
        bodyLarge: GoogleFonts.sourceCodePro(fontSize: 16),
        bodyMedium: GoogleFonts.sourceCodePro(fontSize: 14),
        bodySmall: GoogleFonts.sourceCodePro(fontSize: 12),
        labelLarge:
            GoogleFonts.courierPrime(fontSize: 14, fontWeight: FontWeight.w600),
        labelMedium:
            GoogleFonts.courierPrime(fontSize: 12, fontWeight: FontWeight.w600),
        labelSmall:
            GoogleFonts.courierPrime(fontSize: 10, fontWeight: FontWeight.w600),
      ),
      colorScheme: ColorScheme(
        brightness: Brightness.dark,
        surface: Color(_hexToInt(colors['surface']!)),
        primary: Color(_hexToInt(colors['primary']!)),
        onPrimary: Color(_hexToInt(colors['onPrimary']!)),
        onSurface: Color(_hexToInt(colors['onSurface']!)),
        error: Color(_hexToInt(colors['error']!)),
        onError: Colors.black,
        secondary: Color(_hexToInt(colors['primary']!)).withOpacity(0.8),
        onSecondary: Color(_hexToInt(colors['onPrimary']!)),
        tertiary: Color(_hexToInt(colors['primary']!)).withOpacity(0.6),
        onTertiary: Color(_hexToInt(colors['onPrimary']!)),
        outline: Color(_hexToInt(colors['divider']!)),
        outlineVariant: Color(_hexToInt(colors['divider']!)).withOpacity(0.5),
        shadow: Colors.black,
        scrim: Colors.black,
        inverseSurface: Color(_hexToInt(colors['onSurface']!)),
        onInverseSurface: Color(_hexToInt(colors['background']!)),
        inversePrimary: Color(_hexToInt(colors['primary']!)).withOpacity(0.8),
        surfaceTint: Color(_hexToInt(colors['primary']!)),
      ),
      dividerColor: Color(_hexToInt(colors['divider']!)),
      // TODO: apply scanline overlay in your Scaffold or via a global decorator
    );
  }

  // Helper method to get available theme names
  static Future<List<String>> getAvailableThemes() async {
    try {
      final jsonStr =
          await rootBundle.loadString('assets/themes/custom_colors.json');
      final map = jsonDecode(jsonStr) as Map<String, dynamic>;
      return map.keys.toList();
    } catch (e) {
      return ['default'];
    }
  }
}

// Helper to convert "#RRGGBB" → int
int _hexToInt(String hex) => int.parse(hex.replaceFirst('#', '0xFF'));

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

/// Model class for theme configuration
class ThemeConfig {
  final String name;
  final String mode;
  final Color background;
  final Color surface;
  final Color primary;
  final Color onPrimary;
  final Color onSurface;
  final Color divider;
  final Color error;
  final String typography;
  final String effects;
  final String? glitchAccent;
  final String? tertiaryAccent;
  final String? highlightStyle;

  ThemeConfig({
    required this.name,
    required this.mode,
    required this.background,
    required this.surface,
    required this.primary,
    required this.onPrimary,
    required this.onSurface,
    required this.divider,
    required this.error,
    required this.typography,
    required this.effects,
    this.glitchAccent,
    this.tertiaryAccent,
    this.highlightStyle,
  });

  factory ThemeConfig.fromMap(Map<String, dynamic> map) {
    Color parseColor(String hex) {
      hex = hex.replaceFirst('#', '');
      if (hex.length == 6) hex = 'FF$hex';
      return Color(int.parse(hex, radix: 16));
    }

    return ThemeConfig(
      name: map['name'] as String,
      mode: map['mode'] as String,
      background: parseColor(map['background_color'] as String),
      surface: parseColor(map['surface_color'] as String),
      primary: parseColor(map['primary_color'] as String),
      onPrimary: parseColor(map['on_primary_color'] as String),
      onSurface: parseColor(map['on_surface_color'] as String),
      divider: parseColor(map['divider_color'] as String),
      error: parseColor(map['error_color'] as String),
      typography: map['typography'] as String,
      effects: map['effects'] as String,
      glitchAccent: map['glitch_accent'] as String?,
      tertiaryAccent: map['tertiary_accent'] as String?,
      highlightStyle: map['highlight_style'] as String?,
    );
  }
}

/// Service to fetch theme data from Supabase
class ThemeConfigService {
  final SupabaseClient client;

  ThemeConfigService({required this.client});

  /// Fetch theme by name and mode ('light' or 'dark')
  Future<ThemeConfig?> fetchTheme(String name, bool isDarkMode) async {
    try {
      final mode = isDarkMode ? 'dark' : 'light';
      final response = await client
          .from('themes')
          .select(
              'name, mode, background_color, surface_color, primary_color, on_primary_color, on_surface_color, divider_color, error_color, typography, effects, glitch_accent, tertiary_accent, highlight_style')
          .eq('name', name)
          .eq('mode', mode)
          .single();

      return ThemeConfig.fromMap(response);
    } catch (e) {
      debugPrint('Error fetching theme: $e');
      return null;
    }
  }
}

/// Extension to convert ThemeConfig to Flutter's ThemeData
extension ThemeConfigExtension on ThemeConfig {
  ThemeData toThemeData() {
    final brightness = mode == 'dark' ? Brightness.dark : Brightness.light;
    final base = ThemeData(brightness: brightness);

    // Apply typography using Google Fonts
    final textTheme = _applyGoogleFonts(base.textTheme);

    // Build color scheme
    final colorScheme = ColorScheme(
      brightness: brightness,
      primary: primary,
      onPrimary: onPrimary,
      secondary: tertiaryAccent != null ? parseHex(tertiaryAccent!) : surface,
      onSecondary: onPrimary,
      background: background,
      onBackground: onSurface,
      surface: surface,
      onSurface: onSurface,
      error: error,
      onError: parseHex('#FFFFFF'),
    );

    // Apply effects as decorations
    final buttonTheme = base.buttonTheme.copyWith(
      buttonColor: primary,
      textTheme: ButtonTextTheme.primary,
    );

    return base.copyWith(
      colorScheme: colorScheme,
      scaffoldBackgroundColor: background,
      dividerColor: divider,
      textTheme: textTheme,
      buttonTheme: buttonTheme,
      // Additional theming based on effects/glitchAccent/highlightStyle
    );
  }

  /// Apply Google Fonts based on typography field
  TextTheme _applyGoogleFonts(TextTheme baseTextTheme) {
    // Handle composite font strings (e.g., "Orbitron/VT323/Press Start 2P")
    final fontNames = typography.split('/').map((f) => f.trim()).toList();
    final primaryFont = fontNames.first;

    // Map font names to Google Fonts
    final googleFont = _getGoogleFont(primaryFont);

    if (googleFont != null) {
      return baseTextTheme.apply(fontFamily: googleFont.fontFamily);
    }

    // Fallback to system fonts if Google Font not found
    return baseTextTheme.apply(fontFamily: primaryFont);
  }

  /// Get Google Font based on font name
  TextStyle? _getGoogleFont(String fontName) {
    switch (fontName.toLowerCase()) {
      case 'inter':
        return GoogleFonts.inter();
      case 'lora':
        return GoogleFonts.lora();
      case 'source sans pro':
        return GoogleFonts.roboto();
      case 'roboto':
        return GoogleFonts.roboto();
      case 'roboto condensed':
        return GoogleFonts.robotoCondensed();
      case 'merriweather':
        return GoogleFonts.merriweather();
      case 'open sans':
        return GoogleFonts.openSans();
      case 'orbitron':
        return GoogleFonts.orbitron();
      case 'vt323':
        return GoogleFonts.vt323();
      case 'press start 2p':
        return GoogleFonts.pressStart2p();
      default:
        return null;
    }
  }

  Color parseHex(String hex) {
    var cleaned = hex.replaceFirst('#', '');
    if (cleaned.length == 6) cleaned = 'FF$cleaned';
    return Color(int.parse(cleaned, radix: 16));
  }
}

/// Example usage:
/// ```dart
/// final themeService = ThemeConfigService(client: Supabase.instance.client);
/// final config = await themeService.fetchTheme('Prompt', isDarkMode);
/// final themeData = config?.toThemeData();
/// ```

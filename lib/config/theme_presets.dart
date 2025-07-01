import 'package:flutter/material.dart';

/// Definition of a complete color palette for each theme slug.
class AppTheme {
  final Color background;
  final Color text;
  final Color primary;
  final Color secondary;
  final Color highlight;

  const AppTheme({
    required this.background,
    required this.text,
    required this.primary,
    required this.secondary,
    required this.highlight,
  });
}

class ThemePreset {
  final String slug;
  final String name;
  final Color primaryColor;
  final Color secondaryColor;
  final Color accentColor;
  final Color backgroundColor;
  final Color surfaceColor;
  final Color textColor;
  final Color cardColor;
  final Color borderColor;

  const ThemePreset({
    required this.slug,
    required this.name,
    required this.primaryColor,
    required this.secondaryColor,
    required this.accentColor,
    required this.backgroundColor,
    required this.surfaceColor,
    required this.textColor,
    required this.cardColor,
    required this.borderColor,
  });

  ThemeData toLightTheme() {
    return ThemeData.light().copyWith(
      colorScheme: ColorScheme.light(
        primary: primaryColor,
        secondary: secondaryColor,
        surface: surfaceColor,
        error: const Color(0xFFE53935),
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: textColor,
        onError: Colors.white,
      ),
      scaffoldBackgroundColor: backgroundColor,
      cardTheme: CardThemeData(
        elevation: 2,
        color: cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: surfaceColor,
        foregroundColor: textColor,
        elevation: 0,
        centerTitle: true,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: surfaceColor,
        selectedItemColor: primaryColor,
        unselectedItemColor: textColor.withOpacity(0.6),
      ),
    );
  }

  ThemeData toDarkTheme() {
    return ThemeData.dark().copyWith(
      colorScheme: ColorScheme.dark(
        primary: primaryColor,
        secondary: secondaryColor,
        surface: surfaceColor,
        error: const Color(0xFFE53935),
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: textColor,
        onError: Colors.white,
      ),
      scaffoldBackgroundColor: backgroundColor,
      cardTheme: CardThemeData(
        elevation: 2,
        color: cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: surfaceColor,
        foregroundColor: textColor,
        elevation: 0,
        centerTitle: true,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: surfaceColor,
        selectedItemColor: primaryColor,
        unselectedItemColor: textColor.withOpacity(0.6),
      ),
    );
  }
}

// Helper to convert AppTheme to ThemePreset
ThemePreset appThemeToPreset(String slug, String name, AppTheme t) {
  return ThemePreset(
    slug: slug,
    name: name,
    primaryColor: t.primary,
    secondaryColor: t.secondary,
    accentColor: t.highlight,
    backgroundColor: t.background,
    surfaceColor: t.background,
    textColor: t.text,
    cardColor: t.background,
    borderColor: t.secondary,
  );
}

// Provided AppTheme maps
const Map<String, AppTheme> lightThemes = {
  'default': AppTheme(
    background: Color(0xFFFFFFFF),
    text: Color(0xFF23262B),
    primary: Color(0xFFFF9800),
    secondary: Color(0xFFFFC47E),
    highlight: Color(0xFFFFE0B2),
  ),
  'glacier': AppTheme(
    background: Color(0xFFF0F8FF),
    text: Color(0xFF1A1A2E),
    primary: Color(0xFF7B68EE),
    secondary: Color(0xFF9370DB),
    highlight: Color(0xFFE6E6FA),
  ),
  'forge': AppTheme(
    background: Color(0xFFFFF5E6),
    text: Color(0xFF2C1810),
    primary: Color(0xFFFF6B35),
    secondary: Color(0xFFFF8C42),
    highlight: Color(0xFFFFE4B5),
  ),
  'titan': AppTheme(
    background: Color(0xFF1A1A2E),
    text: Color(0xFFE8E8E8),
    primary: Color(0xFF4A90E2),
    secondary: Color(0xFF5B9BD5),
    highlight: Color(0xFFE3F2FD),
  ),
  'granite': AppTheme(
    background: Color(0xFFFFF0F0),
    text: Color(0xFF2C1810),
    primary: Color(0xFFFF6B6B),
    secondary: Color(0xFFFF8E8E),
    highlight: Color(0xFFFFE0E0),
  ),
  'ranger': AppTheme(
    background: Color(0xFFF0FFF0),
    text: Color(0xFF1A2E1A),
    primary: Color(0xFF2E8B57),
    secondary: Color(0xFF3CB371),
    highlight: Color(0xFFE0F8E0),
  ),
};

const Map<String, AppTheme> darkThemes = {
  'default': AppTheme(
    background: Color(0xFF181A20),
    text: Color(0xFFFFFFFF),
    primary: Color(0xFFFF9800),
    secondary: Color(0xFFFFC47E),
    highlight: Color(0xFFFFE0B2),
  ),
  'glacier': AppTheme(
    background: Color(0xFF0A0A1A),
    text: Color(0xFFE8E8FF),
    primary: Color(0xFF7B68EE),
    secondary: Color(0xFF9370DB),
    highlight: Color(0xFF2A2A4A),
  ),
  'forge': AppTheme(
    background: Color(0xFF1A0A0A),
    text: Color(0xFFFFE8D6),
    primary: Color(0xFFFF6B35),
    secondary: Color(0xFFFF8C42),
    highlight: Color(0xFF4A2A1A),
  ),
  'titan': AppTheme(
    background: Color(0xFF000010),
    text: Color(0xFFE8F4FD),
    primary: Color(0xFF4A90E2),
    secondary: Color(0xFF5B9BD5),
    highlight: Color(0xFF1A2A4A),
  ),
  'granite': AppTheme(
    background: Color(0xFF1A0A0A),
    text: Color(0xFFFFE8E8),
    primary: Color(0xFFFF6B6B),
    secondary: Color(0xFFFF8E8E),
    highlight: Color(0xFF4A1A1A),
  ),
  'ranger': AppTheme(
    background: Color(0xFF0A1A0A),
    text: Color(0xFFE8FFE8),
    primary: Color(0xFF2E8B57),
    secondary: Color(0xFF3CB371),
    highlight: Color(0xFF1A4A1A),
  ),
};

// Theme names for display
const Map<String, String> themeNames = {
  'vintage-terminal': 'Vintage Terminal',
  'dark-steel': 'Dark Steel',
  'retro-heat': 'Retro Heat',
  'high-contrast': 'High Contrast',
  'tactical': 'Tactical',
  'road-rash': 'Road Rash',
  'shoplight': 'Shoplight',
  'night-ops': 'Night Ops',
  'bone-white': 'Bone White',
  'panther': 'Panther',
  'iron-frost': 'Iron Frost',
  'harvest-clay': 'Harvest Clay',
  'urban-fog': 'Urban Fog',
  'gold-rush': 'Gold Rush',
  'red-white-blue': 'Red White Blue',
  'cyberpunk': 'Cyberpunk',
  'earth-tone': 'Earth Tone',
  'synthwave': 'Synthwave',
  'marine': 'Marine',
  'forest': 'Forest',
  'glacier': 'Glacier',
  'forge': 'Forge',
  'titan': 'Titan',
  'granite': 'Granite',
  'ranger': 'Ranger',
};

// Utility to compute color distance
int colorDistance(Color a, Color b) {
  return ((a.red - b.red).abs() +
      (a.green - b.green).abs() +
      (a.blue - b.blue).abs());
}

List<ThemePreset> buildThemeList(Map<String, AppTheme> themes, bool isDark) {
  // Build list with all themes, always put 'default' first
  final presets = <ThemePreset>[];
  themes.forEach((slug, t) {
    presets.add(appThemeToPreset(slug, themeNames[slug] ?? slug, t));
  });
  // Sort to put default first
  presets.sort((a, b) {
    if (a.slug == 'default') return -1;
    if (b.slug == 'default') return 1;
    return a.name.compareTo(b.name);
  });
  return presets;
}

final List<ThemePreset> lightThemePresets = buildThemeList(lightThemes, false);
final List<ThemePreset> darkThemePresets = buildThemeList(darkThemes, true);

// Helper function to get theme preset by slug
ThemePreset? getThemePresetBySlug(String slug, bool isDarkMode) {
  final presets = isDarkMode ? darkThemePresets : lightThemePresets;
  try {
    return presets.firstWhere((preset) => preset.slug == slug);
  } catch (e) {
    return presets.first; // Return default if not found
  }
}

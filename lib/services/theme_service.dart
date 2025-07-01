import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/app_theme.dart';
import '../models/theme_config.dart';

class ThemeService extends ChangeNotifier {
  static const String _themeKey = 'theme_mode';
  static const String _themeSlugKey = 'theme_slug';

  final SharedPreferences _prefs;
  ThemeMode? _themeMode;
  String _themeSlug = 'default';

  // Supabase theme list
  List<AppTheme> availableThemes = [];

  // Enhanced theme config
  ThemeConfig? _currentThemeConfig;

  // Current AppTheme for immediate access
  AppTheme? _currentAppTheme;

  // Theme config service
  late final ThemeConfigService _themeConfigService;

  ThemeService(this._prefs) {
    _themeConfigService = ThemeConfigService(client: Supabase.instance.client);
    _loadThemeFromPrefs();
  }

  ThemeMode? get themeMode => _themeMode;
  String get themeSlug => _themeSlug;
  ThemeConfig? get currentThemeConfig => _currentThemeConfig;

  Future<List<AppTheme>> fetchThemesFromDb() async {
    final supabase = Supabase.instance.client;
    final data = await supabase.from('themes').select();
    if (data == null || data is! List) {
      return [];
    }
    availableThemes = data.map((e) => AppTheme.fromMap(e)).toList();
    notifyListeners();
    return availableThemes;
  }

  /// Fetch themes filtered by mode (light/dark)
  Future<List<AppTheme>> fetchThemesByMode(String mode) async {
    final supabase = Supabase.instance.client;
    final data = await supabase.from('themes').select().eq('mode', mode);

    if (data == null || data is! List) {
      return [];
    }

    List<AppTheme> themes = data.map((e) => AppTheme.fromMap(e)).toList();

    // SIMPLE APPROACH: Find crossbeam and put it first
    AppTheme? crossbeamTheme;
    List<AppTheme> otherThemes = [];

    for (final theme in themes) {
      if (theme.name.toLowerCase() == 'crossbeam') {
        crossbeamTheme = theme;
      } else {
        otherThemes.add(theme);
      }
    }

    // Sort other themes alphabetically
    otherThemes.sort((a, b) => a.name.compareTo(b.name));

    // Put Crossbeam first, then others
    List<AppTheme> result = [];
    if (crossbeamTheme != null) {
      result.add(crossbeamTheme);
    }
    result.addAll(otherThemes);

    return result;
  }

  /// Get themes for current mode
  List<AppTheme> getThemesForCurrentMode() {
    final currentMode = isDarkMode ? 'dark' : 'light';
    return availableThemes.where((theme) => theme.mode == currentMode).toList();
  }

  /// Fetch enhanced theme configuration with typography and effects
  Future<ThemeConfig?> fetchEnhancedTheme(String name, bool isDarkMode) async {
    try {
      final config = await _themeConfigService.fetchTheme(name, isDarkMode);
      _currentThemeConfig = config;
      notifyListeners();
      return config;
    } catch (e) {
      return null;
    }
  }

  Future<void> _loadThemeFromPrefs() async {
    _themeSlug = 'crossbeam'; // Always default to crossbeam
    _themeMode = ThemeMode.light; // Always default to light mode

    // Try to load Crossbeam from database to set as current theme
    try {
      final supabase = Supabase.instance.client;
      final data = await supabase
          .from('themes')
          .select()
          .eq('name', 'crossbeam')
          .eq('mode', 'light')
          .limit(1);
      if (data != null && data is List && data.isNotEmpty) {
        final crossbeamTheme = AppTheme.fromMap(data.first);
        _currentAppTheme = crossbeamTheme;
      }
    } catch (e) {
      // Continue without Crossbeam
    }
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    _themeMode =
        _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    await _prefs.setString(_themeKey, _themeMode.toString());
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    await _prefs.setString(_themeKey, mode.toString());

    // SIMPLE: Always go to crossbeam for the new mode
    final newMode = mode == ThemeMode.dark ? 'dark' : 'light';

    try {
      final supabase = Supabase.instance.client;
      final data = await supabase
          .from('themes')
          .select()
          .eq('name', 'crossbeam')
          .eq('mode', newMode)
          .limit(1);
      if (data != null && data is List && data.isNotEmpty) {
        final crossbeamTheme = AppTheme.fromMap(data.first);
        _currentAppTheme = crossbeamTheme;
        _themeSlug = 'crossbeam';
        notifyListeners();
        return;
      }
    } catch (e) {
      print('Error fetching crossbeam theme: $e');
    }

    notifyListeners();
  }

  Future<void> setThemeSlug(String slug) async {
    _themeSlug = slug;
    await _prefs.setString(_themeSlugKey, slug);
    // Fetch enhanced theme config when theme changes
    await fetchEnhancedTheme(slug, isDarkMode);
    notifyListeners();
  }

  // New: set current theme by AppTheme
  void setCurrentTheme(AppTheme theme) {
    _themeSlug = theme.name;
    // Fetch enhanced theme config
    fetchEnhancedTheme(theme.name, isDarkMode);
    notifyListeners();
  }

  /// Set theme and mode together for immediate application
  Future<void> setThemeAndMode(AppTheme theme, bool isDark) async {
    _themeSlug = theme.name;
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;

    // Store the current theme directly for immediate use
    _currentAppTheme = theme;

    // Save to preferences
    await _prefs.setString(_themeSlugKey, theme.name);
    await _prefs.setString(_themeKey, _themeMode.toString());

    // Try to fetch enhanced theme config, but don't fail if it doesn't work
    try {
      await fetchEnhancedTheme(theme.name, isDark);
    } catch (e) {}

    // Notify listeners to trigger rebuild
    notifyListeners();
  }

  bool get isDarkMode {
    if (_themeMode == ThemeMode.system) {
      // Use system brightness
      final brightness =
          WidgetsBinding.instance.platformDispatcher.platformBrightness;
      return brightness == Brightness.dark;
    }
    return _themeMode == ThemeMode.dark;
  }

  AppTheme? get currentAppTheme {
    // Return stored theme if available
    if (_currentAppTheme != null) {
      return _currentAppTheme;
    }

    // Fallback to finding theme in available themes
    if (availableThemes.isEmpty) return null;

    // First try to find the current theme slug
    try {
      final currentTheme = availableThemes.firstWhere(
        (theme) => theme.name == _themeSlug,
      );
      return currentTheme;
    } catch (e) {
      // Theme not found, continue to fallback
    }

    // If not found, prioritize crossbeam, then fallback to first
    try {
      final crossbeamTheme = availableThemes.firstWhere(
        (theme) => theme.name == 'crossbeam',
      );
      return crossbeamTheme;
    } catch (e) {
      // Crossbeam not found, fallback to first
    }

    return availableThemes.first;
  }

  /// Get enhanced theme data with typography and effects
  ThemeData get currentLightTheme {
    // Use enhanced theme config if available
    if (_currentThemeConfig != null && _currentThemeConfig!.mode == 'light') {
      return _currentThemeConfig!.toThemeData();
    }

    // Fallback to existing AppTheme
    final theme = currentAppTheme;
    if (theme == null) return ThemeData.light();

    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.light(
        background: theme.background,
        surface: theme.surface,
        primary: theme.primary,
        onPrimary: theme.onPrimary,
        onSurface: theme.onSurface,
        outline: theme.divider,
        error: theme.error,
      ),
    );
  }

  ThemeData get currentDarkTheme {
    // Use enhanced theme config if available
    if (_currentThemeConfig != null && _currentThemeConfig!.mode == 'dark') {
      return _currentThemeConfig!.toThemeData();
    }

    // Fallback to existing AppTheme
    final theme = currentAppTheme;
    if (theme == null) return ThemeData.dark();

    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.dark(
        background: theme.background,
        surface: theme.surface,
        primary: theme.primary,
        onPrimary: theme.onPrimary,
        onSurface: theme.onSurface,
        outline: theme.divider,
        error: theme.error,
      ),
    );
  }

  /// Apply effects to widgets based on current theme
  Widget applyEffects(Widget child, {String? effectOverride}) {
    final effect = effectOverride ?? _currentThemeConfig?.effects ?? 'flat';

    switch (effect) {
      case 'neon-glow':
        return _applyNeonGlow(child);
      case 'scanline':
        return _applyScanline(child);
      case 'flat':
      default:
        return child;
    }
  }

  Widget _applyNeonGlow(Widget child) {
    final primaryColor = _currentThemeConfig?.primary ?? Colors.blue;
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.3),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _applyScanline(Widget child) {
    return Stack(
      children: [
        child,
        // Add scanline overlay effect
        Positioned.fill(
          child: CustomPaint(
            painter: ScanlinePainter(),
          ),
        ),
      ],
    );
  }
}

/// Custom painter for scanline effect
class ScanlinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withOpacity(0.1)
      ..strokeWidth = 1;

    // Draw horizontal scanlines
    for (double y = 0; y < size.height; y += 4) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

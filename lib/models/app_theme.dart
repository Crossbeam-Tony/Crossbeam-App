import 'package:flutter/material.dart';

class AppTheme {
  final String id;
  final String name;
  final String mode;
  final Color background;
  final Color surface;
  final Color primary;
  final Color onPrimary;
  final Color onSurface;
  final Color divider;
  final Color error;

  AppTheme({
    required this.id,
    required this.name,
    required this.mode,
    required this.background,
    required this.surface,
    required this.primary,
    required this.onPrimary,
    required this.onSurface,
    required this.divider,
    required this.error,
  });

  factory AppTheme.fromMap(Map<String, dynamic> m) {
    Color parse(String? hex) {
      if (hex == null) return Colors.transparent;
      hex = hex.replaceAll('#', '');
      if (hex.length == 6) hex = 'FF$hex';
      return Color(int.parse(hex, radix: 16));
    }

    return AppTheme(
      id: m['id']?.toString() ?? '',
      name: m['name'] ?? '',
      mode: m['mode'] ?? 'light',
      background: parse(m['background_color'] ?? m['background']),
      surface: parse(m['surface_color'] ?? m['surface']),
      primary: parse(m['primary_color'] ?? m['primary']),
      onPrimary: parse(m['on_primary_color'] ?? m['onPrimary']),
      onSurface: parse(m['on_surface_color'] ?? m['onSurface']),
      divider: parse(m['divider_color'] ?? m['divider']),
      error: parse(m['error_color'] ?? m['error']),
    );
  }
}

import 'package:flutter/material.dart';

extension ColorExtension on Color {
  Color withValues({
    double? red,
    double? green,
    double? blue,
    double? alpha,
  }) {
    return Color.fromARGB(
      ((alpha ?? (a / 255.0)) * 255.0).round() & 0xff,
      ((red ?? (r / 255.0)) * 255.0).round() & 0xff,
      ((green ?? (g / 255.0)) * 255.0).round() & 0xff,
      ((blue ?? (b / 255.0)) * 255.0).round() & 0xff,
    );
  }

  Color withAlpha(double alpha) {
    return Color.fromARGB(
      (alpha * 255.0).round() & 0xff,
      r.round() & 0xff,
      g.round() & 0xff,
      b.round() & 0xff,
    );
  }
}

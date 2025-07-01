import 'package:flutter/material.dart';
import 'dart:math';

class HexagonClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final w = size.width;
    final radius = w / 2;
    final center = Offset(radius, radius);
    final path = Path();
    const angle = 2 * pi / 6;

    // Start at 0° (pointy-top) and go clockwise
    for (int i = 0; i < 6; i++) {
      final x = center.dx + radius * cos(angle * i);
      final y = center.dy + radius * sin(angle * i);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class HexCell extends StatelessWidget {
  final Color color;
  final double size;
  const HexCell({super.key, required this.color, this.size = 40});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: HexCellPainter(
          color: color,
          borderColor: Colors.black.withOpacity(0.3),
          borderWidth: 4,
        ),
      ),
    );
  }
}

class HexCellPainter extends CustomPainter {
  final Color color;
  final Color borderColor;
  final double borderWidth;

  HexCellPainter({
    required this.color,
    required this.borderColor,
    this.borderWidth = 4,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path();
    final double w = size.width, h = size.height;
    final double r = w / 2 - borderWidth;

    // Create a flat-top hexagon (rotated 30 degrees from pointy-top)
    for (int i = 0; i < 6; i++) {
      final angle = (i * 60) * pi / 180; // Start at 0 degrees for flat-top
      final x = w / 2 + r * cos(angle);
      final y = h / 2 + r * sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();

    // Fill the hexagon
    final fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, fillPaint);

    // Draw the border
    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth;
    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class MiniHoneycomb extends StatelessWidget {
  final Color background;
  final Color surface;
  final Color primary;
  final Color onPrimary;
  final Color text;
  final Color border;
  final Color error;
  final double cellSize;
  final bool isDarkMode;

  const MiniHoneycomb({
    super.key,
    required this.background,
    required this.surface,
    required this.primary,
    required this.onPrimary,
    required this.text,
    required this.border,
    required this.error,
    this.cellSize = 40,
    this.isDarkMode = false,
  });

  double _luminance(Color c) => c.computeLuminance();

  @override
  Widget build(BuildContext context) {
    // Always put background in center
    final centerColor = background;

    // Collect remaining colors for perimeter
    final remainingColors = [surface, primary, onPrimary, text, border, error];

    // Sort remaining colors by luminance (light to dark for perimeter)
    remainingColors.sort((a, b) => _luminance(b).compareTo(_luminance(a)));

    // Ensure we have exactly 6 colors for perimeter
    while (remainingColors.length < 6) {
      remainingColors.add(Colors.grey); // Fallback if any color is missing
    }

    // Take the first 6 colors for perimeter (lightest to darkest)
    final perimeterColors = remainingColors.take(6).toList();

    // Compute neighbor distance
    final R = cellSize / 2;
    final neighborDist = R * sqrt(3);

    return SizedBox(
      width: cellSize * 3,
      height: cellSize * 3,
      child: Stack(
        children: [
          // Center
          Positioned(
            left: cellSize,
            top: cellSize,
            child: HexCell(color: centerColor, size: cellSize),
          ),
          // Perimeter hexes at 60° increments, starting from 12 o'clock
          for (var i = 0; i < 6; i++)
            Positioned(
              left: cellSize + neighborDist * cos(pi / 2 - (pi / 3) * i),
              top: cellSize - neighborDist * sin(pi / 2 - (pi / 3) * i),
              child: HexCell(
                  color: perimeterColors[i % perimeterColors.length],
                  size: cellSize),
            ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'dart:math';

/// A custom painter widget for a hexagon selector icon:
/// - `size`: width & height of the outer hexagon
/// - `outerColor`: fill color of the large hex
/// - `innerColors`: exactly 3 colors for the smaller hex shapes (top, bottom-left, bottom-right)
/// - `borderColor`: optional border color
/// - `borderWidth`: optional border thickness
class HexSelectorIcon extends StatelessWidget {
  final double size;
  final Color outerColor;
  final List<Color> innerColors;
  final Color? borderColor;
  final double borderWidth;
  final VoidCallback? onTap;

  const HexSelectorIcon({
    Key? key,
    this.size = 72,
    required this.outerColor,
    required this.innerColors,
    this.borderColor,
    this.borderWidth = 2,
    this.onTap,
  })  : assert(innerColors.length == 3, 'Provide exactly 3 inner colors'),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: CustomPaint(
        size: Size(size, size),
        painter: _HexSelectorPainter(
          outerColor: outerColor,
          innerColors: innerColors,
          borderColor: borderColor,
          borderWidth: borderWidth,
        ),
      ),
    );
  }
}

class _HexSelectorPainter extends CustomPainter {
  final Color outerColor;
  final List<Color> innerColors;
  final Color? borderColor;
  final double borderWidth;

  _HexSelectorPainter({
    required this.outerColor,
    required this.innerColors,
    this.borderColor,
    this.borderWidth = 2,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;
    final double r = w / 2;
    final center = Offset(w / 2, h / 2);

    // Draw outer hexagon
    final outerPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = outerColor;
    final path = Path();
    for (int i = 0; i < 6; i++) {
      final angle = pi / 3 * i - pi / 6;
      final x = center.dx + r * cos(angle);
      final y = center.dy + r * sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, outerPaint);

    // Draw optional border
    if (borderColor != null && borderWidth > 0) {
      final borderPaint = Paint()
        ..style = PaintingStyle.stroke
        ..color = borderColor!
        ..strokeWidth = borderWidth;
      canvas.drawPath(path, borderPaint);
    }

    // Inner hex size = smaller to prevent overlap
    final double innerR = r * 0.35;
    final double topY = center.dy - innerR * 0.8;
    final points = [
      Offset(center.dx, topY), // top
      Offset(center.dx - innerR * 0.8, center.dy + innerR * 0.4), // bottom-left
      Offset(
          center.dx + innerR * 0.8, center.dy + innerR * 0.4), // bottom-right
    ];

    // Draw inner hexes
    for (int i = 0; i < 3; i++) {
      final paint = Paint()
        ..style = PaintingStyle.fill
        ..color = innerColors[i];
      final hexPath = Path();
      for (int j = 0; j < 6; j++) {
        final angle = pi / 3 * j - pi / 6;
        final x = points[i].dx + innerR * cos(angle);
        final y = points[i].dy + innerR * sin(angle);
        if (j == 0) {
          hexPath.moveTo(x, y);
        } else {
          hexPath.lineTo(x, y);
        }
      }
      hexPath.close();
      canvas.drawPath(hexPath, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    if (oldDelegate is! _HexSelectorPainter) return true;
    return outerColor != oldDelegate.outerColor ||
        innerColors != oldDelegate.innerColors ||
        borderColor != oldDelegate.borderColor ||
        borderWidth != oldDelegate.borderWidth;
  }
}

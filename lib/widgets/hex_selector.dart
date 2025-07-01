import 'package:flutter/material.dart';
import 'dart:math' as math;

class HexSelector extends StatelessWidget {
  final Color outerColor;
  final Color borderColor;
  final List<Color> innerColors;
  final VoidCallback? onTap;
  final double size;
  final bool isSelected;
  final String? label;
  final IconData? icon;

  const HexSelector({
    Key? key,
    required this.outerColor,
    required this.borderColor,
    required this.innerColors,
    this.onTap,
    this.size = 80.0,
    this.isSelected = false,
    this.label,
    this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        transform:
            isSelected ? (Matrix4.identity()..scale(1.1)) : Matrix4.identity(),
        child: CustomPaint(
          size: Size(size, size),
          painter: HexPainter(
            outerColor: outerColor,
            borderColor: borderColor,
            innerColors: innerColors,
            isSelected: isSelected,
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null)
                  Icon(
                    icon,
                    color: borderColor,
                    size: size * 0.3,
                  ),
                if (label != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    label!,
                    style: TextStyle(
                      color: borderColor,
                      fontSize: size * 0.12,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class HexPainter extends CustomPainter {
  final Color outerColor;
  final Color borderColor;
  final List<Color> innerColors;
  final bool isSelected;

  HexPainter({
    required this.outerColor,
    required this.borderColor,
    required this.innerColors,
    required this.isSelected,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Draw outer hexagon
    _drawHexagon(canvas, center, radius, outerColor, borderColor, 2.0);

    // Draw inner hexagons
    final innerRadius = radius * 0.7;
    final innerCenter = center;

    // Inner hexagon 1 (primary)
    if (innerColors.isNotEmpty) {
      _drawHexagon(canvas, innerCenter, innerRadius * 0.8, innerColors[0],
          Colors.transparent, 0);
    }

    // Inner hexagon 2 (accent)
    if (innerColors.length > 1) {
      final offset2 = Offset(
        innerCenter.dx + innerRadius * 0.3,
        innerCenter.dy - innerRadius * 0.2,
      );
      _drawHexagon(canvas, offset2, innerRadius * 0.4, innerColors[1],
          Colors.transparent, 0);
    }

    // Inner hexagon 3 (highlight)
    if (innerColors.length > 2) {
      final offset3 = Offset(
        innerCenter.dx - innerRadius * 0.3,
        innerCenter.dy - innerRadius * 0.2,
      );
      _drawHexagon(canvas, offset3, innerRadius * 0.4, innerColors[2],
          Colors.transparent, 0);
    }

    // Selection glow effect
    if (isSelected) {
      final glowPaint = Paint()
        ..color = borderColor.withOpacity(0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4.0
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8.0);

      _drawHexagon(canvas, center, radius + 4, Colors.transparent,
          Colors.transparent, 0, glowPaint);
    }
  }

  void _drawHexagon(
    Canvas canvas,
    Offset center,
    double radius,
    Color fillColor,
    Color strokeColor,
    double strokeWidth, [
    Paint? customPaint,
  ]) {
    final paint = customPaint ?? Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill;

    final strokePaint = Paint()
      ..color = strokeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    final path = Path();
    for (int i = 0; i < 6; i++) {
      final angle = i * math.pi / 3;
      final x = center.dx + radius * math.cos(angle);
      final y = center.dy + radius * math.sin(angle);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();

    canvas.drawPath(path, paint);
    if (strokeWidth > 0) {
      canvas.drawPath(path, strokePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

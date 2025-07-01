import 'package:flutter/material.dart';
import 'dart:math' as math;

class HexProgressIndicator extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final Color accentColor;
  final Color mutedColor;
  final double size;
  final void Function(int)? onStepTapped;

  const HexProgressIndicator({
    Key? key,
    required this.currentStep,
    this.totalSteps = 6,
    required this.accentColor,
    required this.mutedColor,
    this.size = 100,
    this.onStepTapped,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final hexes = <Widget>[];
    for (int i = 0; i < totalSteps; i++) {
      if (i >= currentStep) break;
      hexes.add(GestureDetector(
        onTap: onStepTapped != null ? () => onStepTapped!(i) : null,
        child: Container(
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
            borderRadius: BorderRadius.circular(8),
            color: i == currentStep - 1 ? accentColor : mutedColor,
          ),
          width: size / 3,
          height: size / 3,
          child: Center(
            child: Text(
              '${i + 1}',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: size / 6,
              ),
            ),
          ),
        ),
      ));
    }
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.10),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: hexes,
      ),
    );
  }
}

class HexProgressPainter extends CustomPainter {
  final int currentStep;
  final Color accentColor;
  final Color mutedColor;
  final double animationValue;

  HexProgressPainter({
    required this.currentStep,
    required this.accentColor,
    required this.mutedColor,
    required this.animationValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 3;
    const int totalSteps = 6;

    for (int i = 0; i < totalSteps; i++) {
      final angle =
          i * 2 * math.pi / totalSteps - math.pi / 2; // Start from top
      final hexCenter = Offset(
        center.dx + radius * math.cos(angle),
        center.dy + radius * math.sin(angle),
      );

      final isCompleted = i < currentStep;
      final isCurrent = i == currentStep - 1;

      Color fillColor;
      Color strokeColor;
      double strokeWidth;

      if (isCompleted) {
        fillColor = accentColor;
        strokeColor = accentColor;
        strokeWidth = 2.0;
      } else if (isCurrent) {
        // Animated current step
        final animatedColor =
            Color.lerp(mutedColor, accentColor, animationValue)!;
        fillColor = animatedColor;
        strokeColor = animatedColor;
        strokeWidth = 2.0;
      } else {
        fillColor = Colors.transparent;
        strokeColor = mutedColor;
        strokeWidth = 1.0;
      }

      _drawHexagon(
          canvas, hexCenter, 20.0, fillColor, strokeColor, strokeWidth);

      // Add step number
      final textPainter = TextPainter(
        text: TextSpan(
          text: '${i + 1}',
          style: TextStyle(
            color: isCompleted || isCurrent ? Colors.white : mutedColor,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          hexCenter.dx - textPainter.width / 2,
          hexCenter.dy - textPainter.height / 2,
        ),
      );
    }

    // Draw connecting lines
    final path = Path();
    bool first = true;

    for (int i = 0; i < totalSteps; i++) {
      final angle = i * 2 * math.pi / totalSteps - math.pi / 2;
      final point = Offset(
        center.dx + radius * math.cos(angle),
        center.dy + radius * math.sin(angle),
      );

      if (first) {
        path.moveTo(point.dx, point.dy);
        first = false;
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    path.close();

    final linePaint = Paint()
      ..color = mutedColor.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    canvas.drawPath(path, linePaint);
  }

  void _drawHexagon(
    Canvas canvas,
    Offset center,
    double radius,
    Color fillColor,
    Color strokeColor,
    double strokeWidth,
  ) {
    final paint = Paint()
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
    canvas.drawPath(path, strokePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

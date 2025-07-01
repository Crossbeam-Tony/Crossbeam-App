import 'package:flutter/material.dart';
import 'dart:math';

/// HoneycombGrid arranges icons into a visually offset hexagonal layout.
/// Each row is a Row widget, and every odd-numbered row is offset horizontally
/// using a left padding to simulate the staggered honeycomb layout.
class HoneycombGrid<T> extends StatelessWidget {
  final List<T> items;
  final Widget Function(BuildContext, T, int) itemBuilder;
  final List<int> rowPattern; // e.g., [3,2,3,2,3,2,3,2]
  final double hexSize;
  final double spacing;
  final double? boxHeight;
  final double? verticalOffset; // New: allows nudging the box up

  const HoneycombGrid({
    Key? key,
    required this.items,
    required this.itemBuilder,
    required this.rowPattern,
    this.hexSize = 70.0,
    this.spacing = 12.0,
    this.boxHeight,
    this.verticalOffset,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double hexWidth = hexSize;
        final double hexHeight = hexSize * sqrt(3) / 2;
        double spacing = this.spacing;

        // Calculate the base grid dimensions
        double maxWidth = 0;
        for (int row = 0; row < rowPattern.length; row++) {
          final int cols = rowPattern[row];
          final double rowWidth = (cols - 1) * (hexWidth + spacing) + hexWidth;
          maxWidth = max(maxWidth, rowWidth);
        }

        // Use the full available space from parent
        final double boxWidth = constraints.maxWidth;
        final double boxHeight = constraints.maxHeight;
        final int rowCount = rowPattern.length;

        // Remove topPadding and center grid vertically
        final double totalGridHeight = rowCount > 1
            ? rowCount * hexHeight + (rowCount - 1) * spacing
            : hexHeight;
        final double verticalOffset = (boxHeight - totalGridHeight) / 2;

        return SizedBox(
          width: boxWidth,
          height: boxHeight,
          child: Stack(
            children: [
              // Removed bisecting lines
              for (int row = 0, index = 0; row < rowPattern.length; row++)
                ...() {
                  final int cols = rowPattern[row];
                  final double rowWidth =
                      (cols - 1) * (hexWidth + spacing) + hexWidth;
                  final double leftOffset = (boxWidth - rowWidth) / 2;
                  final double dy =
                      verticalOffset + row * (hexHeight + spacing);
                  return [
                    for (int col = 0;
                        col < cols && index < items.length;
                        col++, index++)
                      Positioned(
                        left: leftOffset + col * (hexWidth + spacing),
                        top: dy,
                        child: itemBuilder(context, items[index], index),
                      ),
                  ];
                }(),
            ],
          ),
        );
      },
    );
  }
}

/// HexIcon renders any child widget inside a hexagonal frame using ClipPath.
class HexIcon extends StatelessWidget {
  final Widget child;

  const HexIcon({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: HexagonClipper(),
      child: Container(
        margin: const EdgeInsets.all(4),
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: Colors.blueAccent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(child: child),
      ),
    );
  }
}

/// HexagonClipper defines a 6-sided polygon using CustomClipper.
/// It is used to clip any container into a perfect hexagon.
class HexagonClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    double w = size.width;
    double h = size.height;
    double side = w / 2;
    double r = side / cos(pi / 6);
    double centerY = h / 2;

    final path = Path();
    for (int i = 0; i < 6; i++) {
      double angle = pi / 3 * i;
      double x = w / 2 + r * cos(angle);
      double y = centerY + r * sin(angle);
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

// Add a painter for bisecting lines
class _BisectingLinesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 2;
    // Vertical center line
    canvas.drawLine(
        Offset(size.width / 2, 0), Offset(size.width / 2, size.height), paint);
    // Horizontal center line
    canvas.drawLine(
        Offset(0, size.height / 2), Offset(size.width, size.height / 2), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

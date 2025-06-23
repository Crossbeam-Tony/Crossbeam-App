import 'package:flutter/material.dart';

class SlidingCard extends StatefulWidget {
  final Widget Function(double slideProgress) topLayer;
  final Widget? bottomLayer;
  final Widget Function(double slideProgress)? leftBottomLayer;
  final Widget Function(double slideProgress)? rightBottomLayer;
  final double maxSwipeOffset;
  final bool canSlideLeft;
  final bool canSlideRight;
  final VoidCallback? onTap;
  final VoidCallback? onSlideLeft;
  final VoidCallback? onSlideRight;
  final VoidCallback? onCardOpen;
  final VoidCallback? onCardClose;
  final double height;
  final double borderRadius;
  final Color backgroundColor;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;

  const SlidingCard({
    super.key,
    required this.topLayer,
    this.bottomLayer,
    this.leftBottomLayer,
    this.rightBottomLayer,
    this.maxSwipeOffset = 0.3,
    this.canSlideLeft = true,
    this.canSlideRight = true,
    this.onTap,
    this.onSlideLeft,
    this.onSlideRight,
    this.onCardOpen,
    this.onCardClose,
    this.height = 500.0,
    this.borderRadius = 4.0,
    this.backgroundColor = Colors.white,
    this.margin,
    this.padding,
  });

  @override
  State<SlidingCard> createState() => _SlidingCardState();
}

class _SlidingCardState extends State<SlidingCard> {
  int _slideDirection = 0; // -1 for left, 0 for center, 1 for right
  double _cardWidth = 0.0;
  double _dragStartX = 0.0;
  double _currentOffset = 0.0;
  bool _isDragging = false;

  void _handleDragStart(DragStartDetails details) {
    print('Drag start: ${details.globalPosition.dx}');
    _dragStartX = details.globalPosition.dx;
    _isDragging = true;
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    if (!_isDragging) return;

    final maxDrag = _cardWidth * 0.85;

    // Set direction on first drag
    if (_slideDirection == 0) {
      if (details.delta.dx < 0 && widget.canSlideLeft) {
        setState(() => _slideDirection = -1);
      } else if (details.delta.dx > 0 && widget.canSlideRight) {
        setState(() => _slideDirection = 1);
      }
    }

    if (_slideDirection != 0) {
      // Update offset directly
      setState(() {
        _currentOffset += details.delta.dx;
        _currentOffset = _currentOffset.clamp(-maxDrag, maxDrag);
      });
    }
  }

  void _handleDragEnd(DragEndDetails details) {
    _isDragging = false;

    final maxDrag = _cardWidth * 0.85;

    // Complete or reset based on position
    if (_currentOffset.abs() > maxDrag * 0.3) {
      // Complete the slide
      setState(() {
        _currentOffset = _slideDirection > 0 ? maxDrag : -maxDrag;
      });
      widget.onCardOpen?.call();
    } else {
      // Reset to center
      setState(() {
        _currentOffset = 0.0;
        _slideDirection = 0;
      });
      widget.onCardClose?.call();
    }
  }

  void _handleTap() {
    if (_slideDirection != 0) {
      // Close the card
      setState(() {
        _currentOffset = 0.0;
        _slideDirection = 0;
      });
      widget.onCardClose?.call();
    } else {
      widget.onTap?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        _cardWidth = constraints.maxWidth;
        // Provide a default height when none is specified to ensure Stack has finite size
        final cardHeight =
            constraints.maxHeight.isFinite ? constraints.maxHeight : 450.0;

        final slideProgress = _currentOffset.abs() / (_cardWidth * 0.85);

        return SizedBox(
          width: _cardWidth,
          height: cardHeight,
          child: Stack(
            children: [
              // Right bottom layer (action buttons)
              if (widget.rightBottomLayer != null && _slideDirection >= 0)
                Positioned(
                  right: 0,
                  top: 0,
                  width: _cardWidth,
                  height: cardHeight,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(4),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: widget.rightBottomLayer!(slideProgress),
                    ),
                  ),
                ),

              // Left bottom layer
              if (widget.leftBottomLayer != null && _slideDirection <= 0)
                Positioned(
                  left: 0,
                  top: 0,
                  width: _cardWidth,
                  height: cardHeight,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(4),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: widget.leftBottomLayer!(slideProgress),
                    ),
                  ),
                ),

              // Top card - slides to reveal bottom layer
              AnimatedPositioned(
                duration: const Duration(milliseconds: 200),
                left: _slideDirection >= 0 ? _currentOffset : null,
                right: _slideDirection < 0 ? -_currentOffset : null,
                top: 0,
                height: cardHeight,
                child: GestureDetector(
                  onTap: _handleTap,
                  onHorizontalDragStart: _handleDragStart,
                  onHorizontalDragUpdate: _handleDragUpdate,
                  onHorizontalDragEnd: _handleDragEnd,
                  behavior: HitTestBehavior.translucent,
                  child: Container(
                    width: _cardWidth,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: SizedBox(
                        width: _cardWidth,
                        height: cardHeight,
                        child: widget.topLayer(slideProgress),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _OutlinePainter extends CustomPainter {
  final double progress;
  final double direction;

  _OutlinePainter({
    required this.progress,
    required this.direction,
  });

  @override
  void paint(Canvas canvas, Size size) {
    try {
      if (progress == 0.0 || size.width <= 0 || size.height <= 0) return;

      final paint = Paint()
        ..color = Colors.purple
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;

      final gradient = LinearGradient(
        colors: [
          Colors.purple.withOpacity(0.8),
          Colors.purple.withOpacity(0.4),
          Colors.purple.withOpacity(0.1),
        ],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        stops: const [0.0, 0.5, 1.0],
      );

      paint.shader =
          gradient.createShader(Rect.fromLTWH(0, 0, size.width, size.height));

      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        const Radius.circular(4),
      );

      canvas.drawRRect(rect, paint);
    } catch (e) {
      debugPrint('Error painting outline: $e');
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

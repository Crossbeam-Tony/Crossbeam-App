import 'package:flutter/material.dart';
import 'dart:math' as math;

/// A hexagon-shaped toggle switch with customizable colors and sizes.
class HexToggle extends StatefulWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final Color? activeColor;
  final Color? inactiveColor;
  final Color? activeTrackColor;
  final Color? inactiveTrackColor;
  final double width;
  final double height;

  const HexToggle({
    super.key,
    required this.value,
    required this.onChanged,
    this.activeColor,
    this.inactiveColor,
    this.activeTrackColor,
    this.inactiveTrackColor,
    this.width = 60,
    this.height = 32,
  });

  @override
  State<HexToggle> createState() => _HexToggleState();
}

class _HexToggleState extends State<HexToggle>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    if (widget.value) {
      _controller.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(HexToggle oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) {
      if (widget.value) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final activeColor = widget.activeColor ?? theme.colorScheme.primary;
    final inactiveColor = widget.inactiveColor ?? theme.colorScheme.surface;
    final activeTrackColor =
        widget.activeTrackColor ?? activeColor.withOpacity(0.3);
    final inactiveTrackColor =
        widget.inactiveTrackColor ?? theme.colorScheme.outline.withOpacity(0.3);

    return GestureDetector(
      onTap: () {
        widget.onChanged(!widget.value);
      },
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return SizedBox(
            width: widget.width,
            height: widget.height,
            child: Stack(
              children: [
                // Hexagon track
                ClipPath(
                  clipper: HexagonClipper(),
                  child: Container(
                    width: widget.width,
                    height: widget.height,
                    decoration: BoxDecoration(
                      color: Color.lerp(inactiveTrackColor, activeTrackColor,
                          _animation.value),
                      border: Border.all(
                        color: inactiveTrackColor.withOpacity(0.8),
                        width: 2.0,
                      ),
                    ),
                  ),
                ),
                // Filled hexagon knob that slides
                Positioned(
                  left: _animation.value * (widget.width - widget.height),
                  top: 0,
                  child: SizedBox(
                    width: widget.height,
                    height: widget.height,
                    child: Stack(
                      children: [
                        // Filled hexagon knob
                        ClipPath(
                          clipper: HexagonClipper(),
                          child: Container(
                            width: widget.height,
                            height: widget.height,
                            decoration: BoxDecoration(
                              color: widget.value ? activeColor : inactiveColor,
                              border: Border.all(
                                color: widget.value
                                    ? activeColor.withOpacity(0.8)
                                    : theme.colorScheme.outline
                                        .withOpacity(0.6),
                                width: 2.0,
                              ),
                            ),
                          ),
                        ),
                        // Light/Dark icon
                        Center(
                          child: Icon(
                            widget.value ? Icons.dark_mode : Icons.light_mode,
                            size: widget.height * 0.4,
                            color: widget.value ? Colors.white : Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Legacy HexToggle for backward compatibility
class HexToggleLegacy extends StatefulWidget {
  final String label;
  final bool selected;
  final void Function()? onTap;
  final double size;

  const HexToggleLegacy({
    super.key,
    required this.label,
    this.selected = false,
    this.onTap,
    this.size = 72.0,
  });

  @override
  State<HexToggleLegacy> createState() => _HexToggleLegacyState();
}

class _HexToggleLegacyState extends State<HexToggleLegacy> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: ClipPath(
        clipper: HexagonClipper(),
        child: Container(
          width: widget.size,
          height: widget.size,
          margin: const EdgeInsets.all(1),
          decoration: BoxDecoration(
            color: widget.selected
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.surface,
            border: Border.all(
              color: widget.selected
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.outline,
            ),
          ),
          child: Center(
            child: ClipPath(
              clipper: HexagonClipper(),
              child: Container(
                width: widget.size * 0.4,
                height: widget.size * 0.4,
                decoration: BoxDecoration(
                  color: widget.selected
                      ? Theme.of(context).colorScheme.onPrimary
                      : Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.5),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// HexagonClipper defines the 6-sided shape used by the toggle.
class HexagonClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    double w = size.width;
    double h = size.height;
    double r = w / 2;
    final path = Path();
    // Rotate by 30 degrees (pi/6)
    double rotation = 3.1415926 / 6;
    for (int i = 0; i < 6; i++) {
      double angle = 3.1415926 / 3 * i + rotation;
      double x = w / 2 + r * math.cos(angle);
      double y = h / 2 + r * math.sin(angle);
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
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

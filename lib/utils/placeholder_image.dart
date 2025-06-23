import 'package:flutter/material.dart';

class PlaceholderImage extends StatelessWidget {
  final double width;
  final double height;
  final String text;
  final Color? backgroundColor;
  final Color? textColor;

  const PlaceholderImage({
    super.key,
    required this.width,
    required this.height,
    this.text = 'No Image',
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: width,
      height: height,
      color: backgroundColor ?? theme.colorScheme.surfaceContainerHighest,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.image_not_supported_outlined,
              size: 48,
              color: textColor ?? theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 8),
            Text(
              text,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: textColor ?? theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

class StatsCard extends StatelessWidget {
  final String label;
  final int value;
  final IconData? icon;
  final Color? color;

  const StatsCard({
    super.key,
    required this.label,
    required this.value,
    this.icon,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveColor = color ?? theme.colorScheme.primary;

    return Card(
      color: effectiveColor.withValues(alpha: 0.1 * 255),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Column(
          children: [
            Icon(icon, color: effectiveColor),
            const SizedBox(height: 8),
            Text(
              value.toString(),
              style: theme.textTheme.headlineMedium?.copyWith(
                color: effectiveColor,
              ),
            ),
            Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: effectiveColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

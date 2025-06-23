import 'package:flutter/material.dart';

class EmptyState extends StatelessWidget {
  final String message;
  final IconData? icon;
  final VoidCallback? onAction;
  final String? actionLabel;

  const EmptyState({
    super.key,
    required this.message,
    this.icon,
    this.onAction,
    this.actionLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 48,
              color: Theme.of(context).colorScheme.secondary,
            ),
            const SizedBox(height: 16),
          ],
          Text(
            message,
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
          if (onAction != null && actionLabel != null) ...[
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onAction,
              child: Text(actionLabel!),
            ),
          ],
        ],
      ),
    );
  }
}

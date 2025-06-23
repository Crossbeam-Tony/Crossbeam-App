import 'package:flutter/material.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onAction;
  final String? actionLabel;
  final IconData? actionIcon;

  const SectionHeader({
    super.key,
    required this.title,
    this.onAction,
    this.actionLabel,
    this.actionIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          if (onAction != null && actionLabel != null)
            TextButton.icon(
              onPressed: onAction,
              icon: Icon(actionIcon ?? Icons.arrow_forward, size: 16),
              label: Text(actionLabel!),
            ),
        ],
      ),
    );
  }
}

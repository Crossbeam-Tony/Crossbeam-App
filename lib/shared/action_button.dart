import 'package:flutter/material.dart';

class ActionButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final IconData? icon;
  final bool isOutlined;
  final bool isLoading;

  const ActionButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isOutlined = false,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final buttonStyle = isOutlined
        ? OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          )
        : ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          );

    final button = isOutlined
        ? OutlinedButton(
            onPressed: isLoading ? null : onPressed,
            style: buttonStyle,
            child: _buildChild(),
          )
        : ElevatedButton(
            onPressed: isLoading ? null : onPressed,
            style: buttonStyle,
            child: _buildChild(),
          );

    return button;
  }

  Widget _buildChild() {
    if (isLoading) {
      return const SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
        ),
      );
    }

    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 8),
          Text(label),
        ],
      );
    }

    return Text(label);
  }
}

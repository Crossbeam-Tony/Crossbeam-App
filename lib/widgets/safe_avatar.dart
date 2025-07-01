import 'package:flutter/material.dart';

class SafeAvatar extends StatelessWidget {
  final String? imageUrl;
  final double radius;
  final IconData fallbackIcon;
  final Color? backgroundColor;

  const SafeAvatar({
    super.key,
    this.imageUrl,
    this.radius = 20,
    this.fallbackIcon = Icons.person,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    // If no URL or empty URL, show fallback icon
    if (imageUrl == null || imageUrl!.isEmpty) {
      return CircleAvatar(
        radius: radius,
        backgroundColor:
            backgroundColor ?? Theme.of(context).colorScheme.surface,
        child: Icon(
          Icons.person,
          size: radius * 0.6,
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
        ),
      );
    }

    // Try to load the image, but show fallback if it fails
    return CircleAvatar(
      radius: radius,
      backgroundColor: backgroundColor ?? Theme.of(context).colorScheme.surface,
      backgroundImage: NetworkImage(imageUrl!),
      onBackgroundImageError: (exception, stackTrace) {
        // This will be called if the image fails to load
        print('Failed to load avatar image: $exception');
      },
      child: imageUrl!.isEmpty
          ? Icon(
              fallbackIcon,
              size: radius * 0.6,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            )
          : null,
    );
  }
}

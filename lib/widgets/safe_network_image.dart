import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../utils/placeholder_image.dart';

class SafeNetworkImage extends StatelessWidget {
  final String imageUrl;
  final double width;
  final double height;
  final BoxFit fit;
  final Widget? errorWidget;

  const SafeNetworkImage({
    super.key,
    required this.imageUrl,
    required this.width,
    required this.height,
    this.fit = BoxFit.cover,
    this.errorWidget,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrl.isEmpty) {
      return errorWidget ??
          PlaceholderImage(
            width: width,
            height: height,
          );
    }

    return CachedNetworkImage(
      imageUrl: imageUrl,
      width: width,
      height: height,
      fit: fit,
      errorWidget: (context, url, error) =>
          errorWidget ??
          PlaceholderImage(
            width: width,
            height: height,
          ),
      placeholder: (context, url) =>
          const Center(child: CircularProgressIndicator()),
    );
  }
}

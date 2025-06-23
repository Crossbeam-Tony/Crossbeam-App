import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'placeholder_image.dart';

class SafeNetworkImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? errorWidget;
  final Widget? placeholder;

  const SafeNetworkImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.errorWidget,
    this.placeholder,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrl.isEmpty) {
      return PlaceholderImage(
        width: width ?? double.infinity,
        height: height ?? 200,
      );
    }

    return CachedNetworkImage(
      imageUrl: imageUrl,
      width: width,
      height: height,
      fit: fit,
      placeholder: (context, url) =>
          placeholder ??
          const Center(
            child: CircularProgressIndicator(),
          ),
      errorWidget: (context, url, error) =>
          errorWidget ??
          PlaceholderImage(
            width: width ?? double.infinity,
            height: height ?? 200,
          ),
    );
  }
}

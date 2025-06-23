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
    return Container(
      width: width,
      height: height,
      color: backgroundColor ?? Colors.grey[300],
      child: Center(
        child: Text(
          text,
          style: TextStyle(
            color: textColor ?? Colors.grey[600],
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}

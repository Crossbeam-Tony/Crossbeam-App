import 'package:flutter/material.dart';
import '../screens/user_profile_screen.dart';
import 'dart:math';

class HexagonClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    final width = size.width;
    final height = size.height;
    final side = width / 2;
    final centerX = width / 2;
    final centerY = height / 2;
    final r = side;
    for (int i = 0; i < 6; i++) {
      final angle = pi / 3 * i + pi / 6 + pi / 6;
      final x = centerX + r * cos(angle);
      final y = centerY + r * sin(angle);
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

class Avatar extends StatelessWidget {
  final String imageUrl;
  final double size;
  final String? username;
  final String? userId;
  final VoidCallback? onTap;

  const Avatar({
    super.key,
    required this.imageUrl,
    this.size = 40,
    this.username,
    this.userId,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (onTap != null) {
          onTap!();
        } else if (userId != null) {
          // Navigate to user profile using Navigator.push
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => UserProfileScreen(userId: userId!),
            ),
          );
        }
      },
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: SizedBox(
          width: size,
          height: size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Orange hex border
              SizedBox(
                width: size,
                height: size,
                child: CustomPaint(
                  painter: _HexBorderPainter(
                    color: const Color(
                        0xFFFF7300), // Use DesignSystem.mutedTangerine if available
                    strokeWidth: size * 0.08,
                  ),
                ),
              ),
              ClipPath(
                clipper: HexagonClipper(),
                child: imageUrl.isEmpty
                    ? Container(
                        color: Colors.grey[300],
                        child:
                            Center(child: Icon(Icons.person, size: size / 2)),
                      )
                    : Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: Colors.grey[300],
                          child:
                              Center(child: Icon(Icons.person, size: size / 2)),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HexBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  _HexBorderPainter({required this.color, this.strokeWidth = 4});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    final path = Path();
    final width = size.width;
    final height = size.height;
    final side = width / 2;
    final centerX = width / 2;
    final centerY = height / 2;
    final r = side * 0.95;
    for (int i = 0; i < 6; i++) {
      final angle = 3.141592653589793 / 3 * i +
          3.141592653589793 / 6 +
          3.141592653589793 / 6;
      final x = centerX + r * cos(angle);
      final y = centerY + r * sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

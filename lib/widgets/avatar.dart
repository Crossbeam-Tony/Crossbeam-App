import 'package:flutter/material.dart';
import 'dart:math';
import 'package:provider/provider.dart';
import '../services/data_service.dart';
import '../screens/user_profile_screen.dart';

class AvatarPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final path = Path();
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    for (int i = 0; i < 6; i++) {
      final angle = (i * 60 + 30) * pi / 180; // Rotate by 90 degrees (add 30)
      final x = center.dx + radius * cos(angle);
      final y = center.dy + radius * sin(angle);
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
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}

class AvatarWidget extends StatelessWidget {
  final String url;
  final double radius;
  final String userId;
  final bool showName;
  final bool showUsername;
  final bool useListTile;
  final VoidCallback? onTap;
  final bool disableInternalNavigation;

  const AvatarWidget({
    super.key,
    required this.url,
    required this.radius,
    required this.userId,
    this.showName = false,
    this.showUsername = false,
    this.useListTile = false,
    this.onTap,
    this.disableInternalNavigation = false,
  });

  @override
  Widget build(BuildContext context) {
    final dataService = Provider.of<DataService>(context, listen: false);
    final user = dataService.getUserById(userId);

    final avatar = GestureDetector(
      onTap: () {
        print('AvatarWidget onTap called for userId: $userId');
        print('External onTap provided: ${onTap != null}');
        print('Disable internal navigation: $disableInternalNavigation');

        // If external onTap is provided, use it
        if (onTap != null) {
          print('Calling external onTap callback');
          onTap!();
          return;
        }

        // If internal navigation is disabled, do nothing
        if (disableInternalNavigation) {
          print('Internal navigation disabled, doing nothing');
          return;
        }

        // Otherwise, use internal navigation logic
        if (user != null && user.isCurrentUser) {
          print('Showing profile picture dialog for current user');
          // Show profile picture dialog for current user
          showDialog(
            context: context,
            builder: (context) => Dialog(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.network(
                    url,
                    width: 200,
                    height: 200,
                    fit: BoxFit.cover,
                  ),
                  TextButton(
                    onPressed: () {
                      // TODO: Implement change profile picture
                      Navigator.pop(context);
                    },
                    child: const Text('Change Profile Picture'),
                  ),
                ],
              ),
            ),
          );
        } else {
          print('Navigating to user profile for userId: $userId');
          // Navigate to user profile for other users (or if user not found, still try to navigate)
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => UserProfileScreen(userId: userId),
            ),
          );
        }
      },
      behavior: HitTestBehavior.opaque, // This ensures the tap is captured
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: CustomPaint(
          size: Size(radius * 2, radius * 2),
          painter: AvatarPainter(),
          child: CircleAvatar(
            radius: radius,
            backgroundImage: NetworkImage(url),
            onBackgroundImageError: (exception, stackTrace) {
              // Handle image loading errors
            },
          ),
        ),
      ),
    );

    if (useListTile) {
      return ListTile(
        leading: avatar,
        title: showName && user != null ? Text(user.name) : null,
        subtitle:
            showUsername && user != null ? Text('@${user.username}') : null,
      );
    }

    return avatar;
  }
}

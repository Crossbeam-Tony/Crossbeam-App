import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import 'rotating_gear.dart';
import 'package:go_router/go_router.dart';

class CrossbeamHeader extends StatelessWidget {
  const CrossbeamHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthService>(context).currentUser;
    return Container(
      color: Theme.of(context).colorScheme.surface,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: IconTheme(
        data: IconThemeData(
            color: Theme.of(context).colorScheme.onSurface, size: 32),
        child: Row(
          children: [
            Image.asset(
              'assets/images/crossbeam_header.png',
              height: 40,
            ),
            const Spacer(),
            const RotatingGear(),
            const SizedBox(width: 16),
            if (user != null)
              GestureDetector(
                onTap: () {
                  GoRouter.of(context).go('/profile');
                },
                child: CircleAvatar(
                  backgroundImage: user.avatarUrl.isNotEmpty
                      ? NetworkImage(user.avatarUrl)
                      : null,
                  child:
                      user.avatarUrl.isEmpty ? const Icon(Icons.person) : null,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

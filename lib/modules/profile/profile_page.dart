import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child:
              Text('Profile', style: Theme.of(context).textTheme.headlineSmall),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: ListView(
            children: [
              // Existing profile widgets
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text('My Circle',
                    style: Theme.of(context).textTheme.titleMedium),
              ),
              const Card(
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(
                    child: Text(
                        'My Circle Page'), // Replace with actual My Circle content if available
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

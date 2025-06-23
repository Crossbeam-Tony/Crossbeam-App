import 'package:flutter/material.dart';

class MapTestPage extends StatelessWidget {
  const MapTestPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Text('Map', style: Theme.of(context).textTheme.headlineSmall),
            ],
          ),
        ),
        const Expanded(
          child: Center(
            child: Text('Map Page'),
          ),
        ),
      ],
    );
  }
}

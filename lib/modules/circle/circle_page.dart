import 'package:flutter/material.dart';

class CirclePage extends StatelessWidget {
  const CirclePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Text('Circle', style: Theme.of(context).textTheme.headlineSmall),
            ],
          ),
        ),
        const Expanded(
          child: Center(
            child: Text('Circle Page'),
          ),
        ),
      ],
    );
  }
}

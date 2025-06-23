import 'package:flutter/material.dart';
import '../../data/seed_data.dart';
import '../../shared/avatar.dart';

class CirclePage extends StatefulWidget {
  const CirclePage({super.key});

  @override
  State<CirclePage> createState() => _CirclePageState();
}

class _CirclePageState extends State<CirclePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Circles'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your Crews',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: seededCrews.length,
                itemBuilder: (context, index) {
                  final crew = seededCrews[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      leading: Avatar(
                        imageUrl: crew.imageUrl ??
                            'https://picsum.photos/seed/default/100/100',
                        size: 50,
                      ),
                      title: Text(crew.name),
                      subtitle: Text(crew.description),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        // TODO: Navigate to crew detail page
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

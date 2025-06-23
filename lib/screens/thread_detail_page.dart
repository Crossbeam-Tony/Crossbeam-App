import 'package:flutter/material.dart';

class ThreadDetailPage extends StatelessWidget {
  final String crewName;
  final String subcrewName;
  final String threadTitle;
  const ThreadDetailPage(
      {super.key,
      required this.crewName,
      required this.subcrewName,
      required this.threadTitle});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(subcrewName),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              crewName,
              style: Theme.of(context)
                  .textTheme
                  .labelLarge
                  ?.copyWith(color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              threadTitle,
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'Thread details and replies will go here.',
                style: TextStyle(color: Colors.black54),
              ),
            ),
            const Spacer(),
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.reply),
              label: const Text('Reply (coming soon)'),
              style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48)),
            ),
          ],
        ),
      ),
    );
  }
}

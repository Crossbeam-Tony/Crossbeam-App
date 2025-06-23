import 'package:flutter/material.dart';
import '../models/crew.dart';
import '../data/dummy_crews_threads.dart';
import 'subcrew_threads_page.dart';

class CrewDetailPage extends StatelessWidget {
  final Crew crew;
  const CrewDetailPage({super.key, required this.crew});

  @override
  Widget build(BuildContext context) {
    final subcrews =
        dummyCrewsThreads[crew.name]?.map((cat) => cat.keys.first).toList() ??
            [];
    return Scaffold(
      appBar: AppBar(
        title: Text(crew.name),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    if (crew.imageUrl != null)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: Image.network(crew.imageUrl!,
                            height: 64, width: 64, fit: BoxFit.cover),
                      ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            crew.name,
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            crew.description,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text('Categories', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.separated(
                itemCount: subcrews.length,
                separatorBuilder: (_, __) => const Divider(),
                itemBuilder: (context, index) {
                  final subcrew = subcrews[index];
                  return Card(
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4)),
                    child: ListTile(
                      leading:
                          const Icon(Icons.category, color: Colors.deepOrange),
                      title: Text(subcrew,
                          style: const TextStyle(fontWeight: FontWeight.w500)),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => SubcrewThreadsPage(
                              crewName: crew.name,
                              subcrewName: subcrew,
                            ),
                          ),
                        );
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

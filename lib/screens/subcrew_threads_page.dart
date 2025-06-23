import 'package:flutter/material.dart';
import '../data/dummy_crews_threads.dart';
import 'thread_detail_page.dart';

class SubcrewThreadsPage extends StatelessWidget {
  final String crewName;
  final String subcrewName;
  const SubcrewThreadsPage(
      {super.key, required this.crewName, required this.subcrewName});

  @override
  Widget build(BuildContext context) {
    final subcrews = dummyCrewsThreads[crewName] ?? [];
    final threads = subcrews.firstWhere(
      (cat) => cat.keys.first == subcrewName,
      orElse: () => {subcrewName: <String>[]},
    )[subcrewName] as List<String>;
    return Scaffold(
      appBar: AppBar(
        title: Text(subcrewName),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Text(
              crewName,
              style: Theme.of(context)
                  .textTheme
                  .labelLarge
                  ?.copyWith(color: Colors.grey[600]),
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: threads.length,
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (context, index) {
                return ListTile(
                  leading: const Icon(Icons.forum_outlined,
                      color: Colors.deepOrange),
                  title: Text(
                    threads[index],
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ThreadDetailPage(
                          crewName: crewName,
                          subcrewName: subcrewName,
                          threadTitle: threads[index],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

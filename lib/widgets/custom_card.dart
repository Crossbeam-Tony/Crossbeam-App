import 'package:flutter/material.dart';
import '../config/design_system.dart';
import '../data/dummy_crews_threads.dart';
import '../screens/thread_detail_page.dart';

class CustomCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? color;
  final VoidCallback? onTap;

  const CustomCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: margin ?? const EdgeInsets.all(DesignSystem.cardMargin),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DesignSystem.cardBorderRadius),
      ),
      color: color,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(DesignSystem.cardBorderRadius),
        child: Padding(
          padding: padding ?? const EdgeInsets.all(DesignSystem.cardPadding),
          child: child,
        ),
      ),
    );
  }
}

class CrewCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;
  final String? imageUrl;

  const CrewCard({
    super.key,
    required this.title,
    this.subtitle,
    this.onTap,
    this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    // Get recent discussion threads for this crew
    List<Map<String, String>> recentThreads = [];

    try {
      final crewThreads = dummyCrewsThreads[title];

      if (crewThreads != null) {
        // Flatten all threads from all subcrews with their subcrew names
        for (var subcrew in crewThreads) {
          for (var entry in subcrew.entries) {
            String subcrewName = entry.key;
            List<String> threads = entry.value;
            for (String thread in threads.take(3)) {
              recentThreads.add({
                'subcrew': subcrewName,
                'thread': thread,
              });
            }
          }
        }
        // Take the first 3 threads
        recentThreads = recentThreads.take(3).toList();
      }
    } catch (e) {
      // If there's an error loading threads, just use empty list
      recentThreads = [];
    }

    return CustomCard(
      onTap: onTap,
      padding: const EdgeInsets.all(8),
      child: SizedBox(
        height: 140, // Fixed height for the card
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Crew image
            if (imageUrl != null)
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(4),
                ),
                child: Image.network(
                  imageUrl!,
                  width: double.infinity,
                  height: 60,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      width: double.infinity,
                      height: 60,
                      color: Colors.grey[200],
                      child: const Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: double.infinity,
                      height: 60,
                      color: Colors.grey[300],
                      child: const Icon(
                        Icons.group,
                        size: 30,
                        color: Colors.grey,
                      ),
                    );
                  },
                ),
              ),

            // Crew title and recent posts
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  // Show up to 2 recent threads or placeholder if none
                  ...recentThreads.isNotEmpty
                      ? recentThreads.take(2).map((threadData) => Padding(
                            padding: const EdgeInsets.only(bottom: 2),
                            child: InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ThreadDetailPage(
                                      crewName: title,
                                      subcrewName: threadData['subcrew']!,
                                      threadTitle: threadData['thread']!,
                                    ),
                                  ),
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.transparent,
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(
                                    color: DesignSystem.mutedTangerine,
                                    width: 1.2,
                                  ),
                                ),
                                child: Text(
                                  threadData['thread']!,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        fontSize: 8,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w500,
                                      ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          ))
                      : List.generate(
                          2,
                          (index) => Padding(
                                padding: const EdgeInsets.only(bottom: 2),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.transparent,
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(
                                      color: Colors.grey[400]!,
                                      width: 1.2,
                                    ),
                                  ),
                                  child: Text(
                                    'No threads yet',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(
                                          fontSize: 8,
                                          color: Colors.grey[500],
                                          fontWeight: FontWeight.w400,
                                        ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

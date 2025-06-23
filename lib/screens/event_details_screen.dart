import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../services/data_service.dart';
import '../shared/avatar.dart';
import '../models/user_profile.dart';

class EventDetailsScreen extends StatelessWidget {
  final String eventId;

  const EventDetailsScreen({
    super.key,
    required this.eventId,
  });

  @override
  Widget build(BuildContext context) {
    final dataService = Provider.of<DataService>(context, listen: false);
    final event = dataService.events.firstWhere((e) => e.id == eventId);

    return Scaffold(
      appBar: AppBar(
        title: Text(event.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              // TODO: Implement share functionality
            },
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              // TODO: Show more options
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (event.imageUrl != null)
              Image.network(
                event.imageUrl!,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 200,
                    width: double.infinity,
                    color: Colors.grey[200],
                    child: const Center(
                      child: Icon(
                        Icons.image_not_supported_outlined,
                        size: 48,
                        color: Colors.grey,
                      ),
                    ),
                  );
                },
              ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.calendar_today,
                          size: 16,
                          color: Theme.of(context).colorScheme.secondary),
                      const SizedBox(width: 4),
                      Text(
                        DateFormat('EEEE, MMMM d, y').format(event.date),
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Icon(Icons.location_on,
                          size: 16,
                          color: Theme.of(context).colorScheme.secondary),
                      const SizedBox(width: 4),
                      Text(
                        event.location,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'About',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    event.description,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Avatar(
                        imageUrl: event.organizerAvatar,
                        size: 60,
                        username: event.organizer,
                        userId: event.organizerId,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Organizer',
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                            Text(
                              event.organizer,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Attendees',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  // Confirmed attendee avatars row (green border)
                  SizedBox(
                    height: 36,
                    child: Consumer<DataService>(
                      builder: (context, dataService, _) {
                        final users = dataService.users;
                        final confirmedIds = event.confirmedAttendeeIds;
                        const maxAvatars = 8;
                        final avatarsToShow = confirmedIds.length < maxAvatars
                            ? confirmedIds.length
                            : maxAvatars;
                        return ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: avatarsToShow,
                          itemBuilder: (context, index) {
                            final user =
                                findUserById(users, confirmedIds[index]);
                            if (user == null) return const SizedBox.shrink();
                            return Padding(
                              padding: const EdgeInsets.only(right: 4),
                              child: Avatar(
                                imageUrl: user.avatarUrl,
                                size: 32,
                                userId: user.id,
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Interested attendee avatars row (orange border)
                  SizedBox(
                    height: 36,
                    child: Consumer<DataService>(
                      builder: (context, dataService, _) {
                        final users = dataService.users;
                        final interestedIds = event.interestedAttendeeIds;
                        const maxAvatars = 8;
                        final avatarsToShow = interestedIds.length < maxAvatars
                            ? interestedIds.length
                            : maxAvatars;
                        return ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: avatarsToShow,
                          itemBuilder: (context, index) {
                            final user =
                                findUserById(users, interestedIds[index]);
                            if (user == null) return const SizedBox.shrink();
                            return Padding(
                              padding: const EdgeInsets.only(right: 4),
                              child: Avatar(
                                imageUrl: user.avatarUrl,
                                size: 32,
                                userId: user.id,
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${event.confirmedAttendeeIds.length + event.interestedAttendeeIds.length} attending',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    // TODO: Implement RSVP functionality
                  },
                  icon: const Icon(Icons.event_available),
                  label: const Text('RSVP'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    // TODO: Implement share functionality
                  },
                  icon: const Icon(Icons.share),
                  label: const Text('Share'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Helper function for safe lookup
UserProfile? findUserById(List<UserProfile> users, String id) {
  try {
    return users.firstWhere((u) => u.id == id);
  } catch (_) {
    return null;
  }
}

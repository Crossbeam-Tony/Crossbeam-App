import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/data_service.dart';
import 'package:intl/intl.dart';
import 'event_details_screen.dart';
import 'package:go_router/go_router.dart';
import '../shared/avatar.dart';
import '../models/user_profile.dart';

class EventsScreen extends StatelessWidget {
  const EventsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dataService = Provider.of<DataService>(context);
    final events = dataService.events;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Events'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // TODO: Implement create event functionality
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: events.length,
        itemBuilder: (context, index) {
          final event = events[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: InkWell(
              onTap: () {
                context.push('/events/${event.id}');
              },
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
                          style: Theme.of(context).textTheme.titleLarge,
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
                        const SizedBox(height: 8),
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
                        const SizedBox(height: 8),
                        // Confirmed attendee avatars row (green border)
                        SizedBox(
                          height: 36,
                          child: Consumer<DataService>(
                            builder: (context, dataService, _) {
                              final users = dataService.users;
                              final confirmedIds = event.confirmedAttendeeIds;
                              const maxAvatars = 8;
                              final avatarsToShow =
                                  confirmedIds.length < maxAvatars
                                      ? confirmedIds.length
                                      : maxAvatars;
                              return ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: avatarsToShow,
                                itemBuilder: (context, index) {
                                  final user =
                                      findUserById(users, confirmedIds[index]);
                                  if (user == null) {
                                    return const SizedBox.shrink();
                                  }
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
                              final avatarsToShow =
                                  interestedIds.length < maxAvatars
                                      ? interestedIds.length
                                      : maxAvatars;
                              return ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: avatarsToShow,
                                itemBuilder: (context, index) {
                                  final user =
                                      findUserById(users, interestedIds[index]);
                                  if (user == null) {
                                    return const SizedBox.shrink();
                                  }
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
                        Row(
                          children: [
                            Icon(Icons.people,
                                size: 16,
                                color: Theme.of(context).colorScheme.secondary),
                            const SizedBox(width: 4),
                            Text(
                              '${event.confirmedAttendeeIds.length + event.interestedAttendeeIds.length} attending',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // Helper function for safe lookup
  UserProfile? findUserById(List<UserProfile> users, String id) {
    try {
      return users.firstWhere((u) => u.id == id);
    } catch (_) {
      return null;
    }
  }
}

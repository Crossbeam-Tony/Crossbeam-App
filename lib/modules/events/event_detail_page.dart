import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/event.dart';
import '../../services/data_service.dart';
import '../../shared/user_link.dart';
import '../../shared/avatar.dart';

class EventDetailPage extends StatelessWidget {
  final Event event;
  const EventDetailPage({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    final user = context.read<DataService>().getUserById(event.organizerId);

    return Scaffold(
      appBar: AppBar(title: Text(event.title)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (user != null)
              UserLink(
                userId: user.id,
                size: 20,
                showName: true,
                showUsername: true,
              )
            else
              Row(
                children: [
                  Avatar(
                    imageUrl: event.organizerAvatar,
                    size: 40,
                    username: event.organizer,
                    userId: event.organizerId,
                  ),
                  const SizedBox(width: 10),
                  Text(event.organizer,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            const SizedBox(height: 16),
            if (event.imageUrl != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  event.imageUrl!,
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ),
            const SizedBox(height: 16),
            Text(
              event.description,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            Text('Date: ${event.date}', style: const TextStyle(fontSize: 16)),
            Text('Location: ${event.location}',
                style: const TextStyle(color: Colors.grey)),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.check_circle_outline),
                  label: const Text('RSVP'),
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.share),
                  label: const Text('Share'),
                  onPressed: () {},
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../models/project.dart';
import '../models/event.dart';
import '../models/marketplace_listing.dart';
import 'project_card.dart';

// Card builders for each content type
Widget buildProjectCard(Project project) => ProjectCard(project: project);

Widget buildEventCard(Event event) {
  return Card(
    margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
    child: ListTile(
      leading: CircleAvatar(
        backgroundImage:
            NetworkImage(event.imageUrl ?? 'https://picsum.photos/50/50'),
      ),
      title: Text(event.title),
      subtitle: Text(event.location),
      trailing: Text('${event.date.day}/${event.date.month}'),
    ),
  );
}

Widget buildListingCard(MarketplaceListing listing) {
  return Card(
    margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
    child: ListTile(
      leading: CircleAvatar(
        backgroundImage:
            NetworkImage(listing.imageUrl ?? 'https://picsum.photos/50/50'),
      ),
      title: Text(listing.title),
      subtitle: Text(listing.description),
      trailing: Text('\$${listing.price.toStringAsFixed(2)}'),
    ),
  );
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/data_service.dart';
import '../models/user_profile.dart';
import '../widgets/project_card.dart';
import '../widgets/marketplace_item_card.dart';
import 'my_profile_screen.dart';
import '../shared/avatar.dart';

class UserProfileScreen extends StatelessWidget {
  final String userId;

  const UserProfileScreen({Key? key, required this.userId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<DataService>(
      builder: (context, dataService, child) {
        final user = dataService.getUserById(userId);
        if (user == null) {
          return const Scaffold(
            body: Center(child: Text('User not found')),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(user.name),
            actions: [
              IconButton(
                icon: const Icon(Icons.message),
                onPressed: () {
                  // TODO: Navigate to chat with this user
                },
              ),
            ],
          ),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProfileHeader(user),
                _buildUserStats(user),
                _buildUserEvents(user, dataService),
                _buildUserProjects(user, dataService),
                _buildUserMarketplaceItems(user, dataService),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfileHeader(UserProfile user) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Avatar(
            imageUrl: user.avatarUrl,
            size: 80,
            userId: user.id,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  user.email,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserStats(UserProfile user) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('Events', user.events.length.toString()),
          _buildStatItem('Projects', user.projects.length.toString()),
          _buildStatItem('Listings', user.marketplaceItems.length.toString()),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildUserEvents(UserProfile user, DataService dataService) {
    final userEvents = dataService.events
        .where((event) =>
            event.organizerId == user.id ||
            event.confirmedAttendeeIds.contains(user.id) ||
            event.interestedAttendeeIds.contains(user.id))
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'Events',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: userEvents.length,
          itemBuilder: (context, index) {
            final event = userEvents[index];
            return Card(
              margin: const EdgeInsets.all(4.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
              child: ListTile(
                leading: const Icon(Icons.event),
                title: Text(event.title),
                subtitle: Text(event.description),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildUserProjects(UserProfile user, DataService dataService) {
    final userProjects = dataService.projects
        .where((project) => project.members.contains(user.id))
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'Projects',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: userProjects.length,
          itemBuilder: (context, index) {
            return ProjectCard(project: userProjects[index]);
          },
        ),
      ],
    );
  }

  Widget _buildUserMarketplaceItems(UserProfile user, DataService dataService) {
    final userItems = dataService.marketplaceItems
        .where((item) => item.sellerId == user.id)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'Marketplace Listings',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: userItems.length,
          itemBuilder: (context, index) {
            return MarketplaceItemCard(item: userItems[index]);
          },
        ),
      ],
    );
  }
}

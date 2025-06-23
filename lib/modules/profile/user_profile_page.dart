import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../models/user_profile.dart';
import '../../shared/avatar.dart';
import '../../shared/empty_state.dart';
import '../../services/data_service.dart';

class UserProfilePage extends StatelessWidget {
  const UserProfilePage({super.key, required this.userId});
  final String userId;

  @override
  Widget build(BuildContext context) {
    final dataService = context.read<DataService>();
    final user = dataService.getUserProfile(userId);

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('User not found')),
      );
    }

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        body: CustomScrollView(
          slivers: [
            // Cover Photo and Profile Header
            SliverAppBar(
              expandedHeight: 200,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      'https://picsum.photos/seed/${user.id}/800/400',
                      fit: BoxFit.cover,
                    ),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.7 * 255),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              bottom: const TabBar(
                isScrollable: true,
                tabs: [
                  Tab(text: 'Projects'),
                  Tab(text: 'Events'),
                  Tab(text: 'Crews'),
                  Tab(text: 'Posts'),
                ],
              ),
            ),

            // Profile Info
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Transform.translate(
                          offset: const Offset(0, -40),
                          child: Avatar(
                            imageUrl: user.avatarUrl,
                            size: 100,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user.realname,
                                style:
                                    Theme.of(context).textTheme.headlineSmall,
                              ),
                              Text(
                                '@${user.username}',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              Text(
                                user.location,
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      user.bio,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                ),
              ),
            ),

            // Public Stats
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(color: Theme.of(context).dividerColor),
                    bottom: BorderSide(color: Theme.of(context).dividerColor),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStat(
                        context, 'Projects', user.stats['projects'] ?? 0),
                    _buildStat(context, 'Events', user.stats['events'] ?? 0),
                    _buildStat(
                        context, 'Followers', user.stats['followers'] ?? 0),
                    _buildStat(
                        context, 'Following', user.stats['following'] ?? 0),
                  ],
                ),
              ),
            ),

            // Tab Content
            SliverFillRemaining(
              child: TabBarView(
                children: <Widget>[
                  // Projects Tab
                  _buildProjectsTab(context, dataService, user),

                  // Events Tab
                  _buildEventsTab(context, dataService, user),

                  // Crews Tab
                  _buildCrewsTab(context, user),

                  // Posts Tab
                  _buildPostsTab(context, dataService, user),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProjectsTab(
      BuildContext context, DataService dataService, UserProfile user) {
    final projects = dataService.getProjectsByCrew(user.id);
    if (projects.isEmpty) {
      return const EmptyState(
        message: 'No projects yet',
        icon: Icons.work_outline,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: projects.length,
      itemBuilder: (context, index) {
        final project = projects[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: ListTile(
            leading: Avatar(
              imageUrl: user.avatarUrl,
              size: 60,
            ),
            title: Text(project.title),
            subtitle: Text(project.description),
            trailing: Text(project.status.name),
          ),
        );
      },
    );
  }

  Widget _buildEventsTab(
      BuildContext context, DataService dataService, UserProfile user) {
    final events = dataService.getEventsByOrganizer(user.id);
    if (events.isEmpty) {
      return const EmptyState(
        message: 'No events yet',
        icon: Icons.event_outlined,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: events.length,
      itemBuilder: (context, index) {
        final event = events[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: ListTile(
            leading: Avatar(
              imageUrl: user.avatarUrl,
              size: 50,
            ),
            title: Text(event.title),
            subtitle: Text(event.description),
            trailing: Text(event.status.name),
          ),
        );
      },
    );
  }

  Widget _buildCrewsTab(BuildContext context, UserProfile user) {
    if (user.mutualCrews.isEmpty) {
      return const EmptyState(
        message: 'No crews yet',
        icon: Icons.group_outlined,
      );
    }

    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Wrap(
        spacing: 4.0,
        runSpacing: 4.0,
        children: user.mutualCrews
            .map((crew) => Chip(
                  label: Text(crew),
                  backgroundColor: Theme.of(context)
                      .colorScheme
                      .primary
                      .withValues(alpha: 0.1 * 255),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4.0),
                  ),
                ))
            .toList(),
      ),
    );
  }

  Widget _buildPostsTab(
      BuildContext context, DataService dataService, UserProfile user) {
    final posts = dataService.crewsfeedPosts
        .where((post) => post.authorId == user.id)
        .toList();
    if (posts.isEmpty) {
      return const EmptyState(
        message: 'No posts yet',
        icon: Icons.post_add_outlined,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: posts.length,
      itemBuilder: (context, index) {
        final post = posts[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: Avatar(
              imageUrl: user.avatarUrl,
              size: 40,
            ),
            title: Text(post.title),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(post.description),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.favorite,
                        size: 16,
                        color: Theme.of(context).colorScheme.secondary),
                    const SizedBox(width: 4),
                    Text(
                      post.likes.toString(),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Icon(Icons.comment,
                        size: 16,
                        color: Theme.of(context).colorScheme.secondary),
                    const SizedBox(width: 4),
                    Text(
                      post.comments.length.toString(),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            isThreeLine: true,
            onTap: () {
              context.push('/crewsfeed/${post.id}', extra: post);
            },
          ),
        );
      },
    );
  }

  Widget _buildStat(BuildContext context, String label, int value) {
    return Column(
      children: [
        Text(
          value.toString(),
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}

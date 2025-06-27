import 'package:flutter/material.dart';
import 'package:provider/provider.dart' as provider;
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/auth_service.dart';
import '../shared/avatar.dart';
import '../config/design_system.dart';
import 'dart:math';

class MyProfileScreen extends StatelessWidget {
  const MyProfileScreen({super.key});

  Future<void> _logout(BuildContext context) async {
    try {
      await Supabase.instance.client.auth.signOut();
      if (context.mounted) {
        // GoRouter will automatically redirect to login
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Logged out successfully')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error logging out: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = provider.Provider.of<AuthService>(context).currentUser;
    if (user == null) return const SizedBox.shrink();

    // Dummy collab data for demonstration
    final List<Map<String, dynamic>> dummyCollabSent = [
      {'project': 'Indie Film Production', 'status': 'Pending'},
      {'project': 'Music Video Shoot', 'status': 'Pending'},
    ];
    final List<Map<String, dynamic>> dummyCollabReceived = [
      {'project': 'Documentary Series', 'status': 'Pending'},
    ];
    final List<String> dummyActiveCollabs = [
      'Indie Film Production',
      'Documentary Series',
    ];

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Cover Photo and Profile Header
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            actions: [
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert),
                onSelected: (value) {
                  if (value == 'logout') {
                    _logout(context);
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'logout',
                    child: Row(
                      children: [
                        Icon(Icons.logout, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Logout', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
            flexibleSpace: Stack(
              fit: StackFit.expand,
              children: [
                // Cover photo - using a car-themed image
                Image.network(
                  'https://images.unsplash.com/photo-1503376780353-7e6692767b70?auto=format&fit=crop&w=1200&h=400',
                  fit: BoxFit.cover,
                ),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.7),
                      ],
                    ),
                  ),
                ),
                // Avatar positioned over cover photo
                Positioned(
                  left: 16,
                  bottom: 16,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Hex border
                      SizedBox(
                        width: 108,
                        height: 108,
                        child: CustomPaint(
                          painter: _HexBorderPainter(
                            color: Theme.of(context).scaffoldBackgroundColor,
                            strokeWidth: 5,
                          ),
                        ),
                      ),
                      Avatar(
                        imageUrl: user.avatarUrl,
                        size: 100,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Profile Info
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name and username moved up
                  Text(
                    user.fullName,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  if (user.bio.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      user.bio,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                  ],
                  Row(
                    children: [
                      Icon(Icons.location_on,
                          color: Theme.of(context).colorScheme.primary),
                      const SizedBox(width: 8),
                      Text(
                        user.fullName,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),

          // Skills - Commented out until skills field is added to schema
          /*
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Skills & Interests',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 4.0,
                    runSpacing: 4.0,
                    children: user.skills.map((skill) {
                      final isDark =
                          Theme.of(context).brightness == Brightness.dark;
                      return Chip(
                        label: Text(skill),
                        backgroundColor: (isDark
                                ? DesignSystem.mutedTangerine
                                : DesignSystem.mutedTangerine)
                            .withValues(alpha: 0.1),
                        labelStyle: TextStyle(
                          color: isDark
                              ? DesignSystem.mutedTangerine
                              : DesignSystem.mutedTangerine,
                          fontWeight: FontWeight.w500,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
          */

          // Collaboration Activity Section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Collaboration Activity',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _CollabBadge(
                        label: 'Sent',
                        count: dummyCollabSent.length,
                        color: DesignSystem.mutedTangerine,
                      ),
                      const SizedBox(width: 8),
                      _CollabBadge(
                        label: 'Received',
                        count: dummyCollabReceived.length,
                        color: Colors.blue,
                      ),
                      const SizedBox(width: 8),
                      _CollabBadge(
                        label: 'Active',
                        count: dummyActiveCollabs.length,
                        color: Colors.green,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Sent
                      Expanded(
                        child: _CollabList(
                          title: 'Sent',
                          items: dummyCollabSent,
                          color: DesignSystem.mutedTangerine,
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Received
                      Expanded(
                        child: _CollabList(
                          title: 'Received',
                          items: dummyCollabReceived,
                          color: Colors.blue,
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Active
                      Expanded(
                        child: _ActiveCollabList(
                          items: dummyActiveCollabs,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Projects Section
          const SliverToBoxAdapter(
            child: _SectionList(
              title: 'Projects',
              children: [],
            ),
          ),
          // Crews Section
          const SliverToBoxAdapter(
            child: _SectionList(
              title: 'Crews',
              children: [],
            ),
          ),
          // Marketplace Section
          const SliverToBoxAdapter(
            child: _SectionList(
              title: 'Marketplace',
              children: [],
            ),
          ),
          // Posts Section
          const SliverToBoxAdapter(
            child: _SectionList(
              title: 'Posts',
              children: [],
            ),
          ),
          // Events Section
          const SliverToBoxAdapter(
            child: _SectionList(
              title: 'Events',
              children: [],
            ),
          ),

          const SizedBox(height: 24),

          // Profile actions
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    // TODO: Implement edit profile
                  },
                  icon: const Icon(Icons.edit),
                  label: const Text('Edit Profile'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    // TODO: Implement settings
                  },
                  icon: const Icon(Icons.settings),
                  label: const Text('Settings'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HexBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  const _HexBorderPainter({required this.color, this.strokeWidth = 4});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    final path = Path();
    final width = size.width;
    final height = size.height;
    final side = width / 2;
    final centerX = width / 2;
    final centerY = height / 2;
    final r = side * 0.95;
    for (int i = 0; i < 6; i++) {
      final angle = 3.141592653589793 / 3 * i +
          3.141592653589793 / 6 +
          3.141592653589793 / 6;
      final x = centerX + r * cos(angle);
      final y = centerY + r * sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _SectionList extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _SectionList({required this.title, required this.children});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ...children,
        ],
      ),
    );
  }
}

class _CollabBadge extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  const _CollabBadge(
      {required this.label, required this.count, required this.color});
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Text(label,
                  style: TextStyle(color: color, fontWeight: FontWeight.bold)),
              const SizedBox(width: 4),
              CircleAvatar(
                radius: 10,
                backgroundColor: color,
                child: Text('$count',
                    style: const TextStyle(color: Colors.white, fontSize: 12)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CollabList extends StatelessWidget {
  final String title;
  final List<Map<String, dynamic>> items;
  final Color color;
  const _CollabList(
      {required this.title, required this.items, required this.color});
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: TextStyle(color: color, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            ...items.map((item) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    children: [
                      Icon(Icons.circle, color: color, size: 10),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(item['project'],
                            style: TextStyle(color: color)),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(item['status'],
                            style: TextStyle(color: color, fontSize: 12)),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }
}

class _ActiveCollabList extends StatelessWidget {
  final List<String> items;
  final Color color;
  const _ActiveCollabList({required this.items, required this.color});
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Active',
                style: TextStyle(color: color, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            ...items.map((project) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle, color: color, size: 14),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(project, style: TextStyle(color: color)),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }
}

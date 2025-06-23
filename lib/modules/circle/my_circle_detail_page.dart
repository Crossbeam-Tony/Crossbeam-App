import 'package:flutter/material.dart';
import '../../shared/avatar.dart';
import '../../models/user_profile.dart';

class MyCircleDetailPage extends StatelessWidget {
  final UserProfile member;

  const MyCircleDetailPage({super.key, required this.member});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(member.realname)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [_buildMemberTile(member)],
      ),
    );
  }

  Widget _buildMemberTile(UserProfile member) {
    return ListTile(
      leading: Avatar(imageUrl: member.avatarUrl, size: 40),
      title: Text(member.realname),
      subtitle: Text(member.bio),
      trailing: IconButton(
        icon: const Icon(Icons.more_vert),
        onPressed: () {
          // TODO: Show member options
        },
      ),
    );
  }
}

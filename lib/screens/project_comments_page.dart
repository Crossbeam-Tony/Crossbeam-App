import 'package:flutter/material.dart';
import '../widgets/comments_widget.dart';

class ProjectCommentsPage extends StatelessWidget {
  final String projectId;

  const ProjectCommentsPage({super.key, required this.projectId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Comments'),
      ),
      body: CommentsWidget(
        entityType: 'project',
        entityId: projectId,
      ),
    );
  }
}

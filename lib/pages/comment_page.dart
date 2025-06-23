import 'package:flutter/material.dart';
import '../widgets/comments_widget.dart';

class CommentPage extends StatelessWidget {
  final String projectId;
  const CommentPage({super.key, required this.projectId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Comments'),
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
      ),
      body: CommentsWidget(projectId: projectId),
    );
  }
}

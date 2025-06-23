import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/data_service.dart';
import '../models/project.dart';
import '../models/user_profile.dart';
import '../shared/avatar.dart';
import '../screens/project_comments_page.dart';

class ProjectDetailsScreen extends StatefulWidget {
  final String projectId;

  const ProjectDetailsScreen({
    super.key,
    required this.projectId,
  });

  @override
  State<ProjectDetailsScreen> createState() => _ProjectDetailsScreenState();
}

class _ProjectDetailsScreenState extends State<ProjectDetailsScreen> {
  final TextEditingController _commentController = TextEditingController();
  final List<Map<String, dynamic>> _comments = [];
  final bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadComments();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _loadComments() {
    // Load existing comments for this project
    _comments.addAll([
      {
        'id': '1',
        'user': 'Sarah Chen',
        'comment':
            'This looks amazing! Would love to collaborate on this project.',
        'time': DateTime.now().subtract(const Duration(hours: 2)),
        'likes': 3,
      },
      {
        'id': '2',
        'user': 'Mike Johnson',
        'comment': 'Great concept! The cinematography is going to be stunning.',
        'time': DateTime.now().subtract(const Duration(hours: 4)),
        'likes': 1,
      },
      {
        'id': '3',
        'user': 'Alex Rivera',
        'comment': 'Count me in for the production team!',
        'time': DateTime.now().subtract(const Duration(hours: 6)),
        'likes': 2,
      },
    ]);
  }

  void _addComment() {
    if (_commentController.text.trim().isNotEmpty) {
      setState(() {
        _comments.insert(0, {
          'id': DateTime.now().millisecondsSinceEpoch.toString(),
          'user': 'You',
          'comment': _commentController.text.trim(),
          'time': DateTime.now(),
          'likes': 0,
        });
      });
      _commentController.clear();
      FocusScope.of(context).unfocus();
    }
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  @override
  Widget build(BuildContext context) {
    final dataService = Provider.of<DataService>(context, listen: false);

    return FutureBuilder<Project?>(
      future: dataService.getProjectById(widget.projectId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Project Not Found'),
            ),
            body: const Center(
              child: Text('The requested project could not be found.'),
            ),
          );
        }

        final project = snapshot.data!;

        return Scaffold(
          appBar: AppBar(
            title: Text(project.title),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  // TODO: Implement project editing
                },
              ),
            ],
          ),
          body: Column(
            children: [
              // Project details section
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Image.network(
                        project.image,
                        width: double.infinity,
                        height: 200,
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
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              project.title,
                              style: Theme.of(context).textTheme.headlineMedium,
                            ),
                            const SizedBox(height: 8),
                            Chip(
                              label: Text(
                                  project.status.toString().split('.').last),
                              backgroundColor: _getStatusColor(project.status),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4.0),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              project.description,
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                            const SizedBox(height: 24),
                            Text(
                              'Project Details',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 8),
                            _buildDetailRow(
                                context, 'Category', project.category),
                            _buildDetailRow(
                                context, 'Progress', '${project.progress}%'),
                            _buildDetailRow(context, 'Due Date',
                                project.dueDate.toString()),
                            const SizedBox(height: 24),
                            Text(
                              'Team Members',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 4.0,
                              runSpacing: 4.0,
                              children: project.members.map((memberId) {
                                return FutureBuilder<UserProfile?>(
                                  future: dataService.getUserProfile(memberId),
                                  builder: (context, snapshot) {
                                    if (!snapshot.hasData ||
                                        snapshot.data == null) {
                                      return const SizedBox.shrink();
                                    }
                                    final member = snapshot.data!;
                                    return Chip(
                                      avatar: ClipOval(
                                        child: Image.network(
                                          member.avatarUrl,
                                          width: 40,
                                          height: 40,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      label: Text(member.name),
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(4.0),
                                      ),
                                    );
                                  },
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 24),
                            // Comments section
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Comments',
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            ProjectCommentsPage(
                                          projectId: project.id,
                                        ),
                                      ),
                                    );
                                  },
                                  child: const Text('View All'),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            // Recent comments preview
                            ..._comments.take(3).map(
                                (comment) => _buildCommentPreview(comment)),
                            if (_comments.length > 3)
                              Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: TextButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            ProjectCommentsPage(
                                          projectId: project.id,
                                        ),
                                      ),
                                    );
                                  },
                                  child: Text(
                                      'View ${_comments.length - 3} more comments'),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Comment input section
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  border: Border(
                    top: BorderSide(
                      color: Colors.grey.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: TextField(
                          controller: _commentController,
                          decoration: const InputDecoration(
                            hintText: 'Add a comment...',
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                          maxLines: null,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: _addComment,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.purple,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(
                          Icons.send,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCommentPreview(Map<String, dynamic> comment) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: Colors.purple,
            child: Text(
              comment['user'][0].toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      comment['user'],
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _formatTime(comment['time']),
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  comment['comment'],
                  style: const TextStyle(
                    fontSize: 12,
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(ProjectStatus status) {
    switch (status) {
      case ProjectStatus.planning:
        return Colors.orange.shade100;
      case ProjectStatus.inProgress:
        return Colors.blue.shade100;
      case ProjectStatus.review:
        return Colors.purple.shade100;
      case ProjectStatus.completed:
        return Colors.green.shade100;
    }
  }
}

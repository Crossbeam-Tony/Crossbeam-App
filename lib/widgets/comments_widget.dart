import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/project_service.dart';
import '../models/project.dart';
import '../services/auth_service.dart';

class CommentsWidget extends StatefulWidget {
  final String projectId;
  final Project? project; // Pass the project directly if available

  const CommentsWidget({
    super.key,
    required this.projectId,
    this.project,
  });

  @override
  State<CommentsWidget> createState() => _CommentsWidgetState();
}

class _CommentsWidgetState extends State<CommentsWidget> {
  final TextEditingController _controller = TextEditingController();
  late final ProjectService _projectService;
  List<Map<String, dynamic>> _comments = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Initialize ProjectService with AuthService from Provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authService = Provider.of<AuthService>(context, listen: false);
      _projectService = ProjectService(authService);
      _loadComments();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadComments() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // If we have a project passed in, use its comments
      if (widget.project != null) {
        setState(() {
          _comments = widget.project!.comments;
          _isLoading = false;
        });
      } else {
        // Otherwise, fetch the project to get its comments
        final projects = await _projectService.fetchProjects();
        final project = projects.firstWhere(
          (p) => p.id == widget.projectId,
          orElse: () => throw Exception('Project not found'),
        );

        setState(() {
          _comments = project.comments;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading comments: $e');
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load comments: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _submitComment() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await _projectService.addComment(widget.projectId, text);

      _controller.clear();
      await _loadComments(); // Refresh comments

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Comment added successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      print('Error submitting comment: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error adding comment: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading && _comments.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        // Comments list
        if (_comments.isNotEmpty)
          Expanded(
            child: ListView.builder(
              itemCount: _comments.length,
              itemBuilder: (context, index) {
                final comment = _comments[index];
                return _buildCommentTile(comment);
              },
            ),
          )
        else
          const Expanded(
            child: Center(
              child: Text(
                'No comments yet. Be the first to comment!',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                ),
              ),
            ),
          ),

        // Comment input
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            border: Border(
              top: BorderSide(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
              ),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: const InputDecoration(
                    hintText: 'Add a comment...',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  maxLines: null,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _submitComment(),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.send),
                onPressed: _isLoading ? null : _submitComment,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCommentTile(Map<String, dynamic> comment) {
    final commentText = comment['comment'] as String? ?? '';
    final createdAt = comment['created_at'] as String?;
    final userId = comment['user_id'] as String?;

    DateTime? commentTime;
    if (createdAt != null) {
      try {
        commentTime = DateTime.parse(createdAt);
      } catch (e) {
        commentTime = DateTime.now();
      }
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context)
            .colorScheme
            .surfaceContainerHighest
            .withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor:
                    Theme.of(context).colorScheme.primary.withOpacity(0.2),
                child: Text(
                  userId?.substring(0, 2).toUpperCase() ?? 'U',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'User ${userId?.substring(0, 8) ?? 'Unknown'}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    if (commentTime != null)
                      Text(
                        _formatTimeAgo(commentTime),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withOpacity(0.6),
                            ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            commentText,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  String _formatTimeAgo(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}

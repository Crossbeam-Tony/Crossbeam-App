import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/project.dart';
import '../../models/comment.dart';
import '../../services/project_service.dart';
import '../../services/comment_service.dart';
import '../../services/auth_service.dart';
import '../../widgets/project_card.dart';
import 'project_form.dart';
import 'package:go_router/go_router.dart';
import '../../components/sliding_card.dart';

enum ActionPriority { primary, secondary, tertiary }

class ProjectsPage extends StatefulWidget {
  const ProjectsPage({super.key});

  @override
  State<ProjectsPage> createState() => _ProjectsPageState();
}

class _ProjectsPageState extends State<ProjectsPage> {
  late Future<List<Project>> _projectsFuture;
  late CommentService _commentService;
  final Map<String, Future<List<Comment>>> _commentsFutures = {};

  @override
  void initState() {
    super.initState();
    final authService = Provider.of<AuthService>(context, listen: false);
    _commentService = CommentService(authService);
    _projectsFuture =
        Provider.of<ProjectService>(context, listen: false).fetchProjects();
  }

  void _refreshProjects() {
    setState(() {
      _projectsFuture =
          Provider.of<ProjectService>(context, listen: false).fetchProjects();
      _commentsFutures.clear(); // Clear cached comments
    });
  }

  Future<List<Comment>> _getCommentsForProject(String projectId) {
    if (!_commentsFutures.containsKey(projectId)) {
      _commentsFutures[projectId] =
          _commentService.fetchCommentsForProject(projectId);
    }
    return _commentsFutures[projectId]!;
  }

  void _navigateToCreateProject() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            controller: scrollController,
            child: ProjectForm(
              onSubmit: (project) {
                Navigator.of(context).pop();
                _refreshProjects();
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRightBottomLayer(
      BuildContext context, Project project, double slideProgress) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context)
                .colorScheme
                .surfaceContainerHighest
                .withValues(alpha: 0.3),
            Theme.of(context).colorScheme.surface,
          ],
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Primary actions (large)
            _buildActionButton(Icons.edit, 'Edit', () {
              // TODO: Navigate to edit project page
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Edit project feature coming soon!')),
              );
            }, ActionPriority.primary),
            const SizedBox(height: 8),
            _buildActionButton(Icons.delete_outline, 'Delete', () {
              // TODO: Delete project functionality
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Delete project feature coming soon!')),
              );
            }, ActionPriority.primary),
            const SizedBox(height: 12),
            // Secondary actions (medium)
            _buildActionButton(Icons.share, 'Share', () {
              // TODO: Share project functionality
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Share project feature coming soon!')),
              );
            }, ActionPriority.secondary),
            const SizedBox(height: 6),
            _buildActionButton(Icons.bookmark_border, 'Save', () {
              // TODO: Save project functionality
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Save project feature coming soon!')),
              );
            }, ActionPriority.secondary),
            const SizedBox(height: 12),
            // Tertiary actions (small)
            _buildActionButton(Icons.person_add, 'Add Member', () {
              // TODO: Add member functionality
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Add member feature coming soon!')),
              );
            }, ActionPriority.tertiary),
          ],
        ),
      ),
    );
  }

  Widget _buildLeftBottomLayer(
      BuildContext context, Project project, double slideProgress) {
    return GestureDetector(
      onTap: () {
        context.push('/projects/${project.id}', extra: project);
      },
      child: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context)
                  .colorScheme
                  .secondaryContainer
                  .withValues(alpha: 0.1),
              Theme.of(context).colorScheme.surface,
            ],
          ),
        ),
        child: CustomPaint(
          painter: _PurpleGradientOutlinePainter(progress: slideProgress),
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .primaryContainer
                      .withValues(alpha: 0.2),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(4),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.comment_outlined,
                        size: 18, color: Theme.of(context).colorScheme.primary),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Comments',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Flexible(
                      child: Icon(
                        Icons.arrow_forward_ios,
                        size: 14,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
              // Comments content
              Expanded(
                child: FutureBuilder<List<Comment>>(
                  future: _getCommentsForProject(project.id),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          'Error loading comments: ${snapshot.error}',
                          style: TextStyle(color: Colors.red[600]),
                        ),
                      );
                    }

                    final comments = snapshot.data ?? [];

                    if (comments.isEmpty) {
                      return const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.comment_outlined,
                              size: 32,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 8),
                            Text(
                              'No comments yet',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return SingleChildScrollView(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: comments.map((comment) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: _buildCommentItem(
                              comment.userId,
                              comment.content,
                              _formatTimeAgo(comment.createdAt),
                            ),
                          );
                        }).toList(),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label, VoidCallback onPressed,
      ActionPriority priority) {
    double iconSize;
    double fontSize;
    EdgeInsets padding;

    switch (priority) {
      case ActionPriority.primary:
        iconSize = 24;
        fontSize = 16;
        padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 12);
        break;
      case ActionPriority.secondary:
        iconSize = 20;
        fontSize = 14;
        padding = const EdgeInsets.symmetric(horizontal: 12, vertical: 8);
        break;
      case ActionPriority.tertiary:
        iconSize = 18;
        fontSize = 12;
        padding = const EdgeInsets.symmetric(horizontal: 8, vertical: 6);
        break;
    }

    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        padding: padding,
      ),
      child: Row(
        children: [
          Icon(icon, size: iconSize),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(fontSize: fontSize),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentItem(String userId, String comment, String timeAgo) {
    // For now, show a shortened user ID. Later we can fetch user names from profiles
    final displayName =
        userId.length > 8 ? '${userId.substring(0, 8)}...' : userId;

    return Container(
      padding: const EdgeInsets.all(8.0),
      margin: const EdgeInsets.only(bottom: 8.0),
      decoration: BoxDecoration(
        color: Theme.of(context)
            .colorScheme
            .surfaceContainerHighest
            .withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                displayName,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
              ),
              const Spacer(),
              Text(
                timeAgo,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontSize: 10,
                      color: Colors.grey[600],
                    ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            comment,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontSize: 12,
                ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Projects'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshProjects,
          ),
        ],
      ),
      body: FutureBuilder<List<Project>>(
        future: _projectsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.work_outline,
                    size: 64,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No projects found',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Create your first project to get started!',
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            );
          }

          final projects = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: projects.length,
            itemBuilder: (context, index) {
              final project = projects[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: SlidingCard(
                  height: 200,
                  topLayer: (slideProgress) => ProjectCard(project: project),
                  rightBottomLayer: (slideProgress) =>
                      _buildRightBottomLayer(context, project, slideProgress),
                  leftBottomLayer: (slideProgress) =>
                      _buildLeftBottomLayer(context, project, slideProgress),
                  onCardOpen: () {
                    // Handle card open
                  },
                  onCardClose: () {
                    // Handle card close
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToCreateProject,
        tooltip: 'Create Project',
        child: const Icon(Icons.add),
      ),
    );
  }

  String _formatTimeAgo(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays > 0) {
      return '${diff.inDays}d ago';
    } else if (diff.inHours > 0) {
      return '${diff.inHours}h ago';
    } else if (diff.inMinutes > 0) {
      return '${diff.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}

class _PurpleGradientOutlinePainter extends CustomPainter {
  final double progress;

  _PurpleGradientOutlinePainter({
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (progress == 0.0 || size.width <= 0 || size.height <= 0) return;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final gradient = LinearGradient(
      colors: [
        Colors.purple.withValues(alpha: 0.8),
        Colors.purple.withValues(alpha: 0.4),
        Colors.purple.withValues(alpha: 0.1),
      ],
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      stops: const [0.0, 0.5, 1.0],
    );

    paint.shader =
        gradient.createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      const Radius.circular(4),
    );

    canvas.drawRRect(rect, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return oldDelegate is _PurpleGradientOutlinePainter &&
        oldDelegate.progress != progress;
  }
}

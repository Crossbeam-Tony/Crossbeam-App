import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/project.dart';
import '../models/user_profile.dart';
import '../services/data_service.dart';
import '../widgets/avatar.dart';
import '../screens/user_profile_screen.dart';
import 'package:go_router/go_router.dart';
import '../shared/user_link.dart';
import '../utils/safe_network_image.dart';

class ProjectCard extends StatefulWidget {
  final Project project;
  final double? width;
  final double? height;

  const ProjectCard({
    super.key,
    required this.project,
    this.width,
    this.height,
  });

  @override
  State<ProjectCard> createState() => _ProjectCardState();
}

class _ProjectCardState extends State<ProjectCard>
    with SingleTickerProviderStateMixin {
  late Future<List<UserProfile?>> _membersFuture;
  late AnimationController _progressController;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _membersFuture = _fetchMembers();

    // Setup progress animation
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: widget.project.progress,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeInOut,
    ));
    _progressController.forward();
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  Future<List<UserProfile?>> _fetchMembers() async {
    final dataService = Provider.of<DataService>(context, listen: false);
    final memberFutures = widget.project.members
        .map((memberId) => dataService.getUserProfile(memberId))
        .toList();
    return Future.wait(memberFutures);
  }

  Color _getStatusColor() {
    switch (widget.project.status) {
      case ProjectStatus.planning:
        return Colors.blue;
      case ProjectStatus.inProgress:
        return Colors.orange;
      case ProjectStatus.review:
        return Colors.purple;
      case ProjectStatus.completed:
        return Colors.green;
    }
  }

  String _getStatusText() {
    switch (widget.project.status) {
      case ProjectStatus.planning:
        return 'Planning';
      case ProjectStatus.inProgress:
        return 'In Progress';
      case ProjectStatus.review:
        return 'In Review';
      case ProjectStatus.completed:
        return 'Completed';
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.push('/project/${widget.project.id}');
      },
      child: Container(
        width: widget.width ?? double.infinity,
        height: widget.height,
        margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          color: Theme.of(context).colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            // Top section with image (60% of card height)
            Container(
              height: 200.0, // Reduced from 240.0 to 200.0
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4.0),
                  topRight: Radius.circular(4.0),
                ),
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(4),
                ),
                child: widget.project.imageUrl != null &&
                        widget.project.imageUrl!.isNotEmpty
                    ? Image.network(
                        widget.project.imageUrl!,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                        errorBuilder: (context, error, stackTrace) =>
                            _buildFallbackImage(),
                      )
                    : _buildFallbackImage(),
              ),
            ),
            // Bottom section with content
            Expanded(
              child: SingleChildScrollView(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12.0, vertical: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.project.title,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  widget.project.description,
                                  style: Theme.of(context).textTheme.bodySmall,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: _getStatusColor().withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              _getStatusText(),
                              style: TextStyle(
                                color: _getStatusColor(),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .colorScheme
                                  .primary
                                  .withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              widget.project.category ?? 'Uncategorized',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            Icons.calendar_today,
                            size: 14,
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            widget.project.dueDate != null
                                ? 'Due ${widget.project.dueDate!.day}/${widget.project.dueDate!.month}/${widget.project.dueDate!.year}'
                                : 'No due date',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                                  color:
                                      Theme.of(context).colorScheme.secondary,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Progress',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              AnimatedBuilder(
                                animation: _progressAnimation,
                                builder: (context, child) {
                                  return Text(
                                    '${(_progressAnimation.value * 100).toInt()}%',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                  );
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          AnimatedBuilder(
                            animation: _progressAnimation,
                            builder: (context, child) {
                              return LinearProgressIndicator(
                                value: _progressAnimation.value,
                                backgroundColor: Theme.of(context)
                                    .colorScheme
                                    .surfaceContainerHighest,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Theme.of(context).colorScheme.primary,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          FutureBuilder<List<UserProfile?>>(
                            future: _membersFuture,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const SizedBox(
                                    height: 24,
                                    width: 24,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2));
                              }
                              if (!snapshot.hasData || snapshot.data == null) {
                                return const SizedBox.shrink();
                              }
                              final members = snapshot.data!
                                  .whereType<UserProfile>()
                                  .toList();
                              return Row(
                                children: [
                                  ...members.take(3).map((member) {
                                    return Padding(
                                      padding: const EdgeInsets.only(right: 4),
                                      child: GestureDetector(
                                        onTap: () => context
                                            .push('/profile/${member.id}'),
                                        child: AvatarWidget(
                                          userId: member.id,
                                          radius: 12,
                                          url: member.avatarUrl,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                  if (members.length > 3)
                                    Container(
                                      width: 24,
                                      height: 24,
                                      decoration: BoxDecoration(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .surfaceContainerHighest,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Center(
                                        child: Text(
                                          '+${members.length - 3}',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall
                                              ?.copyWith(
                                                fontWeight: FontWeight.bold,
                                              ),
                                        ),
                                      ),
                                    ),
                                ],
                              );
                            },
                          ),
                          Text(
                            '${widget.project.members.length} members',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFallbackImage() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Theme.of(context)
          .colorScheme
          .surfaceContainerHighest
          .withOpacity(0.3),
      child: Icon(
        Icons.work_outline,
        size: 48,
        color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.3),
      ),
    );
  }
}

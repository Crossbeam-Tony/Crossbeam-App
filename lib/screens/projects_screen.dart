import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/data_service.dart';
import '../models/project.dart';
import 'project_details_screen.dart';
import '../shared/avatar.dart';
import 'package:go_router/go_router.dart';

class ProjectsScreen extends StatelessWidget {
  const ProjectsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dataService = Provider.of<DataService>(context, listen: false);
    final projects = dataService.projects;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Projects'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // TODO: Implement new project creation
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: projects.length,
        itemBuilder: (context, index) {
          final project = projects[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: InkWell(
              onTap: () {
                context.push('/projects/${project.id}');
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.network(
                    project.imageUrl!,
                    height: 200,
                    width: double.infinity,
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
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                project.title,
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: _getStatusColor(project.status)
                                    .withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                project.status.toString().split('.').last,
                                style: TextStyle(
                                  color: _getStatusColor(project.status),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          project.description,
                          style: Theme.of(context).textTheme.bodyMedium,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Icon(Icons.category,
                                size: 16,
                                color: Theme.of(context).colorScheme.secondary),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                project.category,
                                style: TextStyle(
                                  color:
                                      Theme.of(context).colorScheme.secondary,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Icon(Icons.calendar_today,
                                size: 16,
                                color: Theme.of(context).colorScheme.secondary),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                'Due ${project.dueDate.day}/${project.dueDate.month}/${project.dueDate.year}',
                                style: TextStyle(
                                  color:
                                      Theme.of(context).colorScheme.secondary,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.people,
                                    size: 16,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .secondary),
                                const SizedBox(width: 4),
                                Text(
                                  '${project.members.length} members',
                                  style: TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.secondary,
                                  ),
                                ),
                              ],
                            ),
                            Flexible(
                              child: Text(
                                '${(project.progress * 100).toInt()}% complete',
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        LinearProgressIndicator(
                          value: project.progress,
                          backgroundColor: Theme.of(context)
                              .colorScheme
                              .surfaceContainerHighest,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Color _getStatusColor(ProjectStatus status) {
    switch (status) {
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
}

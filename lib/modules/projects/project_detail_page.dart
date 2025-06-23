import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../models/project.dart';
import '../../models/user_profile.dart';
import '../../services/data_service.dart';
import '../../shared/avatar.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../../services/storage_service.dart';
import '../../services/project_service.dart';

class ProjectDetailPage extends StatefulWidget {
  final String projectId;
  const ProjectDetailPage({super.key, required this.projectId});

  @override
  State<ProjectDetailPage> createState() => _ProjectDetailPageState();
}

class _ProjectDetailPageState extends State<ProjectDetailPage> {
  String? selectedTag;
  late Future<Project?> _projectFuture;
  final ImagePicker _picker = ImagePicker();
  final StorageService _storageService = StorageService();
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    final dataService = Provider.of<DataService>(context, listen: false);
    _projectFuture = dataService.getProjectById(widget.projectId);
  }

  void _updateSelectedTag(String? tag) {
    setState(() {
      selectedTag = tag;
    });
  }

  Future<void> _pickAndUploadImage(Project project) async {
    final tagToUpload = selectedTag;
    if (tagToUpload == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a tag before uploading.')),
      );
      return;
    }

    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return;

    setState(() => _isUploading = true);

    try {
      final file = File(pickedFile.path);
      final imageUrl =
          await _storageService.uploadImage(file, project.id, tagToUpload);

      final projectService =
          Provider.of<ProjectService>(context, listen: false);
      await projectService.addImageToProject(project.id, tagToUpload, imageUrl);

      // Refresh the project data
      setState(() {
        _projectFuture = Provider.of<DataService>(context, listen: false)
            .getProjectById(widget.projectId);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Image uploaded successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Upload failed: $e')),
      );
    } finally {
      setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Project?>(
      future: _projectFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Error')),
            body: const Center(child: Text('Project not found')),
          );
        }

        final project = snapshot.data!;
        final tags = project.buildTags;
        final allImages =
            project.imagesByTag.values.expand((list) => list).toList();
        final images =
            selectedTag != null && project.imagesByTag[selectedTag!] != null
                ? project.imagesByTag[selectedTag!]!.take(20).toList()
                : allImages.take(20).toList();

        return Scaffold(
          appBar: AppBar(
            title: Text(project.title),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  // Navigate to the edit page
                  context.push('/project/${project.id}/edit');
                },
              ),
            ],
          ),
          body: Row(
            children: [
              // Sidebar
              Container(
                width: 160,
                color: Theme.of(context).colorScheme.surface,
                child: ListView(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  children: [
                    TextButton(
                      onPressed: () => _updateSelectedTag(null),
                      style: TextButton.styleFrom(
                        foregroundColor: selectedTag == null
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.onSurface,
                      ),
                      child: const Align(
                        alignment: Alignment.centerLeft,
                        child: Text('All Images'),
                      ),
                    ),
                    ...tags.map((tag) => TextButton(
                          onPressed: () => _updateSelectedTag(tag),
                          style: TextButton.styleFrom(
                            foregroundColor: selectedTag == tag
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context).colorScheme.onSurface,
                          ),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(tag, overflow: TextOverflow.ellipsis),
                          ),
                        )),
                  ],
                ),
              ),
              // Main content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Main project image and overview
                      Container(
                        height: 200,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.grey[300],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: allImages.isNotEmpty
                              ? Image.network(
                                  allImages.first,
                                  fit: BoxFit.cover,
                                )
                              : Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        Colors.purple.withOpacity(0.3),
                                        Colors.indigo.withOpacity(0.3),
                                      ],
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.work_outline,
                                    size: 64,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Project title and description
                      Text(
                        project.title,
                        style:
                            Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        project.description,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withOpacity(0.7),
                            ),
                      ),
                      const SizedBox(height: 16),

                      // Collaboration Data Section - more compact
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.group,
                                    color: Colors.purple, size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  'Collaboration',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Expanded(
                                    child: _buildCollabStat(context, 'Members',
                                        project.members.length)),
                                Expanded(
                                    child: _buildCollabStat(context, 'Progress',
                                        '${(project.progress * 100).toInt()}%')),
                                Expanded(
                                    child: _buildCollabStat(context, 'Due',
                                        _formatDate(project.dueDate))),
                                Expanded(
                                    child: _buildCollabStat(context, 'Status',
                                        project.status.name)),
                              ],
                            ),
                            const SizedBox(height: 12),
                            // Team Members - more compact
                            Text(
                              'Team Members',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w500,
                                  ),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 6,
                              runSpacing: 4,
                              children: project.members.map((memberId) {
                                return FutureBuilder<UserProfile?>(
                                  future: Provider.of<DataService>(context,
                                          listen: false)
                                      .getUserProfile(memberId),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return const Chip(label: Text('...'));
                                    }
                                    if (!snapshot.hasData ||
                                        snapshot.data == null) {
                                      return const Chip(label: Text('Unknown'));
                                    }
                                    final user = snapshot.data!;
                                    return Chip(
                                      avatar: Avatar(
                                        imageUrl: user.avatarUrl,
                                        size: 20,
                                        userId: user.id,
                                      ),
                                      label: Text(
                                        user.name,
                                        style: const TextStyle(fontSize: 11),
                                      ),
                                      backgroundColor:
                                          Theme.of(context).colorScheme.surface,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 4),
                                    );
                                  },
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Project images grid - more compact
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.photo_library,
                                    color: Colors.purple, size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  'Project Images',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                                const Spacer(),
                                if (_isUploading)
                                  const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2),
                                  )
                                else
                                  IconButton(
                                    icon: const Icon(Icons.upload_file),
                                    onPressed: () =>
                                        _pickAndUploadImage(project),
                                    tooltip: 'Upload Image',
                                  ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Expanded(
                              child: GridView.builder(
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3,
                                  crossAxisSpacing: 6,
                                  mainAxisSpacing: 6,
                                  childAspectRatio: 1,
                                ),
                                itemCount: images.length,
                                itemBuilder: (context, index) {
                                  return ClipRRect(
                                    borderRadius: BorderRadius.circular(6),
                                    child: Image.network(
                                      images[index],
                                      fit: BoxFit.cover,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Collaborate button - more compact
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.group_add),
                          label: const Text('Collaborate'),
                          onPressed: () {
                            // TODO: Implement collaboration request logic
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Collaboration Request'),
                                content: const Text(
                                    'Send a collaboration request for this project.'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('Cancel'),
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                            content: Text(
                                                'Collaboration request sent!')),
                                      );
                                    },
                                    child: const Text('Send'),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCollabStat(BuildContext context, String label, dynamic value) {
    return Column(
      children: [
        Text(
          value.toString(),
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontSize: 10,
              ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(now);

    if (difference.inDays > 0) {
      return '${difference.inDays}d left';
    } else if (difference.inDays == 0) {
      return 'Due today';
    } else {
      return 'Overdue';
    }
  }
}

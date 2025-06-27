import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/project.dart';
import '../../services/auth_service.dart';
import '../../services/project_service.dart';

class ProjectForm extends StatefulWidget {
  final Project? project;
  final String? projectId;
  final Function(Project) onSubmit;

  const ProjectForm(
      {super.key, this.project, this.projectId, required this.onSubmit});

  @override
  State<ProjectForm> createState() => _ProjectFormState();
}

class _ProjectFormState extends State<ProjectForm> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _tagsController = TextEditingController();
  late final ProjectService _projectService;
  List<String> _tags = [];
  String _status = 'planning';
  List<String> _images = [];

  @override
  void initState() {
    super.initState();
    final authService = Provider.of<AuthService>(context, listen: false);
    _projectService = ProjectService(authService);

    if (widget.project != null) {
      _loadProjectData(widget.project!);
    } else if (widget.projectId != null) {
      _fetchAndLoadProjectData(widget.projectId!);
    }
  }

  void _loadProjectData(Project project) {
    _titleController.text = project.title;
    _descriptionController.text = project.description;
    _tagsController.text = project.tags?.join(', ') ?? '';
    _tags = project.tags ?? [];
    _status = project.status ?? 'planning';
    _images = project.images ?? [];
  }

  Future<void> _fetchAndLoadProjectData(String projectId) async {
    final project = await _projectService.getProjectById(projectId);
    if (project != null) {
      setState(() {
        _loadProjectData(project);
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  void _parseTags() {
    final tagText = _tagsController.text.trim();
    if (tagText.isNotEmpty) {
      _tags = tagText
          .split(',')
          .map((tag) => tag.trim())
          .where((tag) => tag.isNotEmpty)
          .toList();
    } else {
      _tags = [];
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      _parseTags();
      final authService = Provider.of<AuthService>(context, listen: false);
      final currentUser = authService.currentUser;
      if (currentUser == null) throw Exception('User not authenticated');

      final projectData = Project(
        id: widget.project?.id ?? '',
        userId: currentUser.id,
        title: _titleController.text,
        description: _descriptionController.text,
        status: _status,
        tags: _tags,
        images: _images,
        createdAt: widget.project?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      if (widget.project != null) {
        await _projectService.updateProject(projectData);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Project updated successfully!')),
        );
      } else {
        await _projectService.createProject(projectData);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Project created successfully!')),
        );
      }

      widget.onSubmit(projectData);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            widget.project != null ? 'Edit Project' : 'Create New Project',
            style: Theme.of(context).textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),

          TextFormField(
            controller: _titleController,
            decoration: const InputDecoration(
              labelText: 'Project Title',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter a project title';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          TextFormField(
            controller: _descriptionController,
            decoration: const InputDecoration(
              labelText: 'Description',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter a description';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          DropdownButtonFormField<String>(
            value: _status,
            decoration: const InputDecoration(
              labelText: 'Status',
              border: OutlineInputBorder(),
            ),
            items: const [
              DropdownMenuItem(value: 'planning', child: Text('Planning')),
              DropdownMenuItem(
                  value: 'in-progress', child: Text('In Progress')),
              DropdownMenuItem(value: 'review', child: Text('Review')),
              DropdownMenuItem(value: 'completed', child: Text('Completed')),
            ],
            onChanged: (value) {
              setState(() {
                _status = value!;
              });
            },
          ),
          const SizedBox(height: 16),

          TextFormField(
            controller: _tagsController,
            decoration: const InputDecoration(
              labelText: 'Tags (comma-separated)',
              border: OutlineInputBorder(),
              hintText: 'e.g., photography, workshop, community',
            ),
          ),
          const SizedBox(height: 16),

          // Images section
          if (_images.isNotEmpty) ...[
            Text('Images (${_images.length})',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            SizedBox(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _images.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Stack(
                      children: [
                        Image.network(
                          _images[index],
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                        ),
                        Positioned(
                          top: 4,
                          right: 4,
                          child: IconButton(
                            icon: const Icon(Icons.close, color: Colors.white),
                            onPressed: () => _removeImage(index),
                            style: IconButton.styleFrom(
                              backgroundColor: Colors.red,
                              padding: const EdgeInsets.all(4),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
          ],

          ElevatedButton(
            onPressed: _submitForm,
            child: Text(
                widget.project != null ? 'Update Project' : 'Create Project'),
          ),
        ],
      ),
    );
  }

  void _removeImage(int index) {
    setState(() {
      _images.removeAt(index);
    });
  }
}

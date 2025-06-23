import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../models/project.dart';
import '../../services/auth_service.dart';
import '../../services/project_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide Provider;

class ProjectForm extends StatefulWidget {
  final Project? project;
  final String? projectId; // Can be null for new projects
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
  final _imageUrlController = TextEditingController();
  final _categoryController = TextEditingController();
  final _locationController = TextEditingController();
  final _buildTagsController = TextEditingController();
  late final ProjectService _projectService;
  List<String> _selectedMembers = [];
  List<String> _buildTags = [];
  Map<String, List<String>> _imagesByTag = {};
  ProjectStatus _status = ProjectStatus.planning;
  bool _isSubmitting = false;

  // Image upload variables
  File? _selectedImage;
  bool _isUploadingImage = false;
  final ImagePicker _picker = ImagePicker();

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
    _imageUrlController.text = project.imageUrl ?? '';
    _categoryController.text = project.category;
    _locationController.text = project.location ?? '';
    _buildTagsController.text = project.buildTags.join(', ');
    _selectedMembers = project.members;
    _buildTags = project.buildTags;
    _imagesByTag = project.imagesByTag;
    _status = project.status;
  }

  Future<void> _fetchAndLoadProjectData(String projectId) async {
    // This assumes a method in ProjectService to get a project by ID
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
    _imageUrlController.dispose();
    _categoryController.dispose();
    _locationController.dispose();
    _buildTagsController.dispose();
    super.dispose();
  }

  Future<String?> _uploadImage(File imageFile) async {
    setState(() => _isUploadingImage = true);
    try {
      final fileName =
          'project_${DateTime.now().millisecondsSinceEpoch}_${imageFile.path.split('/').last}';
      final storage = Supabase.instance.client.storage.from('project-images');
      final res = await storage.upload(fileName, imageFile);
      if (res.isNotEmpty) {
        final publicUrl = storage.getPublicUrl(fileName);
        return publicUrl;
      }
    } catch (e) {
      print('Image upload error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Image upload failed: $e'),
            backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _isUploadingImage = false);
    }
    return null;
  }

  Future<void> _pickImage() async {
    final picked =
        await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (picked != null) {
      setState(() {
        _selectedImage = File(picked.path);
      });
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final authService = Provider.of<AuthService>(context, listen: false);
      final currentUser = authService.currentUser;

      if (currentUser == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please sign in to create a project'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      setState(() => _isSubmitting = true);

      try {
        String imageUrl = _imageUrlController.text;
        if (_selectedImage != null) {
          final uploadedUrl = await _uploadImage(_selectedImage!);
          if (uploadedUrl != null) {
            imageUrl = uploadedUrl;
          }
        }

        final buildTags = _buildTagsController.text
            .split(',')
            .map((tag) => tag.trim())
            .where((tag) => tag.isNotEmpty)
            .toList();

        final projectData = Project(
          id: widget.project?.id ?? '', // Use existing ID if editing
          title: _titleController.text,
          description: _descriptionController.text,
          category: _categoryController.text.isNotEmpty
              ? _categoryController.text
              : 'General',
          location: _locationController.text,
          imageUrl: imageUrl,
          ownerId: widget.project?.ownerId ?? currentUser.id,
          owner: widget.project?.owner ?? currentUser.name,
          ownerAvatar: widget.project?.ownerAvatar ?? currentUser.avatarUrl,
          members: _selectedMembers,
          status: _status,
          progress: widget.project?.progress ?? 0.0,
          dueDate: widget.project?.dueDate ??
              DateTime.now().add(const Duration(days: 30)),
          createdAt: widget.project?.createdAt ?? DateTime.now(),
          updatedAt: DateTime.now(),
          buildTags: buildTags,
          imagesByTag: _imagesByTag,
          comments: widget.project?.comments ?? [],
          image: widget.project?.image ?? '',
          userEmail: widget.project?.userEmail ?? currentUser.email,
        );

        if (widget.project != null) {
          await _projectService.updateProject(projectData);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Project updated successfully!')),
          );
        } else {
          final newProject = await _projectService.createProject(projectData);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Project created successfully!')),
          );
        }

        widget.onSubmit(projectData);
      } catch (e) {
        print('Error creating project: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating project: $e'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            controller: _titleController,
            decoration: const InputDecoration(
              labelText: 'Project Title',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a title';
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
              if (value == null || value.isEmpty) {
                return 'Please enter a description';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _categoryController,
            decoration: const InputDecoration(
              labelText: 'Category (optional)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _locationController,
            decoration: const InputDecoration(
              labelText: 'Location (optional)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _buildTagsController,
            decoration: const InputDecoration(
              labelText: 'Tech Stack (comma-separated)',
              border: OutlineInputBorder(),
              hintText: 'e.g., Flutter, Dart, Firebase',
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _imageUrlController,
            decoration: const InputDecoration(
              labelText: 'Image URL (optional)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _selectedImage != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: Image.file(_selectedImage!,
                          width: 80, height: 80, fit: BoxFit.cover),
                    )
                  : _imageUrlController.text.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: Image.network(_imageUrlController.text,
                              width: 80, height: 80, fit: BoxFit.cover),
                        )
                      : Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .colorScheme
                                .surfaceContainerHighest
                                .withOpacity(0.3),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Icon(Icons.work_outline,
                              size: 40,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant
                                  .withOpacity(0.3)),
                        ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _isUploadingImage ? null : _pickImage,
                  icon: const Icon(Icons.image),
                  label:
                      Text(_isUploadingImage ? 'Uploading...' : 'Pick Image'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _submitForm,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(
                      widget.project == null
                          ? 'Create Project'
                          : 'Update Project',
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

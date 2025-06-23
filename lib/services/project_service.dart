import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/project.dart';
import 'auth_service.dart';

class ProjectService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final AuthService _authService;

  ProjectService(this._authService);

  Future<List<Project>> fetchProjects() async {
    try {
      final response = await _supabase
          .from('projects')
          .select('*')
          .order('created_at', ascending: false);

      final data = response as List<dynamic>;
      return data.map((item) => Project.fromJson(item)).toList();
    } catch (error) {
      print('Error fetching projects: $error');
      // Return empty list instead of throwing to prevent app crash
      return [];
    }
  }

  Future<Project> createProject(Project project) async {
    final user = _authService.currentUser;
    if (user == null) throw Exception('User not authenticated');

    try {
      // Only send fields that exist in the database schema
      final projectData = {
        'title': project.title,
        'description': project.description,
        'user_id': user.id,
        'category': project.category,
        'location': project.location,
        'status': project.status.name,
        'progress': project.progress,
        'due_date': project.dueDate?.toIso8601String(),
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      // Only add optional fields if they exist in the database
      // These fields might not exist in your Supabase schema yet
      // try {
      //   projectData['build_tags'] = project.buildTags;
      //   projectData['members'] = project.members;
      //   projectData['images_by_tag'] = project.imagesByTag;
      //   projectData['comments'] = project.comments;
      // } catch (e) {
      //   print('Optional fields not available in database: $e');
      // }

      final response = await _supabase
          .from('projects')
          .insert(projectData)
          .select()
          .single();

      return Project.fromJson(response);
    } catch (error) {
      print('Error creating project: $error');
      throw Exception('Failed to create project: $error');
    }
  }

  Future<void> updateProject(Project project) async {
    final user = _authService.currentUser;
    if (user == null) throw Exception('User not authenticated');

    try {
      final updateData = {
        'title': project.title,
        'description': project.description,
        'category': project.category,
        'location': project.location,
        'status': project.status.name,
        'progress': project.progress,
        'due_date': project.dueDate?.toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      // Only add optional fields if they exist in the database
      // try {
      //   updateData['build_tags'] = project.buildTags;
      //   updateData['members'] = project.members;
      //   updateData['images_by_tag'] = project.imagesByTag;
      //   updateData['comments'] = project.comments;
      // } catch (e) {
      //   print('Optional fields not available in database: $e');
      // }

      await _supabase.from('projects').update(updateData).eq('id', project.id);
    } catch (error) {
      print('Error updating project: $error');
      throw Exception('Failed to update project: $error');
    }
  }

  Future<void> deleteProject(String projectId) async {
    final user = _authService.currentUser;
    if (user == null) throw Exception('User not authenticated');

    try {
      await _supabase.from('projects').delete().eq('id', projectId);
    } catch (error) {
      print('Error deleting project: $error');
      throw Exception('Failed to delete project: $error');
    }
  }

  Future<void> addComment(String projectId, String commentText) async {
    final user = _authService.currentUser;
    if (user == null) throw Exception('User not authenticated');

    try {
      // For now, just print the comment since the comments column might not exist
      print(
          'Comment would be added: $commentText to project $projectId by ${user.email}');

      // Uncomment this when the comments column is added to the database
      // final response = await _supabase
      //     .from('projects')
      //     .select('comments')
      //     .eq('id', projectId)
      //     .single();
      // final List<dynamic> comments = response['comments'] ?? [];
      // comments.add({
      //   'user': user.email,
      //   'text': commentText,
      //   'timestamp': DateTime.now().toIso8601String(),
      // });

      // await _supabase.from('projects').update({
      //   'comments': comments,
      //   'updated_at': DateTime.now().toIso8601String(),
      // }).eq('id', projectId);
    } catch (error) {
      print('Error adding comment: $error');
      throw Exception('Failed to add comment: $error');
    }
  }

  Future<Project?> getProjectById(String projectId) async {
    try {
      final response = await Supabase.instance.client
          .from('projects')
          .select()
          .eq('id', projectId)
          .single();
      return Project.fromJson(response);
    } catch (e) {
      print('Error fetching project: $e');
      return null;
    }
  }

  Future<void> addImageToProject(
      String projectId, String tag, String imageUrl) async {
    try {
      final project = await getProjectById(projectId);
      if (project == null) {
        throw Exception("Project not found");
      }
      final currentImages = project.imagesByTag;
      final tagImages = currentImages[tag] ?? [];
      tagImages.add(imageUrl);
      currentImages[tag] = tagImages;

      await Supabase.instance.client
          .from('projects')
          .update({'images_by_tag': currentImages}).eq('id', projectId);
    } catch (e) {
      print('Error adding image to project: $e');
      throw Exception('Failed to add image to project: $e');
    }
  }

  // Helper methods
  ProjectStatus _parseProjectStatus(String? status) {
    if (status == null) return ProjectStatus.planning;

    switch (status.toLowerCase()) {
      case 'inprogress':
        return ProjectStatus.inProgress;
      case 'review':
        return ProjectStatus.review;
      case 'completed':
        return ProjectStatus.completed;
      default:
        return ProjectStatus.planning;
    }
  }

  Map<String, List<String>> _parseImagesByTag(dynamic data) {
    if (data == null) return {};

    try {
      return Map<String, List<String>>.from(
        (data as Map).map(
          (key, value) => MapEntry(
            key as String,
            List<String>.from(value as List),
          ),
        ),
      );
    } catch (e) {
      return {};
    }
  }

  List<Map<String, dynamic>> _parseComments(List data) {
    try {
      return List<Map<String, dynamic>>.from(
          data.map((c) => c as Map<String, dynamic>));
    } catch (e) {
      return [];
    }
  }
}

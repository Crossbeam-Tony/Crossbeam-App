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
      return [];
    }
  }

  Future<Project> createProject(Project project) async {
    final user = _authService.currentUser;
    if (user == null) throw Exception('User not authenticated');

    try {
      final projectData = {
        'title': project.title,
        'description': project.description,
        'user_id': user.id,
        'status': project.status ?? 'planning',
        'tags': project.tags,
        'images': project.images,
      };

      final response = await _supabase
          .from('projects')
          .insert(projectData)
          .select()
          .single();

      return Project.fromJson(response);
    } catch (error) {
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
        'status': project.status,
        'tags': project.tags,
        'images': project.images,
        'updated_at': DateTime.now().toIso8601String(),
      };

      await _supabase.from('projects').update(updateData).eq('id', project.id);
    } catch (error) {
      throw Exception('Failed to update project: $error');
    }
  }

  Future<void> deleteProject(String projectId) async {
    final user = _authService.currentUser;
    if (user == null) throw Exception('User not authenticated');

    try {
      await _supabase.from('projects').delete().eq('id', projectId);
    } catch (error) {
      throw Exception('Failed to delete project: $error');
    }
  }

  Future<Project?> getProjectById(String projectId) async {
    try {
      final response = await _supabase
          .from('projects')
          .select()
          .eq('id', projectId)
          .single();
      return Project.fromJson(response);
    } catch (e) {
      return null;
    }
  }

  Future<void> addImageToProject(String projectId, String imageUrl) async {
    try {
      final project = await getProjectById(projectId);
      if (project == null) {
        throw Exception("Project not found");
      }

      final currentImages = project.images ?? [];
      currentImages.add(imageUrl);

      await _supabase
          .from('projects')
          .update({'images': currentImages}).eq('id', projectId);
    } catch (e) {
      throw Exception('Failed to add image to project: $e');
    }
  }

  Future<void> addTagToProject(String projectId, String tag) async {
    try {
      final project = await getProjectById(projectId);
      if (project == null) {
        throw Exception("Project not found");
      }

      final currentTags = project.tags ?? [];
      if (!currentTags.contains(tag)) {
        currentTags.add(tag);
      }

      await _supabase
          .from('projects')
          .update({'tags': currentTags}).eq('id', projectId);
    } catch (e) {
      throw Exception('Failed to add tag to project: $e');
    }
  }

  Future<void> removeTagFromProject(String projectId, String tag) async {
    try {
      final project = await getProjectById(projectId);
      if (project == null) {
        throw Exception("Project not found");
      }

      final currentTags = project.tags ?? [];
      currentTags.remove(tag);

      await _supabase
          .from('projects')
          .update({'tags': currentTags}).eq('id', projectId);
    } catch (e) {
      throw Exception('Failed to remove tag from project: $e');
    }
  }
}

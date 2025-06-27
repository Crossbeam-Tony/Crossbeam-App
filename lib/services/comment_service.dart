import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/comment.dart';
import 'auth_service.dart';

class CommentService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final AuthService _authService;

  CommentService(this._authService);

  Future<List<Comment>> fetchCommentsForProject(String projectId) async {
    try {
      final response = await _supabase
          .from('comments')
          .select('*')
          .eq('entity_type', 'project')
          .eq('entity_id', projectId)
          .order('created_at', ascending: false);

      final data = response as List<dynamic>;
      return data.map((item) => Comment.fromJson(item)).toList();
    } catch (error) {
      return [];
    }
  }

  Future<Comment> createComment(Comment comment) async {
    final user = _authService.currentUser;
    if (user == null) throw Exception('User not authenticated');

    try {
      final commentData = {
        'user_id': user.id,
        'entity_type': comment.entityType,
        'entity_id': comment.entityId,
        'content': comment.content,
      };

      final response = await _supabase
          .from('comments')
          .insert(commentData)
          .select()
          .single();

      return Comment.fromJson(response);
    } catch (error) {
      throw Exception('Failed to create comment: $error');
    }
  }

  Future<void> deleteComment(String commentId) async {
    final user = _authService.currentUser;
    if (user == null) throw Exception('User not authenticated');

    try {
      await _supabase.from('comments').delete().eq('id', commentId);
    } catch (error) {
      throw Exception('Failed to delete comment: $error');
    }
  }

  Future<Comment?> getCommentById(String commentId) async {
    try {
      final response = await _supabase
          .from('comments')
          .select()
          .eq('id', commentId)
          .single();
      return Comment.fromJson(response);
    } catch (e) {
      return null;
    }
  }
}

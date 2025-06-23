import 'package:supabase_flutter/supabase_flutter.dart';

class CommentService {
  static final _client = Supabase.instance.client;

  static Future<void> addComment({
    required String postId,
    required String content,
  }) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return;

    await _client.from('comments').insert({
      'user_id': userId,
      'post_id': postId,
      'content': content,
    });
  }

  static Future<List<Map<String, dynamic>>> fetchComments(String postId) async {
    final response = await _client
        .from('comments')
        .select('id, content, created_at, user_id')
        .eq('post_id', postId)
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }
}

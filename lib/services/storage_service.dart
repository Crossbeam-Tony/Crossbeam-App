import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

class StorageService {
  final SupabaseClient _client = Supabase.instance.client;
  final String _bucket = 'project-images';
  final String _avatarsBucket = 'avatars';

  Future<String> uploadImage(File file, String projectId, String tag) async {
    final fileExt = file.path.split('.').last;
    final fileName = '${const Uuid().v4()}.$fileExt';
    final filePath = 'projects/$projectId/$tag/$fileName';

    final res = await _client.storage.from(_bucket).upload(filePath, file);

    // Supabase storage upload doesn't throw an error on failure, it returns an empty string on error.
    if (res.isEmpty) {
      throw Exception('Upload failed. The result from Supabase was empty.');
    }

    return _client.storage.from(_bucket).getPublicUrl(filePath);
  }

  Future<String> uploadProfileImage(File file) async {
    final fileExt = file.path.split('.').last;
    final fileName = '${const Uuid().v4()}.$fileExt';
    final filePath = 'profiles/$fileName';

    final res = await _client.storage.from(_bucket).upload(filePath, file);

    // Supabase storage upload doesn't throw an error on failure, it returns an empty string on error.
    if (res.isEmpty) {
      throw Exception('Upload failed. The result from Supabase was empty.');
    }

    return _client.storage.from(_bucket).getPublicUrl(filePath);
  }

  /// Uploads the given [file] as the current user's avatar.
  /// Stores at path: `<userId>/avatar.png` and returns the public URL.
  Future<String> uploadAvatar(File file) async {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception('Not logged in');
    final path = '${user.id}/avatar.png';

    final res = await _client.storage.from(_avatarsBucket).upload(path, file);

    // Supabase storage upload doesn't throw an error on failure, it returns an empty string on error.
    if (res.isEmpty) {
      throw Exception(
          'Avatar upload failed. The result from Supabase was empty.');
    }

    return _client.storage.from(_avatarsBucket).getPublicUrl(path);
  }

  /// Deletes the current user's avatar file.
  Future<void> deleteAvatar() async {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception('Not logged in');
    final path = '${user.id}/avatar.png';

    try {
      await _client.storage.from(_avatarsBucket).remove([path]);
    } catch (e) {
      // Ignore errors if file doesn't exist
      print('Error deleting avatar: $e');
    }
  }

  /// Gets the current user's avatar URL if it exists
  Future<String?> getAvatarUrl() async {
    final user = _client.auth.currentUser;
    if (user == null) return null;
    final path = '${user.id}/avatar.png';

    try {
      return _client.storage.from(_avatarsBucket).getPublicUrl(path);
    } catch (e) {
      return null;
    }
  }
}

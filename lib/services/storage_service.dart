import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

class StorageService {
  final SupabaseClient _client = Supabase.instance.client;
  final String _bucket = 'project-images';

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
}

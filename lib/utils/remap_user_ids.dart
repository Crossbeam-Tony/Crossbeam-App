import 'dart:io';
import '../data/local_users.dart';

class UserIdRemapper {
  // Map of old user IDs to new user IDs
  static final Map<String, String> _idMapping = {
    // Add your old ID to new ID mappings here
    // Example: 'old_id_1': 'u1',
  };

  // Initialize the ID mapping from the local users list
  static void initializeMapping() {
    for (var i = 0; i < localUsers.length; i++) {
      final user = localUsers[i];
      _idMapping['old_id_${i + 1}'] = user.id;
    }
  }

  // Process all data files
  static Future<void> processAllFiles() async {
    initializeMapping();

    final dataFiles = [
      'lib/data/dummy_crews.dart',
      //'lib/data/dummy_projects.dart',
      'lib/data/dummy_marketplace.dart',
      'lib/data/dummy_crews_threads.dart',
      'lib/data/dummy_posts.dart',
      'lib/data/seed_events.dart',
      'lib/data/seed_projects.dart',
      'lib/data/seed_marketplace_items.dart',
      'lib/data/seed_listings.dart',
    ];

    for (final filePath in dataFiles) {
      try {
        final file = File(filePath);
        if (await file.exists()) {
          String content = await file.readAsString();

          // Find all string literals that might contain user IDs
          final stringPattern = RegExp(r"'u\d+'");
          final matches = stringPattern.allMatches(content);

          String newContent = content;
          for (final match in matches) {
            final oldString = match.group(0)!;
            final oldId =
                oldString.substring(1, oldString.length - 1); // Remove quotes

            if (_idMapping.containsKey(oldId)) {
              final newId = _idMapping[oldId]!;
              final newString = "'$newId'";
              newContent = newContent.replaceFirst(oldString, newString);
            }
          }

          // Write the updated content back to the file
          await file.writeAsString(newContent);
          print('Successfully processed $filePath');
        }
      } catch (e) {
        print('Error processing $filePath: $e');
      }
    }
  }
}

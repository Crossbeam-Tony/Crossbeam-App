import 'dart:io';

// Set the number of users currently in local_users.dart
const int userCount = 21; // Update this to match your actual user count

final files = [
  'lib/data/seed_events.dart',
  'lib/data/dummy_marketplace.dart',
];

final indexRegExp = RegExp(r'localUsers\[(\d+)\]');
final idRegExp = RegExp(r"'u(\d+)'", multiLine: true);

String remapIndices(String content) {
  return content.replaceAllMapped(indexRegExp, (match) {
    final idx = int.parse(match.group(1)!);
    final newIdx = idx % userCount;
    return 'localUsers[[0m$newIdx]';
  });
}

String remapIds(String content) {
  return content.replaceAllMapped(idRegExp, (match) {
    final idx = int.parse(match.group(1)!);
    final newIdx = ((idx - 1) % userCount) + 1;
    return "'u$newIdx'";
  });
}

void processFile(String path) {
  final file = File(path);
  if (!file.existsSync()) {
    print('File not found: $path');
    return;
  }
  String content = file.readAsStringSync();
  content = remapIndices(content);
  content = remapIds(content);
  file.writeAsStringSync(content);
  print('Remapped user references in $path');
}

void main() {
  for (final file in files) {
    processFile(file);
  }
}

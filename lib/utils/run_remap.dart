import 'remap_user_ids.dart';

void main() async {
  print('Starting user ID remapping process...');
  await UserIdRemapper.processAllFiles();
  print('User ID remapping completed!');
}

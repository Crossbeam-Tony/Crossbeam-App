import 'package:flutter_dotenv/flutter_dotenv.dart';

class Env {
  static String get appEnvironment =>
      dotenv.env['APP_ENVIRONMENT'] ?? 'development';
  static String get apiUrl => dotenv.env['API_URL'] ?? 'http://localhost:3000';
  static String get appName => dotenv.env['APP_NAME'] ?? 'Crossbeam';
  static String get wsUrl => dotenv.env['WS_URL'] ?? 'ws://localhost:3000';
  static String get storageUrl =>
      dotenv.env['STORAGE_URL'] ?? 'http://localhost:3000/storage';
  static String get appVersion => dotenv.env['APP_VERSION'] ?? '1.0.0';
  static String get appBuildNumber => dotenv.env['APP_BUILD_NUMBER'] ?? '1';

  static Future<void> load() async {
    await dotenv.load(fileName: '.env');
  }

  static String get(String key) {
    return dotenv.env[key] ?? '';
  }

  static bool getBool(String key) {
    return dotenv.env[key]?.toLowerCase() == 'true';
  }

  static int getInt(String key) {
    return int.tryParse(dotenv.env[key] ?? '0') ?? 0;
  }

  static double getDouble(String key) {
    return double.tryParse(dotenv.env[key] ?? '0.0') ?? 0.0;
  }
}

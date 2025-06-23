import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:temp_new_project_fixed/services/project_service.dart';
import 'package:temp_new_project_fixed/services/auth_service.dart';
import 'package:temp_new_project_fixed/services/data_service.dart';
import 'package:temp_new_project_fixed/services/theme_service.dart';
import 'app.dart';
import 'supabase_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeSupabase();
  final prefs = await SharedPreferences.getInstance();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => ThemeService(prefs)),
        ProxyProvider<AuthService, DataService>(
          update: (_, authService, __) => DataService(authService.currentUser),
        ),
        ProxyProvider<AuthService, ProjectService>(
          update: (_, authService, __) => ProjectService(authService),
        ),
      ],
      child: App(prefs: prefs),
    ),
  );
}

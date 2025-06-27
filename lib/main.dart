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

  final authService = AuthService();

  print('🔥🔥🔥 Starting app initialization... 🔥🔥🔥');

  // Listen for auth state changes as recommended in troubleshooting steps
  Supabase.instance.client.auth.onAuthStateChange.listen((data) {
    final event = data.event;
    final session = data.session;
    print('🔔 Auth state change: $event, session=$session');
    if (session != null) {
      print('🔔 User authenticated: ${session.user.email}');
      print('🔔 Email confirmed at: ${session.user.emailConfirmedAt}');
    }
  });

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => authService),
        ChangeNotifierProvider(create: (_) => ThemeService(prefs)),
        ChangeNotifierProvider(
            create: (_) => DataService(authService.currentUser)),
        ProxyProvider<AuthService, ProjectService>(
          update: (_, authService, __) => ProjectService(authService),
        ),
      ],
      child: App(prefs: prefs, authService: authService),
    ),
  );
}

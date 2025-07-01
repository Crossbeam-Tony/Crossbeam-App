import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:temp_new_project_fixed/services/project_service.dart';
import 'package:temp_new_project_fixed/services/auth_service.dart';
import 'package:temp_new_project_fixed/services/data_service.dart';
import 'package:temp_new_project_fixed/services/theme_service.dart';
import 'package:temp_new_project_fixed/providers/onboarding_provider.dart';
import 'app.dart';
import 'supabase_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeSupabase();
  final prefs = await SharedPreferences.getInstance();

  final authService = AuthService();
  final themeService = ThemeService(prefs);

  // Always set light mode and Crossbeam before app starts
  await themeService.fetchThemesFromDb();
  final crossbeamThemes = themeService.availableThemes
      .where((theme) =>
          theme.name.toLowerCase() == 'crossbeam' && theme.mode == 'light')
      .toList();
  if (crossbeamThemes.isNotEmpty) {
    final crossbeamTheme = crossbeamThemes.first;
    await themeService.setThemeAndMode(
        crossbeamTheme, false); // false = light mode
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => authService),
        ChangeNotifierProvider(create: (_) => themeService),
        ChangeNotifierProvider(
            create: (_) => DataService(authService.currentUser)),
        ChangeNotifierProvider(
            create: (_) => OnboardingProvider(authService, themeService)),
        ProxyProvider<AuthService, ProjectService>(
          update: (_, authService, __) => ProjectService(authService),
        ),
      ],
      child: App(prefs: prefs, authService: authService),
    ),
  );
}

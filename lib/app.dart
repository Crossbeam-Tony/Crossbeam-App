import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:go_router/go_router.dart';
import 'services/theme_service.dart';
import 'services/auth_service.dart';
import 'router.dart';

class App extends StatefulWidget {
  final SharedPreferences prefs;
  final AuthService authService;
  const App({super.key, required this.prefs, required this.authService});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  GoRouter? _router;

  @override
  void initState() {
    super.initState();
    print('  App initState called');
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeService>(
      builder: (context, themeService, child) {
        return MaterialApp.router(
          title: 'Crossbeam',
          debugShowCheckedModeBanner: false,
          theme: themeService.currentLightTheme,
          darkTheme: themeService.currentDarkTheme,
          themeMode: themeService.themeMode,
          routerConfig: _buildRouter(),
        );
      },
    );
  }

  GoRouter _buildRouter() {
    _router = AppRouter.createRouter(widget.authService);
    return _router!;
  }
}

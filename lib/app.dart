import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'services/theme_service.dart';
import 'services/auth_service.dart';
import 'services/data_service.dart';
import 'config/design_system.dart';
import 'router.dart';

class App extends StatelessWidget {
  final SharedPreferences prefs;
  const App({super.key, required this.prefs});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeService(prefs)),
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProxyProvider<AuthService, DataService>(
          create: (context) => DataService(null),
          update: (context, auth, previous) => DataService(auth.currentUser),
        ),
      ],
      child: Consumer<ThemeService>(
        builder: (context, themeService, child) {
          return Consumer<AuthService>(
            builder: (context, authService, child) {
              final mode = themeService.themeMode ?? ThemeMode.system;
              return MaterialApp.router(
                title: 'Crossbeam',
                theme: DesignSystem.lightTheme,
                darkTheme: DesignSystem.darkTheme,
                themeMode: mode,
                routerConfig: AppRouter.createRouter(authService),
                debugShowCheckedModeBanner: false,
              );
            },
          );
        },
      ),
    );
  }
}

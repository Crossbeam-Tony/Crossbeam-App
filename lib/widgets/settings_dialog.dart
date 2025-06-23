import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/theme_service.dart';

class SettingsDialog extends StatelessWidget {
  const SettingsDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final themeService = context.watch<ThemeService>();
    final currentTheme = themeService.themeMode;

    return AlertDialog(
      title: const Text('Settings'),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Theme',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            SegmentedButton<ThemeMode>(
              segments: const [
                ButtonSegment<ThemeMode>(
                  value: ThemeMode.system,
                  label: Text('System'),
                  icon: Icon(Icons.brightness_auto),
                ),
                ButtonSegment<ThemeMode>(
                  value: ThemeMode.light,
                  label: Text('Light'),
                  icon: Icon(Icons.light_mode),
                ),
                ButtonSegment<ThemeMode>(
                  value: ThemeMode.dark,
                  label: Text('Dark'),
                  icon: Icon(Icons.dark_mode),
                ),
              ],
              selected: {currentTheme ?? ThemeMode.system},
              onSelectionChanged: (Set<ThemeMode> selected) {
                themeService.setThemeMode(selected.first);
              },
            ),
            const Divider(height: 32),
            ListTile(
              title: const Text('Edit Profile'),
              trailing: const Icon(Icons.edit),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement navigation to profile editor
              },
            ),
            ListTile(
              title: const Text('Notification Settings'),
              trailing: const Icon(Icons.notifications),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement notification preferences
              },
            ),
            ListTile(
              title: const Text('Location Settings'),
              trailing: const Icon(Icons.location_on),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement location radius picker
              },
            ),
            ListTile(
              title: const Text('App Info'),
              trailing: const Icon(Icons.info_outline),
              onTap: () {
                showAboutDialog(
                  context: context,
                  applicationName: 'Crossbeam',
                  applicationVersion: '1.0.0',
                  applicationLegalese: '© 2025 Crossbeam. All rights reserved.',
                );
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }
}

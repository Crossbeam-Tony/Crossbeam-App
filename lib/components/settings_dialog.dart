import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/theme_service.dart';

class SettingsDialog extends StatelessWidget {
  const SettingsDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final themeService = context.watch<ThemeService>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AlertDialog(
      title: const Text('Settings'),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Text('Dark Theme'),
                const Spacer(),
                Switch(
                  value: isDark,
                  onChanged: (value) {
                    themeService.toggleTheme();
                  },
                ),
              ],
            ),
            const Divider(),
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
          child: const Text('Close'),
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }
}

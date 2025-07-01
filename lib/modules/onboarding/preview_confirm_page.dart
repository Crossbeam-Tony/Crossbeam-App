import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/onboarding_provider.dart';
import '../../widgets/hex_selector.dart';
import '../../config/theme_presets.dart';

class PreviewConfirmPage extends StatefulWidget {
  final VoidCallback onComplete;
  const PreviewConfirmPage({Key? key, required this.onComplete})
      : super(key: key);

  @override
  State<PreviewConfirmPage> createState() => _PreviewConfirmPageState();
}

class _PreviewConfirmPageState extends State<PreviewConfirmPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;
  late Animation<double> _fadeAnim;
  bool _showPulse = false;
  bool _completed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 2.5)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _fadeAnim = Tween<double>(begin: 1.0, end: 0.0)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onComplete();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleComplete(OnboardingProvider provider) async {
    setState(() {
      _showPulse = true;
    });
    await provider.completeOnboarding();
    _controller.forward();
    setState(() {
      _completed = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<OnboardingProvider>(
      builder: (context, provider, child) {
        final currentTheme =
            getThemePresetBySlug(provider.themeSlug, provider.isDarkMode);
        final theme = _getThemePreset(provider.themeSlug);

        return Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    Text('Preview & Confirm',
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: currentTheme?.textColor,
                            )),
                    const SizedBox(height: 8),
                    Text(
                      'Review your profile before we get started',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: currentTheme?.textColor.withOpacity(0.7) ??
                                Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withOpacity(0.7),
                          ),
                    ),
                    const SizedBox(height: 32),
                    // Theme
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: currentTheme?.cardColor ??
                            Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: currentTheme?.textColor.withOpacity(0.1) ??
                                Theme.of(context).colorScheme.outline),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.palette,
                            color: currentTheme?.primaryColor ??
                                Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Theme',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(
                                        color: currentTheme?.textColor,
                                      ),
                                ),
                                Text(
                                  '${provider.themeSlug} (${provider.isDarkMode ? 'Dark' : 'Light'})',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        color: currentTheme?.textColor
                                                .withOpacity(0.7) ??
                                            Theme.of(context)
                                                .colorScheme
                                                .onSurface
                                                .withOpacity(0.7),
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Location
                    Row(
                      children: [
                        Icon(Icons.location_on,
                            color: currentTheme?.primaryColor ?? Colors.teal),
                        const SizedBox(width: 8),
                        Text(provider.currentLocation,
                            style:
                                Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      color: currentTheme?.textColor,
                                    )),
                        const SizedBox(width: 16),
                        Icon(Icons.home,
                            color: currentTheme?.accentColor ?? Colors.orange),
                        const SizedBox(width: 8),
                        Text(provider.hometown,
                            style:
                                Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      color: currentTheme?.textColor,
                                    )),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // Profile
                    Row(
                      children: [
                        Icon(Icons.person,
                            color: currentTheme?.primaryColor ?? Colors.blue),
                        const SizedBox(width: 8),
                        Text('${provider.firstName} ${provider.lastName}',
                            style:
                                Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      color: currentTheme?.textColor,
                                    )),
                      ],
                    ),
                    if (provider.bio.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(provider.bio,
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(
                                color: currentTheme?.textColor.withOpacity(0.8),
                              )),
                    ],
                    const SizedBox(height: 24),
                    // Interests
                    Text('Interests',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: currentTheme?.textColor,
                                )),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: provider.selectedInterests
                          .map((interest) => Chip(
                                label: Text(interest),
                                backgroundColor:
                                    currentTheme?.primaryColor.withOpacity(0.1),
                                labelStyle: TextStyle(
                                    color: currentTheme?.primaryColor),
                              ))
                          .toList(),
                    ),
                    const SizedBox(height: 16),
                    // Skills
                    Text('Skills',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: currentTheme?.textColor,
                                )),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: provider.selectedSkills
                          .map((skill) => Chip(
                                label: Text(skill),
                                backgroundColor:
                                    currentTheme?.primaryColor.withOpacity(0.1),
                                labelStyle: TextStyle(
                                    color: currentTheme?.primaryColor),
                              ))
                          .toList(),
                    ),
                    const SizedBox(height: 16),
                    // Tools
                    Text('Tools',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: currentTheme?.textColor,
                                )),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: provider.selectedTools
                          .map((tool) => Chip(
                                label: Text(tool),
                                backgroundColor:
                                    currentTheme?.primaryColor.withOpacity(0.1),
                                labelStyle: TextStyle(
                                    color: currentTheme?.primaryColor),
                              ))
                          .toList(),
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => _handleComplete(provider),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: currentTheme?.primaryColor ??
                              Theme.of(context).colorScheme.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Complete Setup',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
            // Center hex pulse animation overlay
            if (_showPulse)
              Positioned.fill(
                child: Center(
                  child: AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      return Opacity(
                        opacity: _fadeAnim.value,
                        child: Transform.scale(
                          scale: _scaleAnim.value,
                          child: HexSelector(
                            outerColor: theme['outerColor'],
                            borderColor: theme['borderColor'],
                            innerColors: theme['innerColors'],
                            size: 120,
                            isSelected: true,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Map<String, dynamic> _getThemePreset(String slug) {
    // Should match the themePresets in theme_selection_page.dart
    final presets = [
      {
        'slug': 'default',
        'name': 'Classic',
        'outerColor': Colors.blue.shade50,
        'borderColor': Colors.blue.shade700,
        'innerColors': [
          Colors.blue.shade500,
          Colors.blue.shade300,
          Colors.blue.shade100
        ],
      },
      {
        'slug': 'ocean',
        'name': 'Ocean',
        'outerColor': Colors.teal.shade50,
        'borderColor': Colors.teal.shade700,
        'innerColors': [
          Colors.teal.shade500,
          Colors.cyan.shade300,
          Colors.blue.shade100
        ],
      },
      {
        'slug': 'sunset',
        'name': 'Sunset',
        'outerColor': Colors.orange.shade50,
        'borderColor': Colors.orange.shade700,
        'innerColors': [
          Colors.orange.shade500,
          Colors.red.shade300,
          Colors.pink.shade100
        ],
      },
      {
        'slug': 'forest',
        'name': 'Forest',
        'outerColor': Colors.green.shade50,
        'borderColor': Colors.green.shade700,
        'innerColors': [
          Colors.green.shade500,
          Colors.lime.shade300,
          Colors.teal.shade100
        ],
      },
      {
        'slug': 'lavender',
        'name': 'Lavender',
        'outerColor': Colors.purple.shade50,
        'borderColor': Colors.purple.shade700,
        'innerColors': [
          Colors.purple.shade500,
          Colors.indigo.shade300,
          Colors.blue.shade100
        ],
      },
      {
        'slug': 'coral',
        'name': 'Coral',
        'outerColor': Colors.red.shade50,
        'borderColor': Colors.red.shade700,
        'innerColors': [
          Colors.red.shade500,
          Colors.orange.shade300,
          Colors.yellow.shade100
        ],
      },
      {
        'slug': 'dark-steel',
        'name': 'Dark Steel',
        'outerColor': Colors.grey.shade900,
        'borderColor': Colors.grey.shade300,
        'innerColors': [
          Colors.grey.shade700,
          Colors.grey.shade600,
          Colors.grey.shade500
        ],
      },
    ];
    return presets.firstWhere((p) => p['slug'] == slug,
        orElse: () => presets[0]);
  }
}

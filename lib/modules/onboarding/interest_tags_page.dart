import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../providers/onboarding_provider.dart';
import '../../widgets/hex_selector.dart';
import '../../config/theme_presets.dart';

class InterestTagsPage extends StatefulWidget {
  const InterestTagsPage({Key? key}) : super(key: key);

  @override
  State<InterestTagsPage> createState() => _InterestTagsPageState();
}

class _InterestTagsPageState extends State<InterestTagsPage> {
  List<Map<String, dynamic>> _tags = [];
  bool _isLoading = true;
  bool _autoFollowCrews = true;

  @override
  void initState() {
    super.initState();
    _loadTags();
  }

  Future<void> _loadTags() async {
    try {
      final response =
          await Supabase.instance.client.from('tags').select('*').order('name');

      if (response != null) {
        setState(() {
          _tags = List<Map<String, dynamic>>.from(response);
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading tags: $e');
      // Fallback to some default tags if database query fails
      setState(() {
        _tags = [
          {'name': 'Technology', 'id': 'tech'},
          {'name': 'Design', 'id': 'design'},
          {'name': 'Business', 'id': 'business'},
          {'name': 'Marketing', 'id': 'marketing'},
          {'name': 'Development', 'id': 'dev'},
          {'name': 'Creative', 'id': 'creative'},
          {'name': 'Sports', 'id': 'sports'},
          {'name': 'Music', 'id': 'music'},
          {'name': 'Travel', 'id': 'travel'},
          {'name': 'Food', 'id': 'food'},
          {'name': 'Fitness', 'id': 'fitness'},
          {'name': 'Art', 'id': 'art'},
        ];
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<OnboardingProvider>(
      builder: (context, provider, child) {
        final currentTheme =
            getThemePresetBySlug(provider.themeSlug, provider.isDarkMode);

        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

              // Header
              Text(
                'What interests you?',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: currentTheme?.textColor,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Select topics that match your interests and passions',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: currentTheme?.textColor.withOpacity(0.7) ??
                          Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.7),
                    ),
              ),
              const SizedBox(height: 32),

              // Tags Grid
              if (_isLoading)
                Expanded(
                  child: Center(
                    child: CircularProgressIndicator(
                      color: currentTheme?.primaryColor,
                    ),
                  ),
                )
              else
                Expanded(
                  child: GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      childAspectRatio: 1.0,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: _tags.length,
                    itemBuilder: (context, index) {
                      final tag = _tags[index];
                      final tagName = tag['name'] as String;
                      final isSelected =
                          provider.selectedInterests.contains(tagName);

                      return HexSelector(
                        outerColor: isSelected
                            ? (currentTheme?.primaryColor.withOpacity(0.2) ??
                                Theme.of(context)
                                    .colorScheme
                                    .primary
                                    .withOpacity(0.2))
                            : (currentTheme?.cardColor ??
                                Theme.of(context).colorScheme.surface),
                        borderColor: isSelected
                            ? (currentTheme?.primaryColor ??
                                Theme.of(context).colorScheme.primary)
                            : (currentTheme?.textColor.withOpacity(0.3) ??
                                Theme.of(context).colorScheme.outline),
                        innerColors: isSelected
                            ? [
                                currentTheme?.primaryColor ??
                                    Theme.of(context).colorScheme.primary,
                                (currentTheme?.primaryColor ??
                                        Theme.of(context).colorScheme.primary)
                                    .withOpacity(0.7),
                                (currentTheme?.primaryColor ??
                                        Theme.of(context).colorScheme.primary)
                                    .withOpacity(0.3),
                              ]
                            : [
                                currentTheme?.textColor.withOpacity(0.2) ??
                                    Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withOpacity(0.2),
                                currentTheme?.textColor.withOpacity(0.1) ??
                                    Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withOpacity(0.1),
                                currentTheme?.textColor.withOpacity(0.05) ??
                                    Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withOpacity(0.05),
                              ],
                        label: tagName,
                        isSelected: isSelected,
                        onTap: () {
                          provider.toggleInterest(tagName);
                        },
                        size: 80,
                      );
                    },
                  ),
                ),

              const SizedBox(height: 24),

              // Auto-follow toggle
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
                      Icons.group,
                      color: currentTheme?.primaryColor ??
                          Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Auto-follow matching Crews',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  color: currentTheme?.textColor,
                                ),
                          ),
                          Text(
                            'Automatically join crews that match your interests',
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
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
                    Switch(
                      value: _autoFollowCrews,
                      activeColor: currentTheme?.primaryColor ??
                          Theme.of(context).colorScheme.primary,
                      onChanged: (value) {
                        setState(() {
                          _autoFollowCrews = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Continue button removed - navigation handled by main onboarding page
            ],
          ),
        );
      },
    );
  }
}

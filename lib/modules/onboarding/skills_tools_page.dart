import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/onboarding_provider.dart';
import '../../widgets/hex_selector.dart';
import '../../config/theme_presets.dart';

class SkillsToolsPage extends StatefulWidget {
  const SkillsToolsPage({Key? key}) : super(key: key);

  @override
  State<SkillsToolsPage> createState() => _SkillsToolsPageState();
}

class _SkillsToolsPageState extends State<SkillsToolsPage> {
  final TextEditingController _customSkillController = TextEditingController();
  final TextEditingController _customToolController = TextEditingController();
  bool _showSkillInput = false;
  bool _showToolInput = false;

  // Suggested skills and tools based on common interests
  final Map<String, List<String>> _suggestedSkills = {
    'technology': [
      'JavaScript',
      'Python',
      'React',
      'Flutter',
      'Node.js',
      'SQL'
    ],
    'design': [
      'Figma',
      'Adobe XD',
      'Sketch',
      'Photoshop',
      'Illustrator',
      'InDesign'
    ],
    'business': [
      'Project Management',
      'Marketing',
      'Sales',
      'Finance',
      'Strategy',
      'Leadership'
    ],
    'creative': [
      'Photography',
      'Video Editing',
      'Writing',
      'Music',
      'Art',
      'Animation'
    ],
    'health': [
      'Fitness',
      'Nutrition',
      'Yoga',
      'Meditation',
      'Wellness',
      'Coaching'
    ],
    'education': [
      'Teaching',
      'Curriculum Design',
      'Tutoring',
      'Mentoring',
      'Research',
      'Public Speaking'
    ],
  };

  final Map<String, List<String>> _suggestedTools = {
    'technology': ['VS Code', 'Git', 'Docker', 'AWS', 'Slack', 'Notion'],
    'design': [
      'Figma',
      'Canva',
      'Adobe Creative Suite',
      'Sketch',
      'InVision',
      'Miro'
    ],
    'business': [
      'Excel',
      'PowerPoint',
      'Salesforce',
      'HubSpot',
      'Trello',
      'Asana'
    ],
    'creative': [
      'Adobe Premiere',
      'Final Cut Pro',
      'Lightroom',
      'Procreate',
      'GarageBand',
      'Canva'
    ],
    'health': ['MyFitnessPal', 'Headspace', 'Fitbit', 'Strava', 'Calm', 'Noom'],
    'education': [
      'Google Classroom',
      'Zoom',
      'Kahoot',
      'Mentimeter',
      'Padlet',
      'Edmodo'
    ],
  };

  List<String> get _allSuggestedSkills {
    final skills = <String>{};
    for (final tag in context.read<OnboardingProvider>().selectedInterests) {
      final tagSkills = _suggestedSkills[tag.toLowerCase()] ?? [];
      skills.addAll(tagSkills);
    }
    return skills.toList();
  }

  List<String> get _allSuggestedTools {
    final tools = <String>{};
    for (final tag in context.read<OnboardingProvider>().selectedInterests) {
      final tagTools = _suggestedTools[tag.toLowerCase()] ?? [];
      tools.addAll(tagTools);
    }
    return tools.toList();
  }

  @override
  void dispose() {
    _customSkillController.dispose();
    _customToolController.dispose();
    super.dispose();
  }

  void _addCustomSkill() {
    final skill = _customSkillController.text.trim();
    if (skill.isNotEmpty) {
      context.read<OnboardingProvider>().toggleSkill(skill);
      _customSkillController.clear();
      setState(() {
        _showSkillInput = false;
      });
    }
  }

  void _addCustomTool() {
    final tool = _customToolController.text.trim();
    if (tool.isNotEmpty) {
      context.read<OnboardingProvider>().toggleTool(tool);
      _customToolController.clear();
      setState(() {
        _showToolInput = false;
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
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),

                // Header
                Text(
                  'Skills & Tools',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: currentTheme?.textColor,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'What are you good at? What tools do you use?',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: currentTheme?.textColor.withOpacity(0.7) ??
                            Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.7),
                      ),
                ),
                const SizedBox(height: 32),

                // Skills Section
                Text(
                  'Skills',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: currentTheme?.textColor,
                      ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Select your top skills (choose 3-5)',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: currentTheme?.textColor.withOpacity(0.7) ??
                            Colors.grey.shade600,
                      ),
                ),
                const SizedBox(height: 16),

                // Skills Grid
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: _allSuggestedSkills.map((skill) {
                    final isSelected = provider.selectedSkills.contains(skill);
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
                      label: skill,
                      isSelected: isSelected,
                      onTap: () {
                        provider.toggleSkill(skill);
                      },
                      size: 70,
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),

                // Tools Section
                Text(
                  'Tools',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: currentTheme?.textColor,
                      ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Select tools you use regularly (choose 3-5)',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: currentTheme?.textColor.withOpacity(0.7) ??
                            Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.7),
                      ),
                ),
                const SizedBox(height: 16),

                // Tools Grid
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: _allSuggestedTools.map((tool) {
                    final isSelected = provider.selectedTools.contains(tool);
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
                      label: tool,
                      isSelected: isSelected,
                      onTap: () {
                        provider.toggleTool(tool);
                      },
                      size: 70,
                    );
                  }).toList(),
                ),
                const SizedBox(height: 32),

                // Continue button removed - navigation handled by main onboarding page
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }
}

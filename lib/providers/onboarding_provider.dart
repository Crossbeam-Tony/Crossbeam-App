import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/auth_service.dart';
import '../services/theme_service.dart';
import '../config/theme_presets.dart' as presets;
import '../models/app_theme.dart';

class OnboardingProvider extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;
  final AuthService _authService;
  final ThemeService _themeService;

  OnboardingProvider(this._authService, this._themeService);

  // Navigation state
  int currentPage = 0;

  // Theme state
  String _themeSlug = 'crossbeam';
  bool _isDarkMode = false;

  // Location state
  String _currentLocation = '';
  String _hometown = '';

  // Profile state
  String _firstName = '';
  String _lastName = '';
  String _bio = '';
  String _avatarUrl = '';
  DateTime? _birthday;

  // Interests and skills
  List<String> _selectedInterests = [];
  List<String> _selectedSkills = [];
  List<String> _selectedTools = [];
  List<String> suggestions = [];

  // Getters
  String get themeSlug => _themeSlug;
  bool get isDarkMode => _isDarkMode;
  String get hometown => _hometown;
  String get currentLocation => _currentLocation;
  String get firstName => _firstName;
  String get lastName => _lastName;
  String get bio => _bio;
  String get avatarUrl => _avatarUrl;
  DateTime? get birthday => _birthday;
  List<String> get selectedInterests => _selectedInterests;
  List<String> get selectedSkills => _selectedSkills;
  List<String> get selectedTools => _selectedTools;

  // Navigation methods
  void goToNextPage() {
    if (currentPage < 5) {
      currentPage++;
      notifyListeners();
    }
  }

  void goToPrevPage() {
    if (currentPage > 0) {
      currentPage--;
      notifyListeners();
    }
  }

  // Theme methods
  void setTheme(String themeSlug, bool isDarkMode) {
    _themeSlug = themeSlug;
    _isDarkMode = isDarkMode;

    // Apply theme immediately for live preview
    _themeService.setThemeSlug(themeSlug);
    if (isDarkMode) {
      _themeService.setThemeMode(ThemeMode.dark);
    } else {
      _themeService.setThemeMode(ThemeMode.light);
    }

    notifyListeners();
  }

  /// Update theme selection without applying it immediately
  void selectTheme(String themeSlug, bool isDarkMode) {
    _themeSlug = themeSlug;
    _isDarkMode = isDarkMode;
    notifyListeners();
  }

  /// Set theme with AppTheme object for better synchronization
  Future<void> setThemeWithAppTheme(AppTheme theme, bool isDarkMode) async {
    _themeSlug = theme.name;
    _isDarkMode = isDarkMode;

    // Use the new theme service method for immediate application
    await _themeService.setThemeAndMode(theme, isDarkMode);

    notifyListeners();
  }

  // Location methods
  void setLocation(String hometown, String currentLocation) {
    _hometown = hometown;
    _currentLocation = currentLocation;
    notifyListeners();
  }

  // Profile methods
  void setProfileInfo({
    required String firstName,
    required String lastName,
    required String bio,
    String? avatarUrl,
    DateTime? birthday,
  }) {
    _firstName = firstName;
    _lastName = lastName;
    _bio = bio;
    if (avatarUrl != null) _avatarUrl = avatarUrl;
    if (birthday != null) _birthday = birthday;
    notifyListeners();
  }

  // Interests methods
  void setInterests(List<String> interests) {
    _selectedInterests = interests;
    notifyListeners();
  }

  void toggleInterest(String interest) {
    if (_selectedInterests.contains(interest)) {
      _selectedInterests.remove(interest);
    } else {
      _selectedInterests.add(interest);
    }
    notifyListeners();
  }

  // Skills and tools methods
  Future<void> loadSuggestions(List<String> tags) async {
    try {
      final res = await _supabase
          .from('tag_skill_tool_map')
          .select('related_skill, related_tool')
          .inFilter('tag', tags);

      if (res != null) {
        suggestions = (res as List)
            .expand((row) => [row['related_skill'], row['related_tool']])
            .where((item) => item != null)
            .cast<String>()
            .toSet()
            .toList();
        notifyListeners();
      }
    } catch (e) {
      print('Error loading suggestions: $e');
    }
  }

  void setSkills(List<String> skills) {
    _selectedSkills = skills;
    notifyListeners();
  }

  void setTools(List<String> tools) {
    _selectedTools = tools;
    notifyListeners();
  }

  void toggleSkill(String skill) {
    if (_selectedSkills.contains(skill)) {
      _selectedSkills.remove(skill);
    } else {
      _selectedSkills.add(skill);
    }
    notifyListeners();
  }

  void toggleTool(String tool) {
    if (_selectedTools.contains(tool)) {
      _selectedTools.remove(tool);
    } else {
      _selectedTools.add(tool);
    }
    notifyListeners();
  }

  Future<void> saveSkillsAndTools() async {
    try {
      final userId = _supabase.auth.currentUser!.id;
      for (final s in _selectedSkills) {
        await _supabase.from('user_skills').upsert({
          'user_id': userId,
          'skill': s,
        });
      }
      for (final t in _selectedTools) {
        await _supabase.from('user_tools').upsert({
          'user_id': userId,
          'tool': t,
        });
      }
    } catch (e) {
      print('Error saving skills and tools: $e');
      rethrow;
    }
  }

  // Complete onboarding
  Future<void> completeOnboarding() async {
    try {
      final uid = _supabase.auth.currentUser!.id;

      // Update profile
      await _supabase.from('profiles').upsert({
        'id': uid,
        'theme_slug': _themeSlug,
        'is_dark_mode': _isDarkMode,
        'current_location': _currentLocation,
        'hometown': _hometown,
        'full_name': _firstName + ' ' + _lastName,
        'username': '',
        'bio': _bio,
        'avatar_url': _avatarUrl,
        'onboarding_completed': true,
        'updated_at': DateTime.now().toIso8601String(),
      });

      // Save user tags
      for (final tag in _selectedInterests) {
        await _supabase.from('user_tags').upsert({
          'user_id': uid,
          'tag': tag,
        });
      }

      // Save skills and tools
      await saveSkillsAndTools();

      // Mark onboarding as complete
      currentPage = 6;
      notifyListeners();
    } catch (e) {
      print('Error completing onboarding: $e');
      rethrow;
    }
  }

  // Validation methods
  bool get isLocationValid =>
      _currentLocation.isNotEmpty && _hometown.isNotEmpty;
  bool get isProfileValid => _firstName.isNotEmpty && _lastName.isNotEmpty;
  bool get isTagsValid => _selectedInterests.isNotEmpty;
  bool get isSkillsValid => _selectedSkills.isNotEmpty;

  // Reset method
  void reset() {
    currentPage = 0;
    _themeSlug = 'crossbeam';
    _isDarkMode = false;
    _currentLocation = '';
    _hometown = '';
    _firstName = '';
    _lastName = '';
    _bio = '';
    _avatarUrl = '';
    _birthday = null;
    _selectedInterests = [];
    _selectedSkills = [];
    _selectedTools = [];
    suggestions.clear();
    notifyListeners();
  }

  // Get theme presets for current mode
  List<presets.ThemePreset> getThemePresets() {
    return _isDarkMode ? presets.darkThemePresets : presets.lightThemePresets;
  }
}

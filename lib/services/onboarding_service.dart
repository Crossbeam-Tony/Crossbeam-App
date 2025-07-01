import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../router.dart';

class OnboardingService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Save user's location and hometown
  Future<void> saveLocation(String hometown, Position? gps) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final updates = <String, dynamic>{
        'hometown': hometown,
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (gps != null) {
        updates['current_location'] = '${gps.latitude},${gps.longitude}';
      }

      await _supabase.from('profiles').update(updates).eq('id', user.id);
    } catch (e) {
      await _logError('saveLocation', e.toString());
      rethrow;
    }
  }

  /// Save user's theme preference
  Future<void> saveTheme(String slug, bool isDark) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final updates = <String, dynamic>{
        'theme_slug': slug,
        'is_dark_mode': isDark,
        'updated_at': DateTime.now().toIso8601String(),
      };

      await _supabase.from('profiles').update(updates).eq('id', user.id);
    } catch (e) {
      await _logError('saveTheme', e.toString());
      rethrow;
    }
  }

  /// Save user's selected interests
  Future<void> saveInterests(List<String> tags) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      // Clear existing interests
      await _supabase.from('user_tags').delete().eq('user_id', user.id);

      // Insert new interests
      if (tags.isNotEmpty) {
        final interestData = tags
            .map((tag) => <String, dynamic>{
                  'user_id': user.id,
                  'tag': tag,
                })
            .toList();

        await _supabase.from('user_tags').insert(interestData);
      }
    } catch (e) {
      await _logError('saveInterests', e.toString());
      rethrow;
    }
  }

  /// Save user's selected skills and tools
  Future<void> saveSuggestions(List<Map<String, String>> suggestions) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      // Clear existing skills and tools
      await _supabase.from('user_skills').delete().eq('user_id', user.id);

      await _supabase.from('user_tools').delete().eq('user_id', user.id);

      // Separate skills and tools
      final skills = <String>[];
      final tools = <String>[];

      for (final suggestion in suggestions) {
        final type = suggestion['type'];
        final name = suggestion['name'];

        if (type == 'skill' && name != null) {
          skills.add(name);
        } else if (type == 'tool' && name != null) {
          tools.add(name);
        }
      }

      // Insert skills
      if (skills.isNotEmpty) {
        final skillData = skills
            .map((skill) => <String, dynamic>{
                  'user_id': user.id,
                  'skill': skill,
                })
            .toList();

        await _supabase.from('user_skills').insert(skillData);
      }

      // Insert tools
      if (tools.isNotEmpty) {
        final toolData = tools
            .map((tool) => <String, dynamic>{
                  'user_id': user.id,
                  'tool': tool,
                })
            .toList();

        await _supabase.from('user_tools').insert(toolData);
      }
    } catch (e) {
      await _logError('saveSuggestions', e.toString());
      rethrow;
    }
  }

  /// Mark onboarding as complete
  Future<bool> completeOnboarding() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      // Update profile to mark onboarding as complete
      await _supabase.from('profiles').update(<String, dynamic>{
        'onboarding_completed': true,
        'onboarding_completed_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', user.id);

      // Router cache clearing removed - onboarding check disabled

      return true;
    } catch (e) {
      await _logError('completeOnboarding', e.toString());
      return false;
    }
  }

  /// Check if onboarding is completed
  Future<bool> isOnboardingCompleted() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        print('OnboardingService: No current user');
        return false;
      }

      print('OnboardingService: Checking onboarding for user ${user.id}');

      final response = await _supabase
          .from('profiles')
          .select('onboarding_completed')
          .eq('id', user.id)
          .maybeSingle();

      if (response == null) {
        print(
            'OnboardingService: No profile found for user, onboarding not completed');
        return false;
      }

      print('OnboardingService: Response: $response');
      final result = response['onboarding_completed'] == true;
      print('OnboardingService: Onboarding completed: $result');
      return result;
    } catch (e) {
      print('OnboardingService: Error checking onboarding: $e');
      await _logError('isOnboardingCompleted', e.toString());
      return false;
    }
  }

  /// Get onboarding tags for interest selection
  Future<List<Map<String, dynamic>>> getOnboardingTags() async {
    try {
      final response = await _supabase
          .from('tags')
          .select('*')
          .eq('type', 'interest')
          .eq('is_approved', true)
          .order('name');

      return response;
    } catch (e) {
      await _logError('getOnboardingTags', e.toString());
      return [];
    }
  }

  /// Get skill/tool suggestions based on selected interests
  Future<List<Map<String, dynamic>>> getSuggestions(
      List<String> selectedTags) async {
    try {
      if (selectedTags.isEmpty) return [];

      final response = await _supabase
          .from('tag_skill_tool_map')
          .select('*')
          .inFilter('tag_name', selectedTags)
          .order('type')
          .order('name');

      return response;
    } catch (e) {
      await _logError('getSuggestions', e.toString());
      return [];
    }
  }

  /// Log errors to tag_submission_log table
  Future<void> _logError(String method, String error) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return;

      await _supabase.from('tag_submission_log').insert(<String, dynamic>{
        'user_id': user.id,
        'attempted_tag': method,
        'reason': error,
      });
    } catch (e) {
      // Silently fail to avoid infinite loops
      print('Failed to log error: $e');
    }
  }
}

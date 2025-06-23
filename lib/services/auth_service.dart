import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_profile.dart';

class AuthService extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;
  UserProfile? _currentUser;
  bool _isAuthenticated = false;

  UserProfile? get currentUser => _currentUser;
  bool get isAuthenticated => _isAuthenticated;

  AuthService() {
    _supabase.auth.onAuthStateChange.listen((data) {
      final Session? session = data.session;
      if (session != null) {
        _isAuthenticated = true;
        _loadUserProfile(session.user);
      } else {
        _isAuthenticated = false;
        _currentUser = null;
      }
      notifyListeners();
    });
  }

  Future<void> _loadUserProfile(User user) async {
    final response = await _supabase
        .from('profiles')
        .select()
        .eq('id', user.id)
        .maybeSingle();

    if (response != null) {
      _currentUser = UserProfile.fromJson(response);
    } else {
      // Create a default profile if one doesn't exist
      final newProfile = UserProfile(
        id: user.id,
        email: user.email ?? '',
        username: user.userMetadata?['username'] ?? '',
        name: user.userMetadata?['username'] ?? '',
        realname: '',
        avatarUrl: '',
        bio: '',
        location: '',
        stats: {},
        mutualCrews: [],
        skills: [],
      );
      await _supabase.from('profiles').insert(newProfile.toJson());
      _currentUser = newProfile;
    }
    notifyListeners();
  }

  Future<void> signIn(String email, String password) async {
    await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signUp(String email, String password, String username) async {
    final authResponse = await _supabase.auth.signUp(
      email: email,
      password: password,
      data: {'username': username},
    );
    if (authResponse.user != null) {
      // Create a profile entry
      await _supabase.from('profiles').insert({
        'id': authResponse.user!.id,
        'username': username,
      });
    }
  }

  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  Future<void> updateProfile(UserProfile updatedProfile) async {
    if (_currentUser != null) {
      await _supabase
          .from('profiles')
          .update(updatedProfile.toJson())
          .eq('id', _currentUser!.id);
      _currentUser = updatedProfile;
      notifyListeners();
    }
  }
}

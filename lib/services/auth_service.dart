import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';
import '../models/user_profile.dart';
import '../router.dart';

class AuthService extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;
  UserProfile? _currentUser;
  bool _isAuthenticated = false;

  // Rate limiting for signup attempts
  final Map<String, List<DateTime>> _signupAttempts = {};
  final Map<String, List<DateTime>> _resendAttempts = {};
  static const int _maxSignupAttempts = 3;
  static const int _maxResendAttempts = 2;
  static const Duration _signupCooldown = Duration(minutes: 10);
  static const Duration _resendCooldown = Duration(minutes: 5);

  UserProfile? get currentUser => _currentUser;
  bool get isAuthenticated => _isAuthenticated;

  AuthService() {
    print('=== AUTH SERVICE INITIALIZED ===');
    _supabase.auth.onAuthStateChange.listen((data) async {
      print('=== AUTH STATE CHANGE EVENT ===');
      print('Event: ${data.event}');
      print('Session: ${data.session != null}');

      final Session? session = data.session;
      if (session != null) {
        print('=== USER SIGNED IN ===');
        print('User ID: ${session.user.id}');
        print('Email: ${session.user.email}');
        print('Email confirmed: ${session.user.emailConfirmedAt != null}');

        _isAuthenticated = true;
        await _loadUserProfile(session.user);
        // If user or profile is missing, force sign out
        if (_currentUser == null) {
          print('User profile not found. Forcing sign out.');
          await signOut();
        }
      } else {
        print('=== USER SIGNED OUT ===');
        _isAuthenticated = false;
        _currentUser = null;
      }
      notifyListeners();
    });

    // Check if user is already logged in
    final currentSession = _supabase.auth.currentSession;
    if (currentSession != null) {
      print('=== CURRENT SESSION FOUND ===');
      print('User ID: ${currentSession.user.id}');
      print('Email: ${currentSession.user.email}');
      _isAuthenticated = true;
      _loadUserProfile(currentSession.user).then((_) async {
        if (_currentUser == null) {
          print('User profile not found on startup. Forcing sign out.');
          await signOut();
        }
      });
    } else {
      print('=== NO CURRENT SESSION ===');
    }
  }

  Future<void> _loadUserProfile(User user) async {
    try {
      final response = await _supabase
          .from('profiles')
          .select()
          .eq('id', user.id)
          .maybeSingle();

      if (response != null) {
        _currentUser = UserProfile.fromJson(response);
      } else {
        // Create a minimal profile object if one doesn't exist
        final firstName = user.userMetadata?['first_name'] ?? '';
        final lastName = user.userMetadata?['last_name'] ?? '';
        final username = user.userMetadata?['username'] ?? '';

        _currentUser = UserProfile(
          id: user.id,
          email: user.email ?? '',
          username: username,
          firstName: firstName,
          lastName: lastName,
          fullName: '$firstName $lastName'.trim(),
          bio: '',
          avatarUrl: '',
          hometown: '',
          currentLocation: '',
          createdAt: DateTime.now(),
        );
      }
    } catch (error) {
      // Create a minimal profile object as fallback
      _currentUser = UserProfile(
        id: user.id,
        email: user.email ?? '',
        username: user.userMetadata?['username'] ?? '',
        firstName: user.userMetadata?['first_name'] ?? '',
        lastName: user.userMetadata?['last_name'] ?? '',
        fullName:
            '${user.userMetadata?['first_name'] ?? ''} ${user.userMetadata?['last_name'] ?? ''}'
                .trim(),
        bio: '',
        avatarUrl: '',
        hometown: '',
        currentLocation: '',
        createdAt: DateTime.now(),
      );
    }
  }

  Future<void> signIn(String email, String password) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        throw Exception('Sign in failed');
      }
    } catch (error) {
      throw Exception('Invalid email or password');
    }
  }

  Future<void> signUp(
    String email,
    String password,
    String username,
    String firstName,
    String lastName,
    DateTime? birthday,
  ) async {
    try {
      print('=== STARTING SIGNUP PROCESS ===');
      print('Email: $email');
      print('Username: $username');

      // Create user account with profile data in metadata
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {
          'username': username,
          'first_name': firstName,
          'last_name': lastName,
          'full_name': '$firstName $lastName',
          'birthday': birthday?.toIso8601String(),
          'email_verified': false,
          'phone_verified': false,
          'avatar_url': '',
          'bio': '',
          'hometown': '',
          'current_location': '',
        },
      );

      print('=== SIGNUP RESPONSE ===');
      print('User created: ${response.user != null}');
      print('User ID: ${response.user?.id}');
      print('Email confirmed: ${response.user?.emailConfirmedAt != null}');
      print('Session: ${response.session != null}');
      print('Email verification email should have been sent');

      if (response.user != null) {
        print('SignUp user ID: ${response.user!.id}');
        print('SignUp email: ${response.user!.email}');

        // Create a profile record for the new user
        try {
          await _supabase.from('profiles').insert({
            'id': response.user!.id,
            'email': response.user!.email,
            'username': username,
            'full_name': '$firstName $lastName',
            'first_name': firstName,
            'last_name': lastName,
            'bio': '',
            'avatar_url': '',
            'hometown': '',
            'current_location': '',
            'onboarding_completed': false,
            'created_at': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          });
          print('Profile record created for new user');
        } catch (e) {
          print('Error creating profile record: $e');
          // Continue anyway, profile will be created during onboarding
        }

        // Navigate to OTP entry
        GoRouter.of(navigatorKey.currentContext!).goNamed('verify-code');
      }
    } catch (e) {
      print('❌ SignUp error: $e');
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
      _isAuthenticated = false;
      _currentUser = null;
      notifyListeners();
    } catch (error) {
      rethrow;
    }
  }

  Future<void> resendVerificationEmail(String email) async {
    try {
      await _supabase.auth.resend(
        type: OtpType.signup,
        email: email,
      );
    } catch (error) {
      // Handle specific error types with better user feedback
      if (error.toString().contains('email rate limit exceeded') ||
          error.toString().contains('over_email_send_rate_limit')) {
        throw Exception(
            'Too many email requests. Please wait 5-10 minutes before trying again.');
      } else if (error.toString().contains('User already confirmed')) {
        throw Exception(
            'This email is already verified. Please try signing in.');
      } else if (error.toString().contains('User not found')) {
        throw Exception(
            'No account found with this email. Please check the email address or create a new account.');
      } else if (error.toString().contains('network') ||
          error.toString().contains('connection')) {
        throw Exception(
            'Network error. Please check your internet connection and try again.');
      } else {
        throw Exception(
            'Failed to resend verification email. Please try again in a few minutes.');
      }
    }
  }

  Future<void> verifyOTP(String email, String token) async {
    try {
      print('=== VERIFYING OTP ===');
      print('Email: $email');
      print('Token: $token');

      final res = await _supabase.auth.verifyOTP(
        type: OtpType.signup,
        token: token,
        email: email,
      );

      print('=== OTP VERIFICATION RESPONSE ===');
      print('Full response: user: \\${res.user}, session: \\${res.session}');

      if (res.user == null) {
        throw Exception(
            'Invalid or expired code. Please check your code and try again.');
      }

      // Create profile after successful verification
      await _createProfile(res.user!);
    } catch (e) {
      print('❌ OTP verification error: $e');
      rethrow;
    }
  }

  Future<void> _createProfile(User user) async {
    try {
      print('=== CREATING PROFILE ===');

      String? emailVerifiedAt;
      if (user.emailConfirmedAt != null) {
        if (user.emailConfirmedAt is DateTime) {
          emailVerifiedAt =
              (user.emailConfirmedAt as DateTime).toIso8601String();
        } else {
          emailVerifiedAt = user.emailConfirmedAt.toString();
        }
      }

      final upsertRes = await _supabase
          .from('profiles')
          .upsert({
            'id': user.id,
            'email': user.email,
            'full_name': user.userMetadata?['full_name'] ?? '',
            'avatar_url': user.userMetadata?['avatar_url'] ?? '',
            'username': user.userMetadata?['username'] ?? '',
            'first_name': user.userMetadata?['first_name'] ?? '',
            'last_name': user.userMetadata?['last_name'] ?? '',
            'email_verified': user.emailConfirmedAt != null,
            'email_verified_at': emailVerifiedAt,
            'created_at': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          }, onConflict: 'id')
          .select()
          .single();

      if (upsertRes == null) {
        print('=== PROFILE UPSERT RESPONSE IS NULL ===');
        throw Exception('Profile creation failed: No response from Supabase.');
      }

      print('🔔 Profile upsert → $upsertRes');
      print('=== PROFILE CREATION SUCCESSFUL ===');
    } catch (e) {
      print('❌ Profile creation error: $e');
      rethrow;
    }
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

  // Debug method to check authentication state
  void debugAuthState() {}

  // Rate limiting methods
  bool _isRateLimited(String email, bool isSignup) {
    final attempts = isSignup ? _signupAttempts : _resendAttempts;
    final maxAttempts = isSignup ? _maxSignupAttempts : _maxResendAttempts;
    final cooldown = isSignup ? _signupCooldown : _resendCooldown;

    if (!attempts.containsKey(email)) {
      return false;
    }

    final recentAttempts = attempts[email]!
        .where((time) => DateTime.now().difference(time) < cooldown)
        .toList();

    return recentAttempts.length >= maxAttempts;
  }

  void _recordAttempt(String email, bool isSignup) {
    final attempts = isSignup ? _signupAttempts : _resendAttempts;
    if (!attempts.containsKey(email)) {
      attempts[email] = [];
    }
    attempts[email]!.add(DateTime.now());

    // Clean up old attempts
    final cooldown = isSignup ? _signupCooldown : _resendCooldown;
    attempts[email] = attempts[email]!
        .where((time) => DateTime.now().difference(time) < cooldown)
        .toList();
  }

  Duration _getRemainingCooldown(String email, bool isSignup) {
    final attempts = isSignup ? _signupAttempts : _resendAttempts;
    final cooldown = isSignup ? _signupCooldown : _resendCooldown;

    if (!attempts.containsKey(email)) {
      return Duration.zero;
    }

    final oldestAttempt =
        attempts[email]!.reduce((a, b) => a.isBefore(b) ? a : b);
    final timeSinceOldest = DateTime.now().difference(oldestAttempt);

    if (timeSinceOldest >= cooldown) {
      return Duration.zero;
    }

    return cooldown - timeSinceOldest;
  }
}

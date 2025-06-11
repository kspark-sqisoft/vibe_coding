import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vibe_coding_flutter/features/auth/domain/user_with_profile.dart';
import 'package:logger/logger.dart';

class SupabaseAuthRepository {
  final SupabaseClient _supabase;
  final Logger _logger;

  SupabaseAuthRepository(this._supabase, this._logger);

  User? getCurrentUser() {
    return _supabase.auth.currentUser;
  }

  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;

  Future<UserWithProfile?> getUserWithProfile(User user) async {
    try {
      _logger.i('Fetching user profile for user ID: ${user.id}');
      final response = await _supabase
          .from('profiles')
          .select('username')
          .eq('id', user.id)
          .single();
      final username = response['username'] as String?;
      _logger.i('Fetched user profile: $username for user ID: ${user.id}');
      return UserWithProfile(user: user, username: username);
    } catch (e) {
      _logger.e('Error fetching user profile from repository: $e');
      return UserWithProfile(user: user); // 프로필 가져오기 실패 시 사용자만 포함
    }
  }

  Future<void> signUp(String email, String password, String username) async {
    _logger.i('Attempting to sign up user: $email with username: $username');
    final AuthResponse response = await _supabase.auth.signUp(
      email: email,
      password: password,
      data: {'username': username},
    );
    if (response.user != null) {
      _logger.i(
        'User signed up successfully. Inserting profile for ID: ${response.user!.id}',
      );
      await _supabase.from('profiles').insert({
        'id': response.user!.id,
        'username': username,
        'created_at': DateTime.now().toIso8601String(),
      });
      _logger.i('Profile inserted for user ID: ${response.user!.id}');
    } else {
      _logger.w('Sign up successful, but no user returned.');
    }
  }

  Future<void> signIn(String email, String password) async {
    _logger.i('Attempting to sign in user: $email');
    await _supabase.auth.signInWithPassword(email: email, password: password);
    _logger.i('Sign in request sent for user: $email');
  }

  Future<void> signOut() async {
    _logger.i('Attempting to sign out current user');
    await _supabase.auth.signOut();
    _logger.i('Sign out request sent');
  }
}

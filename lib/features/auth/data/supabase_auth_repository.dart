import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vibe_coding_flutter/features/auth/domain/user_with_profile.dart';

class SupabaseAuthRepository {
  final SupabaseClient _supabase;

  SupabaseAuthRepository(this._supabase);

  User? getCurrentUser() {
    return _supabase.auth.currentUser;
  }

  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;

  Future<UserWithProfile?> getUserWithProfile(User user) async {
    try {
      final response = await _supabase
          .from('profiles')
          .select('username')
          .eq('id', user.id)
          .single();
      final username = response['username'] as String?;
      return UserWithProfile(user: user, username: username);
    } catch (e) {
      print('Error fetching user profile from repository: $e');
      return UserWithProfile(user: user); // 프로필 가져오기 실패 시 사용자만 포함
    }
  }

  Future<void> signUp(String email, String password, String username) async {
    final AuthResponse response = await _supabase.auth.signUp(
      email: email,
      password: password,
      data: {'username': username},
    );
    // If signup is successful, insert the username into the profiles table
    if (response.user != null) {
      await _supabase.from('profiles').insert({
        'id': response.user!.id,
        'username': username,
        'created_at': DateTime.now().toIso8601String(),
      });
    }
  }

  Future<void> signIn(String email, String password) async {
    await _supabase.auth.signInWithPassword(email: email, password: password);
  }

  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }
}

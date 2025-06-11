import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseAuthRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  User? getCurrentUser() {
    return _supabase.auth.currentUser;
  }

  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;

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

import 'package:supabase_flutter/supabase_flutter.dart';
import '../domain/auth_repository.dart';
import '../domain/user_entity.dart';

class SupabaseAuthRepository implements AuthRepository {
  final supabase = Supabase.instance.client;

  @override
  Future<UserEntity> signUp(String email, String password) async {
    final response = await supabase.auth.signUp(
      email: email,
      password: password,
    );
    final user = response.user;
    if (user == null) throw Exception('Sign up failed');
    return UserEntity(id: user.id, email: user.email ?? '');
  }

  @override
  Future<UserEntity> signIn(String email, String password) async {
    final response = await supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
    final user = response.user;
    if (user == null) throw Exception('Sign in failed');
    return UserEntity(id: user.id, email: user.email ?? '');
  }

  @override
  Future<void> signOut() async {
    await supabase.auth.signOut();
  }
}

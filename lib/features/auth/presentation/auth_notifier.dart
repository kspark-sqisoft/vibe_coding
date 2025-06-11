import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide Provider;
import 'package:vibe_coding_flutter/features/auth/data/supabase_auth_repository.dart';
import 'package:vibe_coding_flutter/features/auth/domain/user_with_profile.dart';

final authRepositoryProvider = Provider((ref) => SupabaseAuthRepository());

final authNotifierProvider =
    StateNotifierProvider<AuthNotifier, UserWithProfile?>((ref) {
      return AuthNotifier(ref.watch(authRepositoryProvider));
    });

class AuthNotifier extends StateNotifier<UserWithProfile?> {
  final SupabaseAuthRepository _authRepository;
  final SupabaseClient _supabase = Supabase.instance.client;

  AuthNotifier(this._authRepository) : super(null) {
    _initializeUser();
    _authRepository.authStateChanges.listen((data) async {
      if (data.session?.user != null) {
        state = await _getUserWithProfile(data.session!.user);
      } else {
        state = null;
      }
    });
  }

  Future<void> _initializeUser() async {
    final currentUser = _authRepository.getCurrentUser();
    if (currentUser != null) {
      state = await _getUserWithProfile(currentUser);
    } else {
      state = null;
    }
  }

  Future<UserWithProfile?> _getUserWithProfile(User user) async {
    try {
      final response = await _supabase
          .from('profiles')
          .select('username')
          .eq('id', user.id)
          .single();
      final username = response['username'] as String?;
      return UserWithProfile(user: user, username: username);
    } catch (e) {
      print('Error fetching user profile: $e');
      return UserWithProfile(user: user);
    }
  }

  Future<void> signUp(String email, String password, String username) async {
    try {
      await _authRepository.signUp(email, password, username);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signIn(String email, String password) async {
    try {
      await _authRepository.signIn(email, password);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      await _authRepository.signOut();
    } catch (e) {
      rethrow;
    }
  }
}

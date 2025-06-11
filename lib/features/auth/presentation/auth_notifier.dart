import 'package:flutter_riverpod/flutter_riverpod.dart' as riverpod;
import 'package:supabase_flutter/supabase_flutter.dart' hide Provider;
import 'package:vibe_coding_flutter/features/auth/data/supabase_auth_repository.dart';
import 'package:vibe_coding_flutter/features/auth/domain/user_with_profile.dart';
import 'package:vibe_coding_flutter/providers.dart';

// Removed: final authRepositoryProvider = riverpod.Provider(
//   (ref) => SupabaseAuthRepository(
//     Supabase.instance.client,
//     ref.watch(loggerProvider),
//   ),
// );

final authNotifierProvider =
    riverpod.StateNotifierProvider<AuthNotifier, UserWithProfile?>((ref) {
      return AuthNotifier(ref.watch(authRepositoryProvider));
    });

class AuthNotifier extends riverpod.StateNotifier<UserWithProfile?> {
  final SupabaseAuthRepository _authRepository;

  AuthNotifier(this._authRepository) : super(null) {
    _initializeUser();
    _authRepository.authStateChanges.listen((data) async {
      if (data.session?.user != null) {
        state = await _authRepository.getUserWithProfile(data.session!.user);
      } else {
        state = null;
      }
    });
  }

  Future<void> _initializeUser() async {
    final currentUser = _authRepository.getCurrentUser();
    if (currentUser != null) {
      state = await _authRepository.getUserWithProfile(currentUser);
    } else {
      state = null;
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

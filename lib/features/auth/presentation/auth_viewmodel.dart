import 'package:flutter/material.dart';
import 'package:vibe_coding_flutter/features/auth/application/auth_usecase.dart';
import 'package:vibe_coding_flutter/features/auth/domain/user_entity.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthUseCase useCase;
  UserEntity? user;
  String? error;

  AuthViewModel(this.useCase);

  Future<void> signUp(String email, String password) async {
    try {
      user = await useCase.signUp(email, password);
      error = null;
    } catch (e) {
      error = e.toString();
    }
    notifyListeners();
  }

  Future<void> signIn(String email, String password) async {
    try {
      user = await useCase.signIn(email, password);
      error = null;
    } catch (e) {
      error = e.toString();
    }
    notifyListeners();
  }

  Future<void> signOut() async {
    await useCase.signOut();
    user = null;
    notifyListeners();
  }
}

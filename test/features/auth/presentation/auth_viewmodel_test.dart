import 'package:flutter_test/flutter_test.dart';
import 'package:vibe_coding_flutter/features/auth/presentation/auth_viewmodel.dart';
import 'package:vibe_coding_flutter/features/auth/application/auth_usecase.dart';
import 'package:vibe_coding_flutter/features/auth/domain/auth_repository.dart';
import 'package:vibe_coding_flutter/features/auth/domain/user_entity.dart';

class FakeAuthRepository implements AuthRepository {
  UserEntity? _user;

  @override
  Future<UserEntity> signUp(String email, String password) async {
    _user = UserEntity(id: '1', email: email);
    return _user!;
  }

  @override
  Future<UserEntity> signIn(String email, String password) async {
    if (_user != null && _user!.email == email) {
      return _user!;
    }
    throw Exception('User not found');
  }

  @override
  Future<void> signOut() async {
    _user = null;
  }
}

void main() {
  group('AuthViewModel', () {
    late AuthViewModel viewModel;

    setUp(() {
      viewModel = AuthViewModel(AuthUseCase(FakeAuthRepository()));
    });

    test('signUp sets user and clears error', () async {
      await viewModel.signUp('test@email.com', 'password');
      expect(viewModel.user, isA<UserEntity>());
      expect(viewModel.user!.email, 'test@email.com');
      expect(viewModel.error, isNull);
    });

    test('signIn sets user and clears error', () async {
      await viewModel.signUp('test@email.com', 'password');
      await viewModel.signIn('test@email.com', 'password');
      expect(viewModel.user, isA<UserEntity>());
      expect(viewModel.user!.email, 'test@email.com');
      expect(viewModel.error, isNull);
    });

    test('signOut clears user', () async {
      await viewModel.signUp('test@email.com', 'password');
      await viewModel.signOut();
      expect(viewModel.user, isNull);
    });

    test('signIn with wrong email sets error', () async {
      await viewModel.signUp('test@email.com', 'password');
      await viewModel.signOut();
      await viewModel.signIn('wrong@email.com', 'password');
      expect(viewModel.user, isNull);
      expect(viewModel.error, isNotNull);
    });
  });
}

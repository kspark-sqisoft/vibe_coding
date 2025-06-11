import 'package:flutter_test/flutter_test.dart';
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
  group('AuthRepository', () {
    late AuthRepository repository;

    setUp(() {
      repository = FakeAuthRepository();
    });

    test('signUp returns a UserEntity', () async {
      final user = await repository.signUp('test@email.com', 'password');
      expect(user, isA<UserEntity>());
      expect(user.email, 'test@email.com');
    });

    test('signIn returns the same user after signUp', () async {
      await repository.signUp('test@email.com', 'password');
      final user = await repository.signIn('test@email.com', 'password');
      expect(user.email, 'test@email.com');
    });

    test('signOut clears the user', () async {
      await repository.signUp('test@email.com', 'password');
      await repository.signOut();
      expect(
        () => repository.signIn('test@email.com', 'password'),
        throwsException,
      );
    });
  });
}

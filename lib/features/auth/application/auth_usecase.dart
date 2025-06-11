import '../domain/auth_repository.dart';
import '../domain/user_entity.dart';

class AuthUseCase {
  final AuthRepository repository;

  AuthUseCase(this.repository);

  Future<UserEntity> signUp(String email, String password) {
    return repository.signUp(email, password);
  }

  Future<UserEntity> signIn(String email, String password) {
    return repository.signIn(email, password);
  }

  Future<void> signOut() {
    return repository.signOut();
  }
}

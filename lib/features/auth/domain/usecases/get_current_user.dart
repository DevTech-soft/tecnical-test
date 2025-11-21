import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class GetCurrentUser {
  final AuthRepository repository;

  GetCurrentUser(this.repository);

  User? call() {
    return repository.getCurrentUser();
  }

  Stream<User?> get authStateChanges {
    return repository.authStateChanges;
  }
}

import '../../../../core/usecases/usecase.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class SignUpWithEmail extends UseCase<User, SignUpWithEmailParams> {
  final AuthRepository repository;

  SignUpWithEmail(this.repository);

  @override
  Future<User> call(SignUpWithEmailParams params) async {
    return await repository.signUpWithEmail(
      email: params.email,
      password: params.password,
      firstName: params.firstName,
      lastName: params.lastName,
    );
  }
}

class SignUpWithEmailParams {
  final String email;
  final String password;
  final String firstName;
  final String lastName;

  SignUpWithEmailParams({
    required this.email,
    required this.password,
    required this.firstName,
    required this.lastName,
  });
}

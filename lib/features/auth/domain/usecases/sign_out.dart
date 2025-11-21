import '../../../../core/usecases/usecase.dart';
import '../repositories/auth_repository.dart';
import 'sign_in_with_google.dart';

class SignOut extends UseCase<void, NoParams> {
  final AuthRepository repository;

  SignOut(this.repository);

  @override
  Future<void> call(NoParams params) async {
    return await repository.signOut();
  }
}

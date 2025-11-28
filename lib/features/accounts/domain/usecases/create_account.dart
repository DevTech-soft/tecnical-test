import '../entities/account.dart';
import '../repositories/account_repository.dart';

class CreateAccount {
  final AccountRepository repository;

  CreateAccount(this.repository);

  Future<void> call(Account account) async {
    return await repository.createAccount(account);
  }
}

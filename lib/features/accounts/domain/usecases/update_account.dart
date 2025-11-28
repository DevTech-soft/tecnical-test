import '../entities/account.dart';
import '../repositories/account_repository.dart';

class UpdateAccount {
  final AccountRepository repository;

  UpdateAccount(this.repository);

  Future<void> call(Account account) async {
    return await repository.updateAccount(account);
  }
}

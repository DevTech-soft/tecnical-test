import '../entities/account.dart';
import '../repositories/account_repository.dart';

class GetAccountById {
  final AccountRepository repository;

  GetAccountById(this.repository);

  Future<Account?> call(String id) async {
    return await repository.getAccountById(id);
  }
}

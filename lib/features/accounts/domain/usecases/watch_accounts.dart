import '../entities/account.dart';
import '../repositories/account_repository.dart';

class WatchAccounts {
  final AccountRepository repository;

  WatchAccounts(this.repository);

  Stream<List<Account>> call() {
    return repository.watchAccounts();
  }
}

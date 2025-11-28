import '../entities/account.dart';

abstract class AccountRepository {
  Future<void> createAccount(Account account);
  Future<List<Account>> getAllAccounts();
  Future<Account?> getAccountById(String id);
  Future<void> updateAccount(Account account);
  Future<void> deleteAccount(String id);
  Stream<List<Account>> watchAccounts();
}

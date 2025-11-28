import 'package:hive/hive.dart';
import '../models/account_model.dart';

abstract class AccountLocalDataSource {
  Future<void> addAccount(AccountModel account);
  Future<List<AccountModel>> getAllAccounts();
  Future<AccountModel?> getAccountById(String id);
  Future<void> updateAccount(AccountModel account);
  Future<void> deleteAccount(String id);
}

class AccountLocalDataSourceImpl implements AccountLocalDataSource {
  final Box<AccountModel> box;

  AccountLocalDataSourceImpl(this.box);

  @override
  Future<void> addAccount(AccountModel account) async {
    await box.put(account.id, account);
  }

  @override
  Future<List<AccountModel>> getAllAccounts() async {
    return box.values.toList();
  }

  @override
  Future<AccountModel?> getAccountById(String id) async {
    return box.get(id);
  }

  @override
  Future<void> updateAccount(AccountModel account) async {
    await box.put(account.id, account);
  }

  @override
  Future<void> deleteAccount(String id) async {
    await box.delete(id);
  }
}

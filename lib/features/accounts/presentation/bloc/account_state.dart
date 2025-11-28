import 'package:equatable/equatable.dart';
import '../../domain/entities/account.dart';

abstract class AccountState extends Equatable {
  const AccountState();

  @override
  List<Object?> get props => [];
}

class AccountInitial extends AccountState {}

class AccountLoading extends AccountState {}

class AccountLoaded extends AccountState {
  final List<Account> accounts;

  const AccountLoaded(this.accounts);

  @override
  List<Object?> get props => [accounts];

  bool get hasAccounts => accounts.isNotEmpty;

  double get totalBalance =>
      accounts.fold(0, (sum, account) => sum + account.balance);
}

class AccountError extends AccountState {
  final String message;

  const AccountError(this.message);

  @override
  List<Object?> get props => [message];
}

class AccountOperationSuccess extends AccountState {
  final String message;

  const AccountOperationSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

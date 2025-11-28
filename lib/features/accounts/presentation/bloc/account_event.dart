import 'package:equatable/equatable.dart';
import '../../domain/entities/account.dart';

abstract class AccountEvent extends Equatable {
  const AccountEvent();

  @override
  List<Object?> get props => [];
}

class LoadAccounts extends AccountEvent {}

class CreateAccountEvent extends AccountEvent {
  final Account account;

  const CreateAccountEvent(this.account);

  @override
  List<Object?> get props => [account];
}

class UpdateAccountEvent extends AccountEvent {
  final Account account;

  const UpdateAccountEvent(this.account);

  @override
  List<Object?> get props => [account];
}

class DeleteAccountEvent extends AccountEvent {
  final String accountId;

  const DeleteAccountEvent(this.accountId);

  @override
  List<Object?> get props => [accountId];
}

class UpdateAccountBalance extends AccountEvent {
  final String accountId;
  final double newBalance;

  const UpdateAccountBalance({
    required this.accountId,
    required this.newBalance,
  });

  @override
  List<Object?> get props => [accountId, newBalance];
}

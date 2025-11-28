import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/account.dart';
import '../../domain/usecases/create_account.dart';
import '../../domain/usecases/delete_account.dart';
import '../../domain/usecases/get_all_accounts.dart';
import '../../domain/usecases/get_account_by_id.dart';
import '../../domain/usecases/update_account.dart';
import 'account_event.dart';
import 'account_state.dart';

class AccountBloc extends Bloc<AccountEvent, AccountState> {
  final CreateAccount createAccount;
  final GetAllAccounts getAllAccounts;
  final GetAccountById getAccountById;
  final UpdateAccount updateAccount;
  final DeleteAccount deleteAccount;

  AccountBloc({
    required this.createAccount,
    required this.getAllAccounts,
    required this.getAccountById,
    required this.updateAccount,
    required this.deleteAccount,
  }) : super(AccountInitial()) {
    on<LoadAccounts>(_onLoadAccounts);
    on<CreateAccountEvent>(_onCreateAccount);
    on<UpdateAccountEvent>(_onUpdateAccount);
    on<DeleteAccountEvent>(_onDeleteAccount);
    on<UpdateAccountBalance>(_onUpdateAccountBalance);
  }

  Future<void> _onLoadAccounts(
    LoadAccounts event,
    Emitter<AccountState> emit,
  ) async {
    emit(AccountLoading());
    try {
      final accounts = await getAllAccounts();
      emit(AccountLoaded(accounts));
    } catch (e) {
      emit(AccountError('Error al cargar cuentas: ${e.toString()}'));
    }
  }

  Future<void> _onCreateAccount(
    CreateAccountEvent event,
    Emitter<AccountState> emit,
  ) async {
    try {
      await createAccount(event.account);
      final accounts = await getAllAccounts();
      emit(AccountLoaded(accounts));
    } catch (e) {
      emit(AccountError('Error al crear cuenta: ${e.toString()}'));
    }
  }

  Future<void> _onUpdateAccount(
    UpdateAccountEvent event,
    Emitter<AccountState> emit,
  ) async {
    try {
      await updateAccount(event.account);
      final accounts = await getAllAccounts();
      emit(AccountLoaded(accounts));
    } catch (e) {
      emit(AccountError('Error al actualizar cuenta: ${e.toString()}'));
    }
  }

  Future<void> _onDeleteAccount(
    DeleteAccountEvent event,
    Emitter<AccountState> emit,
  ) async {
    try {
      await deleteAccount(event.accountId);
      final accounts = await getAllAccounts();
      emit(AccountLoaded(accounts));
    } catch (e) {
      emit(AccountError('Error al eliminar cuenta: ${e.toString()}'));
    }
  }

  Future<void> _onUpdateAccountBalance(
    UpdateAccountBalance event,
    Emitter<AccountState> emit,
  ) async {
    try {
      final account = await getAccountById(event.accountId);
      if (account != null) {
        final updatedAccount = account.copyWith(
          balance: event.newBalance,
          updatedAt: DateTime.now(),
        );
        await updateAccount(updatedAccount);
        final accounts = await getAllAccounts();
        emit(AccountLoaded(accounts));
      }
    } catch (e) {
      emit(AccountError('Error al actualizar balance: ${e.toString()}'));
    }
  }
}

import '../../../accounts/domain/usecases/get_account_by_id.dart';
import '../../../accounts/domain/usecases/update_account.dart';
import '../repositories/expense_repository.dart';
import 'get_expense_by_id.dart';

class DeleteExpenseWithAccountUpdate {
  final ExpenseRepository expenseRepository;
  final GetExpenseById getExpenseById;
  final GetAccountById getAccountById;
  final UpdateAccount updateAccount;

  DeleteExpenseWithAccountUpdate({
    required this.expenseRepository,
    required this.getExpenseById,
    required this.getAccountById,
    required this.updateAccount,
  });

  Future<void> call(String expenseId) async {
    // 1. Obtener el gasto antes de eliminarlo
    final expense = await getExpenseById(expenseId);
    if (expense == null) {
      throw Exception('Gasto no encontrado');
    }

    // 2. Eliminar el gasto (local + remoto)
    await expenseRepository.deleteExpense(expenseId);

    // 3. Devolver el monto a la cuenta
    try {
      final account = await getAccountById(expense.accountId);
      if (account != null) {
        final restoredBalance = account.balance + expense.amount;
        final updatedAccount = account.copyWith(
          balance: restoredBalance,
          updatedAt: DateTime.now(),
        );
        await updateAccount(updatedAccount);
      }
    } catch (e) {
      // Si falla actualizar cuenta, rollback del gasto
      try {
        await expenseRepository.addExpense(expense);
      } catch (rollbackError) {
        // Log error
      }
      rethrow;
    }
  }
}

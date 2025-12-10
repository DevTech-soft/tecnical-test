import '../../../../core/validators/input_validators.dart';
import '../../../accounts/domain/usecases/get_account_by_id.dart';
import '../../../accounts/domain/usecases/update_account.dart';
import '../repositories/expense_repository.dart';
import '../entities/expense.dart';

class AddExpenseWithAccountUpdate {
  final ExpenseRepository expenseRepository;
  final GetAccountById getAccountById;
  final UpdateAccount updateAccount;

  AddExpenseWithAccountUpdate({
    required this.expenseRepository,
    required this.getAccountById,
    required this.updateAccount,
  });

  Future<void> call(Expense expense) async {
    // 1. Validar datos
    _validateExpense(expense);

    // 2. Obtener cuenta actual
    final account = await getAccountById(expense.accountId);
    if (account == null) {
      throw Exception('Cuenta no encontrada');
    }

    // 3. Calcular nuevo balance (restar el gasto)
    final newBalance = account.balance - expense.amount;

    // 4. Guardar el gasto (local + remoto)
    await expenseRepository.addExpense(expense);

    // 5. Actualizar balance de la cuenta (local + remoto)
    try {
      final updatedAccount = account.copyWith(
        balance: newBalance,
        updatedAt: DateTime.now(),
      );
      await updateAccount(updatedAccount);
    } catch (e) {
      // Si falla actualizar cuenta, intentar rollback del gasto
      try {
        await expenseRepository.deleteExpense(expense.id);
      } catch (rollbackError) {
        // Log error pero no lanzar
      }
      rethrow; // Re-lanzar el error original
    }
  }

  void _validateExpense(Expense expense) {
    InputValidators.validateAmount(expense.amount);
    InputValidators.validateDate(expense.date, allowFuture: false);
    InputValidators.validateCategoryId(expense.categoryId);
    if (expense.note != null && expense.note!.isNotEmpty) {
      InputValidators.validateAndSanitizeText(
        expense.note,
        fieldName: 'nota',
        required: false,
        maxLength: 500,
      );
    }
  }
}

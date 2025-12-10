import '../../../../core/validators/input_validators.dart';
import '../../../accounts/domain/usecases/get_account_by_id.dart';
import '../../../accounts/domain/usecases/update_account.dart';
import '../repositories/expense_repository.dart';
import '../entities/expense.dart';
import 'get_expense_by_id.dart';

class UpdateExpenseWithAccountUpdate {
  final ExpenseRepository expenseRepository;
  final GetExpenseById getExpenseById;
  final GetAccountById getAccountById;
  final UpdateAccount updateAccount;

  UpdateExpenseWithAccountUpdate({
    required this.expenseRepository,
    required this.getExpenseById,
    required this.getAccountById,
    required this.updateAccount,
  });

  Future<void> call(Expense newExpense) async {
    // 1. Validar datos
    _validateExpense(newExpense);

    // 2. Obtener el gasto antiguo
    final oldExpense = await getExpenseById(newExpense.id);
    if (oldExpense == null) {
      throw Exception('Gasto no encontrado');
    }

    // 3. Determinar si cambió la cuenta o el monto
    final accountChanged = oldExpense.accountId != newExpense.accountId;
    final amountChanged = oldExpense.amount != newExpense.amount;

    if (!accountChanged && !amountChanged) {
      // Solo cambió nota o categoría, actualizar sin tocar balance
      await expenseRepository.updateExpense(newExpense);
      return;
    }

    // 4. Actualizar gasto (local + remoto)
    await expenseRepository.updateExpense(newExpense);

    // 5. Actualizar balance(s)
    try {
      if (accountChanged) {
        // Caso: Cambio de cuenta (puede o no cambiar monto)
        await _handleAccountChange(oldExpense, newExpense);
      } else if (amountChanged) {
        // Caso: Solo cambió el monto, misma cuenta
        await _handleAmountChange(oldExpense, newExpense);
      }
    } catch (e) {
      // Si falla actualizar cuenta(s), rollback del gasto
      try {
        await expenseRepository.updateExpense(oldExpense);
      } catch (rollbackError) {
        // Log error
      }
      rethrow;
    }
  }

  Future<void> _handleAccountChange(Expense oldExpense, Expense newExpense) async {
    // Devolver dinero a cuenta antigua
    final oldAccount = await getAccountById(oldExpense.accountId);
    if (oldAccount != null) {
      final restoredBalance = oldAccount.balance + oldExpense.amount;
      final updatedOldAccount = oldAccount.copyWith(
        balance: restoredBalance,
        updatedAt: DateTime.now(),
      );
      await updateAccount(updatedOldAccount);
    }

    // Restar dinero de cuenta nueva
    final newAccount = await getAccountById(newExpense.accountId);
    if (newAccount != null) {
      final deductedBalance = newAccount.balance - newExpense.amount;
      final updatedNewAccount = newAccount.copyWith(
        balance: deductedBalance,
        updatedAt: DateTime.now(),
      );
      await updateAccount(updatedNewAccount);
    }
  }

  Future<void> _handleAmountChange(Expense oldExpense, Expense newExpense) async {
    final account = await getAccountById(newExpense.accountId);
    if (account == null) return;

    // Calcular ajuste: devolver monto antiguo y restar monto nuevo
    final adjustment = oldExpense.amount - newExpense.amount;
    final newBalance = account.balance + adjustment;

    final updatedAccount = account.copyWith(
      balance: newBalance,
      updatedAt: DateTime.now(),
    );
    await updateAccount(updatedAccount);
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

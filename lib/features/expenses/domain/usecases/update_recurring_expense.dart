import '../../../../core/usecases/usecase.dart';
import '../entities/recurring_expense.dart';
import '../repositories/recurring_expense_repository.dart';

/// Use case para actualizar un gasto recurrente existente
class UpdateRecurringExpense implements UseCase<void, RecurringExpense> {
  final RecurringExpenseRepository repository;

  UpdateRecurringExpense(this.repository);

  @override
  Future<void> call(RecurringExpense recurringExpense) async {
    await repository.updateRecurringExpense(recurringExpense);
  }
}

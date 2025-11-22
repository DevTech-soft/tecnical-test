import '../../../../core/usecases/usecase.dart';
import '../entities/recurring_expense.dart';
import '../repositories/recurring_expense_repository.dart';

/// Use case para crear un gasto recurrente
class CreateRecurringExpense
    implements UseCase<void, RecurringExpense> {
  final RecurringExpenseRepository repository;

  CreateRecurringExpense(this.repository);

  @override
  Future<void> call(RecurringExpense recurringExpense) async {
    // TODO: Agregar validaciones si es necesario
    // - Validar que amount > 0
    // - Validar que startDate no sea muy antigua
    // - Validar que endDate sea después de startDate

    await repository.createRecurringExpense(recurringExpense);
  }
}

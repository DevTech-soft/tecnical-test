import '../../../../core/usecases/usecase.dart';
import '../repositories/recurring_expense_repository.dart';

/// Use case para eliminar un gasto recurrente
class DeleteRecurringExpense implements UseCase<void, String> {
  final RecurringExpenseRepository repository;

  DeleteRecurringExpense(this.repository);

  @override
  Future<void> call(String id) async {
    await repository.deleteRecurringExpense(id);
  }
}

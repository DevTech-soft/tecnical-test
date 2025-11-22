import '../../../../core/usecases/usecase.dart';
import '../entities/recurring_expense.dart';
import '../repositories/recurring_expense_repository.dart';

/// Use case para obtener todos los gastos recurrentes
class GetAllRecurringExpenses implements UseCase<List<RecurringExpense>, NoParams> {
  final RecurringExpenseRepository repository;

  GetAllRecurringExpenses(this.repository);

  @override
  Future<List<RecurringExpense>> call(NoParams params) async {
    return await repository.getAllRecurringExpenses();
  }
}

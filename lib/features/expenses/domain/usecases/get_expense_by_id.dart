import '../entities/expense.dart';
import '../repositories/expense_repository.dart';

class GetExpenseById {
  final ExpenseRepository repository;

  GetExpenseById(this.repository);

  Future<Expense?> call(String id) async {
    return await repository.getExpenseById(id);
  }
}

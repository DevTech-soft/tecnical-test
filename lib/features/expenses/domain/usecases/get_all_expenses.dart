import '../repositories/expense_repository.dart';
import '../entities/expense.dart';

class GetAllExpenses {
  final ExpenseRepository repository;

  GetAllExpenses(this.repository);

  Future<List<Expense>> call() async {
    return await repository.getAllExpenses();
  }
}

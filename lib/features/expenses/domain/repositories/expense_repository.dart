import '../entities/expense.dart';

abstract class ExpenseRepository {
  Future<void> addExpense(Expense expense);
  Future<List<Expense>> getAllExpenses();
  Future<Expense?> getExpenseById(String id);
  Future<void> deleteExpense(String id);
  Future<void> updateExpense(Expense expense);
  Future<List<Expense>> getExpensesByDateRange({
    required DateTime startDate,
    required DateTime endDate,
  });
}

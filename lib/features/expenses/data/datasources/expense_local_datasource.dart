import 'package:hive/hive.dart';
import '../models/expense_model.dart';

abstract class ExpenseLocalDataSource {
  Future<void> addExpense(ExpenseModel expense);
  Future<List<ExpenseModel>> getAllExpenses();
  Future<ExpenseModel?> getExpenseById(String id);
  Future<void> deleteExpense(String id);
  Future<void> updateExpense(ExpenseModel expense);
}

class ExpenseLocalDataSourceImpl implements ExpenseLocalDataSource {
  final Box<ExpenseModel> box;

  ExpenseLocalDataSourceImpl(this.box);

  @override
  Future<void> addExpense(ExpenseModel expense) async {
    await box.put(expense.id, expense);
  }

  @override
  Future<List<ExpenseModel>> getAllExpenses() async {
    return box.values.toList();
  }

  @override
  Future<ExpenseModel?> getExpenseById(String id) async {
    return box.get(id);
  }

  @override
  Future<void> deleteExpense(String id) async {
    await box.delete(id);
  }

  @override
  Future<void> updateExpense(ExpenseModel expense) async {
    await box.put(expense.id, expense);
  }
}

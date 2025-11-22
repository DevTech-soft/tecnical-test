import 'package:hive/hive.dart';
import '../models/recurring_expense_model.dart';

/// Data source local para gastos recurrentes usando Hive
abstract class RecurringExpenseLocalDataSource {
  Future<void> createRecurringExpense(RecurringExpenseModel model);
  Future<List<RecurringExpenseModel>> getAllRecurringExpenses();
  Future<RecurringExpenseModel?> getRecurringExpenseById(String id);
  Future<void> updateRecurringExpense(RecurringExpenseModel model);
  Future<void> deleteRecurringExpense(String id);
}

class RecurringExpenseLocalDataSourceImpl
    implements RecurringExpenseLocalDataSource {
  final Box<RecurringExpenseModel> box;

  RecurringExpenseLocalDataSourceImpl(this.box);

  @override
  Future<void> createRecurringExpense(RecurringExpenseModel model) async {
    await box.put(model.id, model);
  }

  @override
  Future<List<RecurringExpenseModel>> getAllRecurringExpenses() async {
    return box.values.toList();
  }

  @override
  Future<RecurringExpenseModel?> getRecurringExpenseById(String id) async {
    return box.get(id);
  }

  @override
  Future<void> updateRecurringExpense(RecurringExpenseModel model) async {
    await box.put(model.id, model);
  }

  @override
  Future<void> deleteRecurringExpense(String id) async {
    await box.delete(id);
  }
}

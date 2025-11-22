import '../../domain/entities/recurring_expense.dart';
import '../../domain/repositories/recurring_expense_repository.dart';
import '../datasources/recurring_expense_local_datasource.dart';
import '../models/recurring_expense_model.dart';

/// Implementación del repositorio de gastos recurrentes
///
/// Esta clase es "tonta" - solo traduce entre modelos y entidades,
/// y delega el acceso a datos al datasource.
class RecurringExpenseRepositoryImpl implements RecurringExpenseRepository {
  final RecurringExpenseLocalDataSource localDataSource;

  RecurringExpenseRepositoryImpl({required this.localDataSource});

  @override
  Future<void> createRecurringExpense(RecurringExpense recurringExpense) async {
    final model = RecurringExpenseModel.fromEntity(recurringExpense);
    await localDataSource.createRecurringExpense(model);
  }

  @override
  Future<List<RecurringExpense>> getAllRecurringExpenses() async {
    final models = await localDataSource.getAllRecurringExpenses();
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<RecurringExpense?> getRecurringExpenseById(String id) async {
    final model = await localDataSource.getRecurringExpenseById(id);
    return model?.toEntity();
  }

  @override
  Future<void> updateRecurringExpense(RecurringExpense recurringExpense) async {
    final model = RecurringExpenseModel.fromEntity(recurringExpense);
    await localDataSource.updateRecurringExpense(model);
  }

  @override
  Future<void> deleteRecurringExpense(String id) async {
    await localDataSource.deleteRecurringExpense(id);
  }

  @override
  Future<List<RecurringExpense>> getActiveRecurringExpenses() async {
    final all = await getAllRecurringExpenses();
    return all.where((expense) => expense.isActive).toList();
  }

  @override
  Future<List<RecurringExpense>> getRecurringExpensesDueForGeneration() async {
    final active = await getActiveRecurringExpenses();
    return active.where((expense) => expense.shouldGenerateNow()).toList();
  }
}

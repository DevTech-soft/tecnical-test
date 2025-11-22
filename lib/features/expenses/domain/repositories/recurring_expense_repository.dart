import '../entities/recurring_expense.dart';

/// Repositorio abstracto para gastos recurrentes
///
/// Define los métodos de acceso a datos para gastos recurrentes.
/// La implementación concreta estará en la capa de datos.
abstract class RecurringExpenseRepository {
  /// Crea un nuevo gasto recurrente
  Future<void> createRecurringExpense(RecurringExpense recurringExpense);

  /// Obtiene todos los gastos recurrentes
  Future<List<RecurringExpense>> getAllRecurringExpenses();

  /// Obtiene un gasto recurrente por ID
  Future<RecurringExpense?> getRecurringExpenseById(String id);

  /// Actualiza un gasto recurrente existente
  Future<void> updateRecurringExpense(RecurringExpense recurringExpense);

  /// Elimina un gasto recurrente
  Future<void> deleteRecurringExpense(String id);

  /// Obtiene solo los gastos recurrentes activos
  Future<List<RecurringExpense>> getActiveRecurringExpenses();

  /// Obtiene los gastos recurrentes que deben generar un gasto ahora
  Future<List<RecurringExpense>> getRecurringExpensesDueForGeneration();
}

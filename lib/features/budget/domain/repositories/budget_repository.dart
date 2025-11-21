import '../entities/budget.dart';

abstract class BudgetRepository {
  /// Crea un nuevo presupuesto
  Future<Budget> createBudget(Budget budget);

  /// Obtiene un presupuesto por ID
  Future<Budget?> getBudgetById(String id);

  /// Obtiene el presupuesto general del mes y año especificado
  Future<Budget?> getGeneralBudget({required int month, required int year});

  /// Obtiene el presupuesto de una categoría específica para el mes y año especificado
  Future<Budget?> getCategoryBudget({
    required String categoryId,
    required int month,
    required int year,
  });

  /// Obtiene todos los presupuestos de un mes y año específico
  Future<List<Budget>> getBudgetsByPeriod({
    required int month,
    required int year,
  });

  /// Obtiene todos los presupuestos (para histórico)
  Future<List<Budget>> getAllBudgets();

  /// Actualiza un presupuesto existente
  Future<Budget> updateBudget(Budget budget);

  /// Elimina un presupuesto por ID
  Future<void> deleteBudget(String id);

  /// Elimina todos los presupuestos de un período específico
  Future<void> deleteBudgetsByPeriod({required int month, required int year});

  /// Verifica si existe un presupuesto general para el mes y año especificado
  Future<bool> hasGeneralBudget({required int month, required int year});

  /// Verifica si existe un presupuesto para una categoría en el mes y año especificado
  Future<bool> hasCategoryBudget({
    required String categoryId,
    required int month,
    required int year,
  });
}

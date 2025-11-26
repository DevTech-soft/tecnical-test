import '../entities/budget.dart';

abstract class BudgetRepository {
  Future<Budget> createBudget(Budget budget);

  Future<Budget?> getBudgetById(String id);

  Future<Budget?> getGeneralBudget({required int month, required int year});

  Future<Budget?> getCategoryBudget({
    required String categoryId,
    required int month,
    required int year,
  });

  Future<List<Budget>> getBudgetsByPeriod({
    required int month,
    required int year,
  });

  Future<List<Budget>> getAllBudgets();

  Future<Budget> updateBudget(Budget budget);

  Future<void> deleteBudget(String id);

  Future<void> deleteBudgetsByPeriod({required int month, required int year});

  Future<bool> hasGeneralBudget({required int month, required int year});

  Future<bool> hasCategoryBudget({
    required String categoryId,
    required int month,
    required int year,
  });
}

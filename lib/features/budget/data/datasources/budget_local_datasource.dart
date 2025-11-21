import 'package:hive/hive.dart';
import '../models/budget_model.dart';

abstract class BudgetLocalDataSource {
  Future<void> addBudget(BudgetModel budget);
  Future<BudgetModel?> getBudgetById(String id);
  Future<BudgetModel?> getGeneralBudget({required int month, required int year});
  Future<BudgetModel?> getCategoryBudget({
    required String categoryId,
    required int month,
    required int year,
  });
  Future<List<BudgetModel>> getBudgetsByPeriod({
    required int month,
    required int year,
  });
  Future<List<BudgetModel>> getAllBudgets();
  Future<void> updateBudget(BudgetModel budget);
  Future<void> deleteBudget(String id);
}

class BudgetLocalDataSourceImpl implements BudgetLocalDataSource {
  final Box<BudgetModel> budgetBox;

  BudgetLocalDataSourceImpl({required this.budgetBox});

  @override
  Future<void> addBudget(BudgetModel budget) async {
    await budgetBox.put(budget.id, budget);
  }

  @override
  Future<BudgetModel?> getBudgetById(String id) async {
    return budgetBox.get(id);
  }

  @override
  Future<BudgetModel?> getGeneralBudget({
    required int month,
    required int year,
  }) async {
    final budgets = budgetBox.values.where((budget) {
      return budget.month == month &&
          budget.year == year &&
          budget.categoryId == null;
    }).toList();

    return budgets.isNotEmpty ? budgets.first : null;
  }

  @override
  Future<BudgetModel?> getCategoryBudget({
    required String categoryId,
    required int month,
    required int year,
  }) async {
    final budgets = budgetBox.values.where((budget) {
      return budget.month == month &&
          budget.year == year &&
          budget.categoryId == categoryId;
    }).toList();

    return budgets.isNotEmpty ? budgets.first : null;
  }

  @override
  Future<List<BudgetModel>> getBudgetsByPeriod({
    required int month,
    required int year,
  }) async {
    final budgets = budgetBox.values.where((budget) {
      return budget.month == month && budget.year == year;
    }).toList();

    return budgets;
  }

  @override
  Future<List<BudgetModel>> getAllBudgets() async {
    return budgetBox.values.toList();
  }

  @override
  Future<void> updateBudget(BudgetModel budget) async {
    await budgetBox.put(budget.id, budget);
  }

  @override
  Future<void> deleteBudget(String id) async {
    await budgetBox.delete(id);
  }
}

import '../../domain/entities/budget.dart';
import '../../domain/repositories/budget_repository.dart';
import '../datasources/budget_local_datasource.dart';
import '../models/budget_model.dart';

class BudgetRepositoryImpl implements BudgetRepository {
  final BudgetLocalDataSource localDataSource;

  BudgetRepositoryImpl({required this.localDataSource});

  @override
  Future<Budget> createBudget(Budget budget) async {
    final model = BudgetModel.fromEntity(budget);
    await localDataSource.addBudget(model);
    return budget;
  }

  @override
  Future<Budget?> getBudgetById(String id) async {
    final model = await localDataSource.getBudgetById(id);
    return model?.toEntity();
  }

  @override
  Future<Budget?> getGeneralBudget({
    required int month,
    required int year,
  }) async {
    final model = await localDataSource.getGeneralBudget(
      month: month,
      year: year,
    );
    return model?.toEntity();
  }

  @override
  Future<Budget?> getCategoryBudget({
    required String categoryId,
    required int month,
    required int year,
  }) async {
    final model = await localDataSource.getCategoryBudget(
      categoryId: categoryId,
      month: month,
      year: year,
    );
    return model?.toEntity();
  }

  @override
  Future<List<Budget>> getBudgetsByPeriod({
    required int month,
    required int year,
  }) async {
    final models = await localDataSource.getBudgetsByPeriod(
      month: month,
      year: year,
    );
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<List<Budget>> getAllBudgets() async {
    final models = await localDataSource.getAllBudgets();
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<Budget> updateBudget(Budget budget) async {
    final model = BudgetModel.fromEntity(budget);
    await localDataSource.updateBudget(model);
    return budget;
  }

  @override
  Future<void> deleteBudget(String id) async {
    await localDataSource.deleteBudget(id);
  }

  @override
  Future<void> deleteBudgetsByPeriod({
    required int month,
    required int year,
  }) async {
    final budgets = await localDataSource.getBudgetsByPeriod(
      month: month,
      year: year,
    );
    for (final budget in budgets) {
      await localDataSource.deleteBudget(budget.id);
    }
  }

  @override
  Future<bool> hasGeneralBudget({required int month, required int year}) async {
    final budget = await localDataSource.getGeneralBudget(
      month: month,
      year: year,
    );
    return budget != null;
  }

  @override
  Future<bool> hasCategoryBudget({
    required String categoryId,
    required int month,
    required int year,
  }) async {
    final budget = await localDataSource.getCategoryBudget(
      categoryId: categoryId,
      month: month,
      year: year,
    );
    return budget != null;
  }
}

import '../../../auth/domain/repositories/auth_repository.dart';
import '../../domain/entities/budget.dart';
import '../../domain/repositories/budget_repository.dart';
import '../datasources/budget_local_datasource.dart';
import '../datasources/budget_remote_datasource.dart';
import '../models/budget_model.dart';

class BudgetRepositoryImpl implements BudgetRepository {
  final BudgetLocalDataSource localDataSource;
  final BudgetRemoteDataSource remoteDataSource;
  final AuthRepository authRepository;

  BudgetRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
    required this.authRepository,
  });

  @override
  Future<Budget> createBudget(Budget budget) async {
    final model = BudgetModel.fromEntity(budget);

    await localDataSource.addBudget(model);

    final user = authRepository.getCurrentUser();
    if (user != null) {
      try {
        await remoteDataSource.createBudget(user.id, model);
      } catch (e) {
        // Continuar aunque falle la sincronización
        // Los datos ya están guardados localmente
      }
    }

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
    final user = authRepository.getCurrentUser();

    if (user != null) {
      try {
        // Obtener desde Firestore y sincronizar con local
        final remoteModels = await remoteDataSource.getAllBudgets(user.id);

        // Actualizar cache local (eliminar todo y volver a agregar)
        final localModels = await localDataSource.getAllBudgets();
        for (final localModel in localModels) {
          await localDataSource.deleteBudget(localModel.id);
        }
        for (final remoteModel in remoteModels) {
          await localDataSource.addBudget(remoteModel);
        }

        return remoteModels.map((m) => m.toEntity()).toList();
      } catch (e) {
        // Si falla Firestore, usar datos locales
        final models = await localDataSource.getAllBudgets();
        return models.map((m) => m.toEntity()).toList();
      }
    } else {
      // Sin usuario autenticado, usar solo datos locales
      final models = await localDataSource.getAllBudgets();
      return models.map((m) => m.toEntity()).toList();
    }
  }

  @override
  Future<Budget> updateBudget(Budget budget) async {
    final model = BudgetModel.fromEntity(budget);

    // Actualizar localmente (offline-first)
    await localDataSource.updateBudget(model);

    // Sincronizar con Firestore si hay usuario autenticado
    final user = authRepository.getCurrentUser();
    if (user != null) {
      try {
        await remoteDataSource.updateBudget(user.id, model);
      } catch (e) {
        // Continuar aunque falle la sincronización
      }
    }

    return budget;
  }

  @override
  Future<void> deleteBudget(String id) async {
    // Eliminar localmente (offline-first)
    await localDataSource.deleteBudget(id);

    // Sincronizar con Firestore si hay usuario autenticado
    final user = authRepository.getCurrentUser();
    if (user != null) {
      try {
        await remoteDataSource.deleteBudget(user.id, id);
      } catch (e) {
        // Continuar aunque falle la sincronización
      }
    }
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

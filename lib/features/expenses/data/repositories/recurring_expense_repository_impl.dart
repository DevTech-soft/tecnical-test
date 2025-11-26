import '../../../auth/domain/repositories/auth_repository.dart';
import '../../domain/entities/recurring_expense.dart';
import '../../domain/repositories/recurring_expense_repository.dart';
import '../datasources/recurring_expense_local_datasource.dart';
import '../datasources/recurring_expense_remote_datasource.dart';
import '../models/recurring_expense_model.dart';

/// Implementación del repositorio de gastos recurrentes con sincronización offline-first
class RecurringExpenseRepositoryImpl implements RecurringExpenseRepository {
  final RecurringExpenseLocalDataSource localDataSource;
  final RecurringExpenseRemoteDataSource remoteDataSource;
  final AuthRepository authRepository;

  RecurringExpenseRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
    required this.authRepository,
  });

  @override
  Future<void> createRecurringExpense(RecurringExpense recurringExpense) async {
    final model = RecurringExpenseModel.fromEntity(recurringExpense);

    // Guardar localmente (offline-first)
    await localDataSource.createRecurringExpense(model);

    // Sincronizar con Firestore si hay usuario autenticado
    final user = authRepository.getCurrentUser();
    if (user != null) {
      try {
        await remoteDataSource.createRecurringExpense(user.id, model);
      } catch (e) {
        // Continuar aunque falle la sincronización
      }
    }
  }

  @override
  Future<List<RecurringExpense>> getAllRecurringExpenses() async {
    final user = authRepository.getCurrentUser();

    if (user != null) {
      try {
        // Obtener desde Firestore y sincronizar con local
        final remoteModels = await remoteDataSource.getAllRecurringExpenses(user.id);

        // Actualizar cache local
        final localModels = await localDataSource.getAllRecurringExpenses();
        for (final localModel in localModels) {
          await localDataSource.deleteRecurringExpense(localModel.id);
        }
        for (final remoteModel in remoteModels) {
          await localDataSource.createRecurringExpense(remoteModel);
        }

        return remoteModels.map((m) => m.toEntity()).toList();
      } catch (e) {
        // Si falla Firestore, usar datos locales
        final models = await localDataSource.getAllRecurringExpenses();
        return models.map((m) => m.toEntity()).toList();
      }
    } else {
      // Sin usuario autenticado, usar solo datos locales
      final models = await localDataSource.getAllRecurringExpenses();
      return models.map((m) => m.toEntity()).toList();
    }
  }

  @override
  Future<RecurringExpense?> getRecurringExpenseById(String id) async {
    final model = await localDataSource.getRecurringExpenseById(id);
    return model?.toEntity();
  }

  @override
  Future<void> updateRecurringExpense(RecurringExpense recurringExpense) async {
    final model = RecurringExpenseModel.fromEntity(recurringExpense);

    // Actualizar localmente (offline-first)
    await localDataSource.updateRecurringExpense(model);

    // Sincronizar con Firestore si hay usuario autenticado
    final user = authRepository.getCurrentUser();
    if (user != null) {
      try {
        await remoteDataSource.updateRecurringExpense(user.id, model);
      } catch (e) {
        // Continuar aunque falle la sincronización
      }
    }
  }

  @override
  Future<void> deleteRecurringExpense(String id) async {
    // Eliminar localmente (offline-first)
    await localDataSource.deleteRecurringExpense(id);

    // Sincronizar con Firestore si hay usuario autenticado
    final user = authRepository.getCurrentUser();
    if (user != null) {
      try {
        await remoteDataSource.deleteRecurringExpense(user.id, id);
      } catch (e) {
        // Continuar aunque falle la sincronización
      }
    }
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

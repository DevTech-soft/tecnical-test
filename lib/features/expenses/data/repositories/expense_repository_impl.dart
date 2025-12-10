import '../../../auth/domain/repositories/auth_repository.dart';
import '../../domain/entities/expense.dart';
import '../../domain/repositories/expense_repository.dart';
import '../datasources/expense_local_datasource.dart';
import '../datasources/expense_remote_datasource.dart';
import '../models/expense_model.dart';

class ExpenseRepositoryImpl implements ExpenseRepository {
  final ExpenseLocalDataSource local;
  final ExpenseRemoteDataSource remote;
  final AuthRepository authRepository;

  ExpenseRepositoryImpl({
    required this.local,
    required this.remote,
    required this.authRepository,
  });

  @override
  Future<void> addExpense(Expense expense) async {
    final model = ExpenseModel.fromEntity(expense);

    // Guardar localmente
    await local.addExpense(model);

    // Sincronizar con Firestore si hay usuario autenticado
    final user = authRepository.getCurrentUser();
    if (user != null) {
      await remote.addExpense(user.id, model);
    }
  }

  @override
  Future<List<Expense>> getAllExpenses() async {
    final user = authRepository.getCurrentUser();

    if (user != null) {
      try {
        // Obtener desde Firestore y sincronizar con local
        final remoteModels = await remote.getAllExpenses(user.id);

        // Actualizar cache local (eliminar todo y volver a agregar)
        final localModels = await local.getAllExpenses();
        for (final localModel in localModels) {
          await local.deleteExpense(localModel.id);
        }
        for (final remoteModel in remoteModels) {
          await local.addExpense(remoteModel);
        }

        return remoteModels.map((m) => m.toEntity()).toList();
      } catch (e) {
        // Si falla Firestore, usar datos locales
        final models = await local.getAllExpenses();
        return models.map((m) => m.toEntity()).toList();
      }
    } else {
      // Sin usuario autenticado, usar solo datos locales
      final models = await local.getAllExpenses();
      return models.map((m) => m.toEntity()).toList();
    }
  }

  @override
  Future<Expense?> getExpenseById(String id) async {
    final model = await local.getExpenseById(id);
    return model?.toEntity();
  }

  @override
  Future<void> deleteExpense(String id) async {
    // Eliminar localmente
    await local.deleteExpense(id);

    // Sincronizar con Firestore si hay usuario autenticado
    final user = authRepository.getCurrentUser();
    if (user != null) {
      await remote.deleteExpense(user.id, id);
    }
  }

  @override
  Future<void> updateExpense(Expense expense) async {
    final model = ExpenseModel.fromEntity(expense);

    // Actualizar localmente
    await local.updateExpense(model);

    // Sincronizar con Firestore si hay usuario autenticado
    final user = authRepository.getCurrentUser();
    if (user != null) {
      await remote.updateExpense(user.id, model);
    }
  }

  @override
  Future<List<Expense>> getExpensesByDateRange({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final models = await local.getAllExpenses();
    final filtered = models.where((model) {
      return model.date.isAfter(startDate.subtract(const Duration(seconds: 1))) &&
          model.date.isBefore(endDate.add(const Duration(seconds: 1)));
    }).toList();
    return filtered.map((m) => m.toEntity()).toList();
  }
}

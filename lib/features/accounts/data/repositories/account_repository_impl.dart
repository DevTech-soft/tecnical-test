import '../../../auth/domain/repositories/auth_repository.dart';
import '../../domain/entities/account.dart';
import '../../domain/repositories/account_repository.dart';
import '../datasources/account_local_datasource.dart';
import '../datasources/account_remote_datasource.dart';
import '../models/account_model.dart';

class AccountRepositoryImpl implements AccountRepository {
  final AccountLocalDataSource local;
  final AccountRemoteDataSource remote;
  final AuthRepository authRepository;

  AccountRepositoryImpl({
    required this.local,
    required this.remote,
    required this.authRepository,
  });

  @override
  Future<void> createAccount(Account account) async {
    final model = AccountModel.fromEntity(account);

    // Guardar localmente
    await local.addAccount(model);

    // Sincronizar con Firestore si hay usuario autenticado
    final user = authRepository.getCurrentUser();
    if (user != null) {
      await remote.addAccount(user.id, model);
    }
  }

  @override
  Future<List<Account>> getAllAccounts() async {
    final user = authRepository.getCurrentUser();

    if (user != null) {
      try {
        // Obtener desde Firestore y sincronizar con local
        final remoteModels = await remote.getAllAccounts(user.id);

        // Actualizar cache local (eliminar todo y volver a agregar)
        final localModels = await local.getAllAccounts();
        for (final localModel in localModels) {
          await local.deleteAccount(localModel.id);
        }
        for (final remoteModel in remoteModels) {
          await local.addAccount(remoteModel);
        }

        return remoteModels.map((m) => m.toEntity()).toList();
      } catch (e) {
        // Si falla Firestore, usar datos locales
        final models = await local.getAllAccounts();
        return models.map((m) => m.toEntity()).toList();
      }
    } else {
      // Sin usuario autenticado, usar solo datos locales
      final models = await local.getAllAccounts();
      return models.map((m) => m.toEntity()).toList();
    }
  }

  @override
  Future<Account?> getAccountById(String id) async {
    final model = await local.getAccountById(id);
    return model?.toEntity();
  }

  @override
  Future<void> updateAccount(Account account) async {
    final model = AccountModel.fromEntity(account);

    // Actualizar localmente
    await local.updateAccount(model);

    // Sincronizar con Firestore si hay usuario autenticado
    final user = authRepository.getCurrentUser();
    if (user != null) {
      await remote.updateAccount(user.id, model);
    }
  }

  @override
  Future<void> deleteAccount(String id) async {
    // Eliminar localmente
    await local.deleteAccount(id);

    // Sincronizar con Firestore si hay usuario autenticado
    final user = authRepository.getCurrentUser();
    if (user != null) {
      await remote.deleteAccount(user.id, id);
    }
  }

  @override
  Stream<List<Account>> watchAccounts() {
    final user = authRepository.getCurrentUser();

    if (user != null) {
      return remote.watchAccounts(user.id).map(
            (models) => models.map((m) => m.toEntity()).toList(),
          );
    } else {
      // Si no hay usuario, retornar stream vacío
      return Stream.value([]);
    }
  }
}

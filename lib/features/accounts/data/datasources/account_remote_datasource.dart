import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/account_model.dart';

abstract class AccountRemoteDataSource {
  /// Obtener todas las cuentas del usuario desde Firestore
  Future<List<AccountModel>> getAllAccounts(String userId);

  /// Agregar una cuenta a Firestore
  Future<void> addAccount(String userId, AccountModel account);

  /// Actualizar una cuenta en Firestore
  Future<void> updateAccount(String userId, AccountModel account);

  /// Eliminar una cuenta de Firestore
  Future<void> deleteAccount(String userId, String accountId);

  /// Stream de cuentas en tiempo real
  Stream<List<AccountModel>> watchAccounts(String userId);
}

class AccountRemoteDataSourceImpl implements AccountRemoteDataSource {
  final FirebaseFirestore _firestore;

  AccountRemoteDataSourceImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference _getUserAccountsCollection(String userId) {
    return _firestore.collection('users').doc(userId).collection('accounts');
  }

  @override
  Future<List<AccountModel>> getAllAccounts(String userId) async {
    try {
      final snapshot = await _getUserAccountsCollection(userId).get();

      return snapshot.docs
          .map((doc) =>
              AccountModel.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw ServerException(
        message: 'Error al obtener cuentas de Firestore: ${e.toString()}',
        code: 'FIRESTORE_GET_ERROR',
      );
    }
  }

  @override
  Future<void> addAccount(String userId, AccountModel account) async {
    try {
      await _getUserAccountsCollection(userId).doc(account.id).set(
            account.toJson(),
          );
    } catch (e) {
      throw ServerException(
        message: 'Error al agregar cuenta en Firestore: ${e.toString()}',
        code: 'FIRESTORE_ADD_ERROR',
      );
    }
  }

  @override
  Future<void> updateAccount(String userId, AccountModel account) async {
    try {
      await _getUserAccountsCollection(userId).doc(account.id).update(
            account.toJson(),
          );
    } catch (e) {
      throw ServerException(
        message: 'Error al actualizar cuenta en Firestore: ${e.toString()}',
        code: 'FIRESTORE_UPDATE_ERROR',
      );
    }
  }

  @override
  Future<void> deleteAccount(String userId, String accountId) async {
    try {
      await _getUserAccountsCollection(userId).doc(accountId).delete();
    } catch (e) {
      throw ServerException(
        message: 'Error al eliminar cuenta de Firestore: ${e.toString()}',
        code: 'FIRESTORE_DELETE_ERROR',
      );
    }
  }

  @override
  Stream<List<AccountModel>> watchAccounts(String userId) {
    try {
      return _getUserAccountsCollection(userId).snapshots().map((snapshot) {
        return snapshot.docs
            .map((doc) =>
                AccountModel.fromJson(doc.data() as Map<String, dynamic>))
            .toList();
      });
    } catch (e) {
      throw ServerException(
        message: 'Error al escuchar cambios de Firestore: ${e.toString()}',
        code: 'FIRESTORE_STREAM_ERROR',
      );
    }
  }
}

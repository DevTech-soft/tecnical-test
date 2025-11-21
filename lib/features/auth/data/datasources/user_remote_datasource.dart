import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/user_model.dart';

abstract class UserRemoteDataSource {
  /// Guardar o actualizar usuario en Firestore
  Future<void> saveUser(UserModel user);

  /// Obtener usuario de Firestore
  Future<UserModel?> getUser(String userId);

  /// Eliminar usuario de Firestore
  Future<void> deleteUser(String userId);
}

class UserRemoteDataSourceImpl implements UserRemoteDataSource {
  final FirebaseFirestore _firestore;

  UserRemoteDataSourceImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<void> saveUser(UserModel user) async {
    try {
      await _firestore.collection('users').doc(user.id).set(
            user.toJson(),
            SetOptions(merge: true), // Merge para no sobrescribir campos
          );
    } catch (e) {
      throw ServerException(
        message: 'Error al guardar usuario en Firestore: ${e.toString()}',
        code: 'FIRESTORE_SAVE_ERROR',
      );
    }
  }

  @override
  Future<UserModel?> getUser(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();

      if (!doc.exists || doc.data() == null) {
        return null;
      }

      return UserModel.fromJson(doc.data()!);
    } catch (e) {
      throw ServerException(
        message: 'Error al obtener usuario de Firestore: ${e.toString()}',
        code: 'FIRESTORE_GET_ERROR',
      );
    }
  }

  @override
  Future<void> deleteUser(String userId) async {
    try {
      await _firestore.collection('users').doc(userId).delete();
    } catch (e) {
      throw ServerException(
        message: 'Error al eliminar usuario de Firestore: ${e.toString()}',
        code: 'FIRESTORE_DELETE_ERROR',
      );
    }
  }
}

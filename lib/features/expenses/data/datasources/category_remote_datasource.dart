import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/category_model.dart';

abstract class CategoryRemoteDataSource {
  /// Obtener todas las categorías del usuario desde Firestore
  Future<List<CategoryModel>> getAllCategories(String userId);

  /// Crear una categoría en Firestore
  Future<void> createCategory(String userId, CategoryModel category);

  /// Actualizar una categoría en Firestore
  Future<void> updateCategory(String userId, CategoryModel category);

  /// Eliminar una categoría de Firestore
  Future<void> deleteCategory(String userId, String categoryId);
}

class CategoryRemoteDataSourceImpl implements CategoryRemoteDataSource {
  final FirebaseFirestore _firestore;

  CategoryRemoteDataSourceImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference _getUserCategoriesCollection(String userId) {
    return _firestore.collection('users').doc(userId).collection('categories');
  }

  @override
  Future<List<CategoryModel>> getAllCategories(String userId) async {
    try {
      final snapshot = await _getUserCategoriesCollection(userId).get();

      return snapshot.docs
          .map((doc) => CategoryModel.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw ServerException(
        message: 'Error al obtener categorías de Firestore: ${e.toString()}',
        code: 'FIRESTORE_GET_ERROR',
      );
    }
  }

  @override
  Future<void> createCategory(String userId, CategoryModel category) async {
    try {
      await _getUserCategoriesCollection(userId).doc(category.id).set(
            category.toJson(),
          );
    } catch (e) {
      throw ServerException(
        message: 'Error al crear categoría en Firestore: ${e.toString()}',
        code: 'FIRESTORE_ADD_ERROR',
      );
    }
  }

  @override
  Future<void> updateCategory(String userId, CategoryModel category) async {
    try {
      await _getUserCategoriesCollection(userId).doc(category.id).update(
            category.toJson(),
          );
    } catch (e) {
      throw ServerException(
        message: 'Error al actualizar categoría en Firestore: ${e.toString()}',
        code: 'FIRESTORE_UPDATE_ERROR',
      );
    }
  }

  @override
  Future<void> deleteCategory(String userId, String categoryId) async {
    try {
      await _getUserCategoriesCollection(userId).doc(categoryId).delete();
    } catch (e) {
      throw ServerException(
        message: 'Error al eliminar categoría de Firestore: ${e.toString()}',
        code: 'FIRESTORE_DELETE_ERROR',
      );
    }
  }
}

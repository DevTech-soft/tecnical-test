import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/budget_model.dart';

abstract class BudgetRemoteDataSource {
  Future<List<BudgetModel>> getAllBudgets(String userId);

  Future<BudgetModel?> getCurrentBudget(String userId);

  Future<void> createBudget(String userId, BudgetModel budget);

  Future<void> updateBudget(String userId, BudgetModel budget);

  Future<void> deleteBudget(String userId, String budgetId);
}

class BudgetRemoteDataSourceImpl implements BudgetRemoteDataSource {
  final FirebaseFirestore _firestore;

  BudgetRemoteDataSourceImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference _getUserBudgetsCollection(String userId) {
    return _firestore.collection('users').doc(userId).collection('budgets');
  }

  @override
  Future<List<BudgetModel>> getAllBudgets(String userId) async {
    try {
      final snapshot = await _getUserBudgetsCollection(userId).get();

      return snapshot.docs
          .map((doc) => BudgetModel.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw ServerException(
        message: 'Error al obtener presupuestos de Firestore: ${e.toString()}',
        code: 'FIRESTORE_GET_ERROR',
      );
    }
  }

  @override
  Future<BudgetModel?> getCurrentBudget(String userId) async {
    try {
      final now = DateTime.now();
      final snapshot = await _getUserBudgetsCollection(userId)
          .where('startDate', isLessThanOrEqualTo: now.toIso8601String())
          .where('endDate', isGreaterThanOrEqualTo: now.toIso8601String())
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        return null;
      }

      return BudgetModel.fromJson(snapshot.docs.first.data() as Map<String, dynamic>);
    } catch (e) {
      throw ServerException(
        message: 'Error al obtener presupuesto actual de Firestore: ${e.toString()}',
        code: 'FIRESTORE_GET_ERROR',
      );
    }
  }

  @override
  Future<void> createBudget(String userId, BudgetModel budget) async {
    try {
      await _getUserBudgetsCollection(userId).doc(budget.id).set(
            budget.toJson(),
          );
    } catch (e) {
      throw ServerException(
        message: 'Error al crear presupuesto en Firestore: ${e.toString()}',
        code: 'FIRESTORE_ADD_ERROR',
      );
    }
  }

  @override
  Future<void> updateBudget(String userId, BudgetModel budget) async {
    try {
      await _getUserBudgetsCollection(userId).doc(budget.id).update(
            budget.toJson(),
          );
    } catch (e) {
      throw ServerException(
        message: 'Error al actualizar presupuesto en Firestore: ${e.toString()}',
        code: 'FIRESTORE_UPDATE_ERROR',
      );
    }
  }

  @override
  Future<void> deleteBudget(String userId, String budgetId) async {
    try {
      await _getUserBudgetsCollection(userId).doc(budgetId).delete();
    } catch (e) {
      throw ServerException(
        message: 'Error al eliminar presupuesto de Firestore: ${e.toString()}',
        code: 'FIRESTORE_DELETE_ERROR',
      );
    }
  }
}

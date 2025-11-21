import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/expense_model.dart';

abstract class ExpenseRemoteDataSource {
  /// Obtener todos los gastos del usuario desde Firestore
  Future<List<ExpenseModel>> getAllExpenses(String userId);

  /// Agregar un gasto a Firestore
  Future<void> addExpense(String userId, ExpenseModel expense);

  /// Actualizar un gasto en Firestore
  Future<void> updateExpense(String userId, ExpenseModel expense);

  /// Eliminar un gasto de Firestore
  Future<void> deleteExpense(String userId, String expenseId);

  /// Stream de gastos en tiempo real
  Stream<List<ExpenseModel>> watchExpenses(String userId);
}

class ExpenseRemoteDataSourceImpl implements ExpenseRemoteDataSource {
  final FirebaseFirestore _firestore;

  ExpenseRemoteDataSourceImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference _getUserExpensesCollection(String userId) {
    return _firestore.collection('users').doc(userId).collection('expenses');
  }

  @override
  Future<List<ExpenseModel>> getAllExpenses(String userId) async {
    try {
      final snapshot = await _getUserExpensesCollection(userId).get();

      return snapshot.docs
          .map((doc) => ExpenseModel.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw ServerException(
        message: 'Error al obtener gastos de Firestore: ${e.toString()}',
        code: 'FIRESTORE_GET_ERROR',
      );
    }
  }

  @override
  Future<void> addExpense(String userId, ExpenseModel expense) async {
    try {
      await _getUserExpensesCollection(userId).doc(expense.id).set(
            expense.toJson(),
          );
    } catch (e) {
      throw ServerException(
        message: 'Error al agregar gasto en Firestore: ${e.toString()}',
        code: 'FIRESTORE_ADD_ERROR',
      );
    }
  }

  @override
  Future<void> updateExpense(String userId, ExpenseModel expense) async {
    try {
      await _getUserExpensesCollection(userId).doc(expense.id).update(
            expense.toJson(),
          );
    } catch (e) {
      throw ServerException(
        message: 'Error al actualizar gasto en Firestore: ${e.toString()}',
        code: 'FIRESTORE_UPDATE_ERROR',
      );
    }
  }

  @override
  Future<void> deleteExpense(String userId, String expenseId) async {
    try {
      await _getUserExpensesCollection(userId).doc(expenseId).delete();
    } catch (e) {
      throw ServerException(
        message: 'Error al eliminar gasto de Firestore: ${e.toString()}',
        code: 'FIRESTORE_DELETE_ERROR',
      );
    }
  }

  @override
  Stream<List<ExpenseModel>> watchExpenses(String userId) {
    try {
      return _getUserExpensesCollection(userId)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs
            .map((doc) => ExpenseModel.fromJson(doc.data() as Map<String, dynamic>))
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

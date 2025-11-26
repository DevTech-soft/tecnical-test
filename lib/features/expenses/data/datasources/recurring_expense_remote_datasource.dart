import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/recurring_expense_model.dart';

abstract class RecurringExpenseRemoteDataSource {
  /// Obtener todos los gastos recurrentes del usuario desde Firestore
  Future<List<RecurringExpenseModel>> getAllRecurringExpenses(String userId);

  /// Crear un gasto recurrente en Firestore
  Future<void> createRecurringExpense(String userId, RecurringExpenseModel expense);

  /// Actualizar un gasto recurrente en Firestore
  Future<void> updateRecurringExpense(String userId, RecurringExpenseModel expense);

  /// Eliminar un gasto recurrente de Firestore
  Future<void> deleteRecurringExpense(String userId, String expenseId);
}

class RecurringExpenseRemoteDataSourceImpl implements RecurringExpenseRemoteDataSource {
  final FirebaseFirestore _firestore;

  RecurringExpenseRemoteDataSourceImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference _getUserRecurringExpensesCollection(String userId) {
    return _firestore.collection('users').doc(userId).collection('recurring_expenses');
  }

  @override
  Future<List<RecurringExpenseModel>> getAllRecurringExpenses(String userId) async {
    try {
      final snapshot = await _getUserRecurringExpensesCollection(userId).get();

      return snapshot.docs
          .map((doc) => RecurringExpenseModel.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw ServerException(
        message: 'Error al obtener gastos recurrentes de Firestore: ${e.toString()}',
        code: 'FIRESTORE_GET_ERROR',
      );
    }
  }

  @override
  Future<void> createRecurringExpense(String userId, RecurringExpenseModel expense) async {
    try {
      await _getUserRecurringExpensesCollection(userId).doc(expense.id).set(
            expense.toJson(),
          );
    } catch (e) {
      throw ServerException(
        message: 'Error al crear gasto recurrente en Firestore: ${e.toString()}',
        code: 'FIRESTORE_ADD_ERROR',
      );
    }
  }

  @override
  Future<void> updateRecurringExpense(String userId, RecurringExpenseModel expense) async {
    try {
      await _getUserRecurringExpensesCollection(userId).doc(expense.id).update(
            expense.toJson(),
          );
    } catch (e) {
      throw ServerException(
        message: 'Error al actualizar gasto recurrente en Firestore: ${e.toString()}',
        code: 'FIRESTORE_UPDATE_ERROR',
      );
    }
  }

  @override
  Future<void> deleteRecurringExpense(String userId, String expenseId) async {
    try {
      await _getUserRecurringExpensesCollection(userId).doc(expenseId).delete();
    } catch (e) {
      throw ServerException(
        message: 'Error al eliminar gasto recurrente de Firestore: ${e.toString()}',
        code: 'FIRESTORE_DELETE_ERROR',
      );
    }
  }
}

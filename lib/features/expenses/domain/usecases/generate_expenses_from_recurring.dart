import 'package:uuid/uuid.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/app_logger.dart';
import '../entities/expense.dart';
import '../entities/recurring_expense.dart';
import '../repositories/recurring_expense_repository.dart';
import 'add_expense_with_account_update.dart';

/// Use case para generar gastos reales desde gastos recurrentes
///
/// Esta clase contiene la LÓGICA DE NEGOCIO para:
/// 1. Obtener gastos recurrentes que deben generar un gasto
/// 2. Crear el gasto real
/// 3. Actualizar la fecha de última generación en el recurrente
/// 4. Actualizar el balance de la cuenta asociada
///
/// Este use case debe ser llamado periódicamente
/// (por ejemplo, al abrir la app o mediante un servicio en background)
class GenerateExpensesFromRecurring implements UseCase<int, NoParams> {
  final RecurringExpenseRepository recurringRepository;
  final AddExpenseWithAccountUpdate addExpenseWithAccountUpdate;
  final _logger = AppLogger('GenerateExpensesFromRecurring');
  final _uuid = const Uuid();

  GenerateExpensesFromRecurring({
    required this.recurringRepository,
    required this.addExpenseWithAccountUpdate,
  });

  /// Retorna el número de gastos generados
  @override
  Future<int> call(NoParams params) async {
    try {
      _logger.info('Iniciando generación de gastos desde recurrentes');

      // 1. Obtener gastos recurrentes que deben generar un gasto
      final dueRecurringExpenses =
          await recurringRepository.getRecurringExpensesDueForGeneration();

      _logger.info('Gastos recurrentes por generar: ${dueRecurringExpenses.length}');

      if (dueRecurringExpenses.isEmpty) {
        return 0;
      }

      int generatedCount = 0;

      // 2. Para cada gasto recurrente, generar el gasto real
      for (final recurring in dueRecurringExpenses) {
        try {
          // Crear el gasto real y actualizar la cuenta
          final expense = _createExpenseFromRecurring(recurring);
          await addExpenseWithAccountUpdate(expense);

          // Actualizar la fecha de última generación
          final updatedRecurring = recurring.copyWith(
            lastGenerated: DateTime.now(),
            updatedAt: DateTime.now(),
          );
          await recurringRepository.updateRecurringExpense(updatedRecurring);

          generatedCount++;
          _logger.info('Gasto generado desde recurrente: ${recurring.id}');
        } catch (e, stackTrace) {
          _logger.error(
            'Error generando gasto desde recurrente ${recurring.id}',
            e,
            stackTrace,
          );
          // Continuar con los demás gastos recurrentes
        }
      }

      _logger.info('Generación completada: $generatedCount gastos creados');
      return generatedCount;
    } catch (e, stackTrace) {
      _logger.error('Error en generación automática de gastos', e, stackTrace);
      rethrow;
    }
  }

  /// Crea un Expense desde un RecurringExpense
  Expense _createExpenseFromRecurring(RecurringExpense recurring) {
    return Expense(
      id: _uuid.v4(),
      amount: recurring.amount,
      categoryId: recurring.categoryId,
      accountId: recurring.accountId,
      note: recurring.note,
      date: DateTime.now(),
    );
  }
}

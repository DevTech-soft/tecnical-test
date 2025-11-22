import 'package:equatable/equatable.dart';
import '../../domain/entities/recurring_expense.dart';

abstract class RecurringExpensesEvent extends Equatable {
  const RecurringExpensesEvent();

  @override
  List<Object?> get props => [];
}

/// Evento para cargar todos los gastos recurrentes
class LoadRecurringExpensesEvent extends RecurringExpensesEvent {
  const LoadRecurringExpensesEvent();
}

/// Evento para crear un nuevo gasto recurrente
class CreateRecurringExpenseEvent extends RecurringExpensesEvent {
  final RecurringExpense recurringExpense;

  const CreateRecurringExpenseEvent(this.recurringExpense);

  @override
  List<Object?> get props => [recurringExpense];
}

/// Evento para actualizar un gasto recurrente
class UpdateRecurringExpenseEvent extends RecurringExpensesEvent {
  final RecurringExpense recurringExpense;

  const UpdateRecurringExpenseEvent(this.recurringExpense);

  @override
  List<Object?> get props => [recurringExpense];
}

/// Evento para eliminar un gasto recurrente
class DeleteRecurringExpenseEvent extends RecurringExpensesEvent {
  final String id;

  const DeleteRecurringExpenseEvent(this.id);

  @override
  List<Object?> get props => [id];
}

/// Evento para pausar un gasto recurrente (cambiar isActive a false)
class PauseRecurringExpenseEvent extends RecurringExpensesEvent {
  final RecurringExpense recurringExpense;

  const PauseRecurringExpenseEvent(this.recurringExpense);

  @override
  List<Object?> get props => [recurringExpense];
}

/// Evento para reanudar un gasto recurrente (cambiar isActive a true)
class ResumeRecurringExpenseEvent extends RecurringExpensesEvent {
  final RecurringExpense recurringExpense;

  const ResumeRecurringExpenseEvent(this.recurringExpense);

  @override
  List<Object?> get props => [recurringExpense];
}

/// Evento para generar gastos desde recurrencias
class GenerateExpensesEvent extends RecurringExpensesEvent {
  const GenerateExpensesEvent();
}

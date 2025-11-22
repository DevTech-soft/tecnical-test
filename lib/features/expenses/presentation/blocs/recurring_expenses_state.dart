import 'package:equatable/equatable.dart';
import '../../domain/entities/recurring_expense.dart';

abstract class RecurringExpensesState extends Equatable {
  const RecurringExpensesState();

  @override
  List<Object?> get props => [];
}

/// Estado inicial
class RecurringExpensesInitial extends RecurringExpensesState {
  const RecurringExpensesInitial();
}

/// Estado de carga
class RecurringExpensesLoading extends RecurringExpensesState {
  const RecurringExpensesLoading();
}

/// Estado con datos cargados
class RecurringExpensesLoaded extends RecurringExpensesState {
  final List<RecurringExpense> recurringExpenses;

  const RecurringExpensesLoaded(this.recurringExpenses);

  @override
  List<Object?> get props => [recurringExpenses];
}

/// Estado de error
class RecurringExpensesError extends RecurringExpensesState {
  final String message;

  const RecurringExpensesError(this.message);

  @override
  List<Object?> get props => [message];
}

/// Estado cuando se genera gastos exitosamente
class ExpensesGenerated extends RecurringExpensesState {
  final int count;
  final List<RecurringExpense> recurringExpenses;

  const ExpensesGenerated({
    required this.count,
    required this.recurringExpenses,
  });

  @override
  List<Object?> get props => [count, recurringExpenses];
}

/// Estado cuando se crea/actualiza/elimina con éxito
class RecurringExpenseOperationSuccess extends RecurringExpensesState {
  final String message;
  final List<RecurringExpense> recurringExpenses;

  const RecurringExpenseOperationSuccess({
    required this.message,
    required this.recurringExpenses,
  });

  @override
  List<Object?> get props => [message, recurringExpenses];
}

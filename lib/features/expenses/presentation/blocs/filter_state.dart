import 'package:equatable/equatable.dart';
import '../../domain/entities/expense.dart';
import '../../domain/entities/expense_filter.dart';

abstract class FilterState extends Equatable {
  const FilterState();

  @override
  List<Object?> get props => [];
}

/// Estado inicial
class FilterInitial extends FilterState {
  const FilterInitial();
}

/// Estado de carga
class FilterLoading extends FilterState {
  const FilterLoading();
}

/// Estado con resultados de búsqueda
class FilterSuccess extends FilterState {
  final List<Expense> expenses;
  final ExpenseFilter currentFilter;

  const FilterSuccess({
    required this.expenses,
    required this.currentFilter,
  });

  @override
  List<Object?> get props => [expenses, currentFilter];
}

/// Estado de error
class FilterError extends FilterState {
  final String message;

  const FilterError(this.message);

  @override
  List<Object?> get props => [message];
}

import 'package:equatable/equatable.dart';

abstract class BudgetEvent extends Equatable {
  const BudgetEvent();

  @override
  List<Object?> get props => [];
}

/// Evento para cargar el presupuesto actual (mes y año actuales)
class LoadCurrentBudgetEvent extends BudgetEvent {
  final String? categoryId; // null = presupuesto general

  const LoadCurrentBudgetEvent({this.categoryId});

  @override
  List<Object?> get props => [categoryId];
}

/// Evento para cargar el presupuesto de un período específico
class LoadBudgetByPeriodEvent extends BudgetEvent {
  final int month;
  final int year;
  final String? categoryId;

  const LoadBudgetByPeriodEvent({
    required this.month,
    required this.year,
    this.categoryId,
  });

  @override
  List<Object?> get props => [month, year, categoryId];
}

/// Evento para crear un nuevo presupuesto
class CreateBudgetEvent extends BudgetEvent {
  final double amount;
  final int month;
  final int year;
  final String? categoryId;

  const CreateBudgetEvent({
    required this.amount,
    required this.month,
    required this.year,
    this.categoryId,
  });

  @override
  List<Object?> get props => [amount, month, year, categoryId];
}

/// Evento para actualizar un presupuesto existente
class UpdateBudgetEvent extends BudgetEvent {
  final String budgetId;
  final double? amount;
  final int? month;
  final int? year;

  const UpdateBudgetEvent({
    required this.budgetId,
    this.amount,
    this.month,
    this.year,
  });

  @override
  List<Object?> get props => [budgetId, amount, month, year];
}

/// Evento para eliminar un presupuesto
class DeleteBudgetEvent extends BudgetEvent {
  final String budgetId;

  const DeleteBudgetEvent({required this.budgetId});

  @override
  List<Object?> get props => [budgetId];
}

/// Evento para calcular el estado/progreso del presupuesto
class CalculateBudgetStatusEvent extends BudgetEvent {
  const CalculateBudgetStatusEvent();
}

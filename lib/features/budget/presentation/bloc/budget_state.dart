import 'package:equatable/equatable.dart';
import '../../../../core/errors/error_handler.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/budget.dart';
import '../../domain/entities/budget_status.dart';

abstract class BudgetState extends Equatable {
  const BudgetState();

  @override
  List<Object?> get props => [];
}

/// Estado inicial
class BudgetInitial extends BudgetState {
  const BudgetInitial();
}

/// Estado de carga
class BudgetLoading extends BudgetState {
  const BudgetLoading();
}

/// Estado cuando el presupuesto fue cargado exitosamente
class BudgetLoaded extends BudgetState {
  final Budget? budget; // null si no existe presupuesto para el período
  final BudgetStatus? status; // null si no existe presupuesto

  const BudgetLoaded({
    this.budget,
    this.status,
  });

  /// Retorna true si existe un presupuesto activo
  bool get hasBudget => budget != null;

  @override
  List<Object?> get props => [budget, status];
}

/// Estado cuando se crea/actualiza un presupuesto exitosamente
class BudgetOperationSuccess extends BudgetState {
  final Budget budget;
  final String message;

  const BudgetOperationSuccess({
    required this.budget,
    required this.message,
  });

  @override
  List<Object?> get props => [budget, message];
}

/// Estado cuando se elimina un presupuesto exitosamente
class BudgetDeleted extends BudgetState {
  final String message;

  const BudgetDeleted({required this.message});

  @override
  List<Object?> get props => [message];
}

/// Estado de error
class BudgetError extends BudgetState {
  final Failure failure;

  const BudgetError({required this.failure});

  /// Mensaje amigable para el usuario
  String get userMessage => ErrorHandler.getUserFriendlyMessage(failure);

  /// Título del error
  String get title => ErrorHandler.getErrorTitle(failure);

  /// Indica si el error es recuperable
  bool get isRecoverable => ErrorHandler.isRecoverable(failure);

  @override
  List<Object?> get props => [failure];
}

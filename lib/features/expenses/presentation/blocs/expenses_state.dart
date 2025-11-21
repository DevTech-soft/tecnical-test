part of 'expenses_bloc.dart';

abstract class ExpensesState extends Equatable {
  const ExpensesState();

  @override
  List<Object?> get props => [];
}

class ExpensesInitial extends ExpensesState {
  const ExpensesInitial();
}

class ExpensesLoading extends ExpensesState {
  const ExpensesLoading();
}

class ExpensesLoaded extends ExpensesState {
  final List<Expense> expenses;

  const ExpensesLoaded(this.expenses);

  @override
  List<Object?> get props => [expenses];
}

class ExpensesError extends ExpensesState {
  final Failure failure;

  const ExpensesError(this.failure);

  /// Mensaje amigable para el usuario
  String get userMessage => ErrorHandler.getUserFriendlyMessage(failure);

  /// Título del error
  String get title => ErrorHandler.getErrorTitle(failure);

  /// Indica si el error es recuperable
  bool get isRecoverable => ErrorHandler.isRecoverable(failure);

  @override
  List<Object?> get props => [failure];
}
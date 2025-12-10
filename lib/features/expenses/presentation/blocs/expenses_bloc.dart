import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/error_handler.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/expense.dart';
import '../../domain/usecases/get_all_expenses.dart';
import '../../domain/usecases/add_expense_with_account_update.dart';
import '../../domain/usecases/delete_expense_with_account_update.dart';
import '../../domain/usecases/update_expense_with_account_update.dart';

part 'expenses_event.dart';
part 'expenses_state.dart';

class ExpensesBloc extends Bloc<ExpensesEvent, ExpensesState> {
  final GetAllExpenses getAll;
  final AddExpenseWithAccountUpdate addExpense;
  final DeleteExpenseWithAccountUpdate deleteExpense;
  final UpdateExpenseWithAccountUpdate updateExpense;

  ExpensesBloc({
    required this.getAll,
    required this.addExpense,
    required this.deleteExpense,
    required this.updateExpense,
  }) : super(const ExpensesInitial()) {
    on<LoadExpensesEvent>(_onLoadExpenses);
    on<AddExpenseEvent>(_onAddExpense);
    on<DeleteExpenseEvent>(_onDeleteExpense);
    on<UpdateExpenseEvent>(_onUpdateExpense);
  }

  Future<void> _onLoadExpenses(
    LoadExpensesEvent event,
    Emitter<ExpensesState> emit,
  ) async {
    try {
      emit(const ExpensesLoading());
      final list = await getAll();
      emit(ExpensesLoaded(list));
    } catch (error) {
      final failure = ErrorHandler.handleException(error);
      emit(ExpensesError(failure));
    }
  }

  Future<void> _onAddExpense(
    AddExpenseEvent event,
    Emitter<ExpensesState> emit,
  ) async {
    try {
      await addExpense(event.expense);
      final list = await getAll();
      emit(ExpensesLoaded(list));
    } catch (error) {
      final failure = ErrorHandler.handleException(error);
      emit(ExpensesError(failure));
    }
  }

  Future<void> _onDeleteExpense(
    DeleteExpenseEvent event,
    Emitter<ExpensesState> emit,
  ) async {
    try {
      await deleteExpense(event.id);
      final list = await getAll();
      emit(ExpensesLoaded(list));
    } catch (error) {
      final failure = ErrorHandler.handleException(error);
      emit(ExpensesError(failure));
    }
  }

  Future<void> _onUpdateExpense(
    UpdateExpenseEvent event,
    Emitter<ExpensesState> emit,
  ) async {
    try {
      await updateExpense(event.expense);
      final list = await getAll();
      emit(ExpensesLoaded(list));
    } catch (error) {
      final failure = ErrorHandler.handleException(error);
      emit(ExpensesError(failure));
    }
  }
}

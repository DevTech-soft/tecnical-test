import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/errors/error_handler.dart';
import '../../domain/usecases/calculate_budget_status.dart';
import '../../domain/usecases/create_budget.dart';
import '../../domain/usecases/delete_budget.dart';
import '../../domain/usecases/get_current_budget.dart';
import '../../domain/usecases/update_budget.dart';
import 'budget_event.dart';
import 'budget_state.dart';

class BudgetBloc extends Bloc<BudgetEvent, BudgetState> {
  final CreateBudget createBudgetUseCase;
  final GetCurrentBudget getCurrentBudgetUseCase;
  final UpdateBudget updateBudgetUseCase;
  final DeleteBudget deleteBudgetUseCase;
  final CalculateBudgetStatus calculateBudgetStatusUseCase;

  BudgetBloc({
    required this.createBudgetUseCase,
    required this.getCurrentBudgetUseCase,
    required this.updateBudgetUseCase,
    required this.deleteBudgetUseCase,
    required this.calculateBudgetStatusUseCase,
  }) : super(const BudgetInitial()) {
    on<LoadCurrentBudgetEvent>(_onLoadCurrentBudget);
    on<LoadBudgetByPeriodEvent>(_onLoadBudgetByPeriod);
    on<CreateBudgetEvent>(_onCreateBudget);
    on<UpdateBudgetEvent>(_onUpdateBudget);
    on<DeleteBudgetEvent>(_onDeleteBudget);
    on<CalculateBudgetStatusEvent>(_onCalculateBudgetStatus);
  }

  Future<void> _onLoadCurrentBudget(
    LoadCurrentBudgetEvent event,
    Emitter<BudgetState> emit,
  ) async {
    try {
      emit(const BudgetLoading());

      final budget = await getCurrentBudgetUseCase(
        GetCurrentBudgetParams(categoryId: event.categoryId),
      );

      if (budget == null) {
        emit(const BudgetLoaded(budget: null, status: null));
        return;
      }

      // Calcular el estado del presupuesto
      final status = await calculateBudgetStatusUseCase(
        CalculateBudgetStatusParams(budget: budget),
      );

      emit(BudgetLoaded(budget: budget, status: status));
    } catch (error) {
      final failure = ErrorHandler.handleException(error);
      emit(BudgetError(failure: failure));
    }
  }

  Future<void> _onLoadBudgetByPeriod(
    LoadBudgetByPeriodEvent event,
    Emitter<BudgetState> emit,
  ) async {
    try {
      emit(const BudgetLoading());

      final budget = await getCurrentBudgetUseCase(
        GetCurrentBudgetParams(
          categoryId: event.categoryId,
          month: event.month,
          year: event.year,
        ),
      );

      if (budget == null) {
        emit(const BudgetLoaded(budget: null, status: null));
        return;
      }

      // Calcular el estado del presupuesto
      final status = await calculateBudgetStatusUseCase(
        CalculateBudgetStatusParams(budget: budget),
      );

      emit(BudgetLoaded(budget: budget, status: status));
    } catch (error) {
      final failure = ErrorHandler.handleException(error);
      emit(BudgetError(failure: failure));
    }
  }

  Future<void> _onCreateBudget(
    CreateBudgetEvent event,
    Emitter<BudgetState> emit,
  ) async {
    try {
      emit(const BudgetLoading());

      final budget = await createBudgetUseCase(
        CreateBudgetParams(
          id: const Uuid().v4(),
          amount: event.amount,
          month: event.month,
          year: event.year,
          categoryId: event.categoryId,
        ),
      );

      emit(BudgetOperationSuccess(
        budget: budget,
        message: 'Presupuesto creado exitosamente',
      ));

      // Recargar el presupuesto para mostrar el estado actualizado
      add(LoadCurrentBudgetEvent(categoryId: event.categoryId));
    } catch (error) {
      final failure = ErrorHandler.handleException(error);
      emit(BudgetError(failure: failure));
    }
  }

  Future<void> _onUpdateBudget(
    UpdateBudgetEvent event,
    Emitter<BudgetState> emit,
  ) async {
    try {
      emit(const BudgetLoading());

      final budget = await updateBudgetUseCase(
        UpdateBudgetParams(
          budgetId: event.budgetId,
          amount: event.amount,
          month: event.month,
          year: event.year,
        ),
      );

      emit(BudgetOperationSuccess(
        budget: budget,
        message: 'Presupuesto actualizado exitosamente',
      ));

      // Recargar el presupuesto para mostrar el estado actualizado
      add(LoadCurrentBudgetEvent(categoryId: budget.categoryId));
    } catch (error) {
      final failure = ErrorHandler.handleException(error);
      emit(BudgetError(failure: failure));
    }
  }

  Future<void> _onDeleteBudget(
    DeleteBudgetEvent event,
    Emitter<BudgetState> emit,
  ) async {
    try {
      emit(const BudgetLoading());

      await deleteBudgetUseCase(
        DeleteBudgetParams(budgetId: event.budgetId),
      );

      emit(const BudgetDeleted(message: 'Presupuesto eliminado exitosamente'));

      // Recargar para mostrar que no hay presupuesto
      add(const LoadCurrentBudgetEvent());
    } catch (error) {
      final failure = ErrorHandler.handleException(error);
      emit(BudgetError(failure: failure));
    }
  }

  Future<void> _onCalculateBudgetStatus(
    CalculateBudgetStatusEvent event,
    Emitter<BudgetState> emit,
  ) async {
    // Este evento se maneja automáticamente al cargar el presupuesto
    // Se puede usar para recalcular el estado si los gastos cambian
    if (state is BudgetLoaded) {
      final currentState = state as BudgetLoaded;
      if (currentState.budget != null) {
        try {
          final status = await calculateBudgetStatusUseCase(
            CalculateBudgetStatusParams(budget: currentState.budget!),
          );
          emit(BudgetLoaded(budget: currentState.budget, status: status));
        } catch (error) {
          final failure = ErrorHandler.handleException(error);
          emit(BudgetError(failure: failure));
        }
      }
    }
  }
}

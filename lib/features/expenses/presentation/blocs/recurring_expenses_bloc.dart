import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/app_logger.dart';
import '../../domain/usecases/create_recurring_expense.dart';
import '../../domain/usecases/delete_recurring_expense.dart';
import '../../domain/usecases/generate_expenses_from_recurring.dart';
import '../../domain/usecases/get_all_recurring_expenses.dart';
import '../../domain/usecases/update_recurring_expense.dart';
import 'recurring_expenses_event.dart';
import 'recurring_expenses_state.dart';

class RecurringExpensesBloc
    extends Bloc<RecurringExpensesEvent, RecurringExpensesState> {
  final GetAllRecurringExpenses getAllRecurringExpenses;
  final CreateRecurringExpense createRecurringExpense;
  final UpdateRecurringExpense updateRecurringExpense;
  final DeleteRecurringExpense deleteRecurringExpense;
  final GenerateExpensesFromRecurring generateExpensesFromRecurring;

  final _logger = AppLogger('RecurringExpensesBloc');

  RecurringExpensesBloc({
    required this.getAllRecurringExpenses,
    required this.createRecurringExpense,
    required this.updateRecurringExpense,
    required this.deleteRecurringExpense,
    required this.generateExpensesFromRecurring,
  }) : super(const RecurringExpensesInitial()) {
    on<LoadRecurringExpensesEvent>(_onLoadRecurringExpenses);
    on<CreateRecurringExpenseEvent>(_onCreateRecurringExpense);
    on<UpdateRecurringExpenseEvent>(_onUpdateRecurringExpense);
    on<DeleteRecurringExpenseEvent>(_onDeleteRecurringExpense);
    on<PauseRecurringExpenseEvent>(_onPauseRecurringExpense);
    on<ResumeRecurringExpenseEvent>(_onResumeRecurringExpense);
    on<GenerateExpensesEvent>(_onGenerateExpenses);
  }

  Future<void> _onLoadRecurringExpenses(
    LoadRecurringExpensesEvent event,
    Emitter<RecurringExpensesState> emit,
  ) async {
    try {
      emit(const RecurringExpensesLoading());
      _logger.info('Cargando gastos recurrentes');

      final recurringExpenses = await getAllRecurringExpenses(NoParams());

      emit(RecurringExpensesLoaded(recurringExpenses));
      _logger.info('Gastos recurrentes cargados: ${recurringExpenses.length}');
    } catch (e, stackTrace) {
      _logger.error('Error cargando gastos recurrentes', e, stackTrace);
      emit(RecurringExpensesError('Error al cargar gastos recurrentes'));
    }
  }

  Future<void> _onCreateRecurringExpense(
    CreateRecurringExpenseEvent event,
    Emitter<RecurringExpensesState> emit,
  ) async {
    try {
      emit(const RecurringExpensesLoading());
      _logger.info('Creando gasto recurrente: ${event.recurringExpense.id}');

      await createRecurringExpense(event.recurringExpense);

      // Recargar la lista
      final recurringExpenses = await getAllRecurringExpenses(NoParams());

      emit(RecurringExpenseOperationSuccess(
        message: 'Gasto recurrente creado exitosamente',
        recurringExpenses: recurringExpenses,
      ));
      _logger.info('Gasto recurrente creado exitosamente');
    } catch (e, stackTrace) {
      _logger.error('Error creando gasto recurrente', e, stackTrace);
      emit(const RecurringExpensesError('Error al crear gasto recurrente'));
    }
  }

  Future<void> _onUpdateRecurringExpense(
    UpdateRecurringExpenseEvent event,
    Emitter<RecurringExpensesState> emit,
  ) async {
    try {
      emit(const RecurringExpensesLoading());
      _logger.info('Actualizando gasto recurrente: ${event.recurringExpense.id}');

      await updateRecurringExpense(event.recurringExpense);

      // Recargar la lista
      final recurringExpenses = await getAllRecurringExpenses(NoParams());

      emit(RecurringExpenseOperationSuccess(
        message: 'Gasto recurrente actualizado exitosamente',
        recurringExpenses: recurringExpenses,
      ));
      _logger.info('Gasto recurrente actualizado exitosamente');
    } catch (e, stackTrace) {
      _logger.error('Error actualizando gasto recurrente', e, stackTrace);
      emit(const RecurringExpensesError('Error al actualizar gasto recurrente'));
    }
  }

  Future<void> _onDeleteRecurringExpense(
    DeleteRecurringExpenseEvent event,
    Emitter<RecurringExpensesState> emit,
  ) async {
    try {
      emit(const RecurringExpensesLoading());
      _logger.info('Eliminando gasto recurrente: ${event.id}');

      await deleteRecurringExpense(event.id);

      // Recargar la lista
      final recurringExpenses = await getAllRecurringExpenses(NoParams());

      emit(RecurringExpenseOperationSuccess(
        message: 'Gasto recurrente eliminado exitosamente',
        recurringExpenses: recurringExpenses,
      ));
      _logger.info('Gasto recurrente eliminado exitosamente');
    } catch (e, stackTrace) {
      _logger.error('Error eliminando gasto recurrente', e, stackTrace);
      emit(const RecurringExpensesError('Error al eliminar gasto recurrente'));
    }
  }

  Future<void> _onPauseRecurringExpense(
    PauseRecurringExpenseEvent event,
    Emitter<RecurringExpensesState> emit,
  ) async {
    try {
      emit(const RecurringExpensesLoading());
      _logger.info('Pausando gasto recurrente: ${event.recurringExpense.id}');

      final updated = event.recurringExpense.copyWith(
        isActive: false,
        updatedAt: DateTime.now(),
      );

      await updateRecurringExpense(updated);

      // Recargar la lista
      final recurringExpenses = await getAllRecurringExpenses(NoParams());

      emit(RecurringExpenseOperationSuccess(
        message: 'Gasto recurrente pausado',
        recurringExpenses: recurringExpenses,
      ));
      _logger.info('Gasto recurrente pausado');
    } catch (e, stackTrace) {
      _logger.error('Error pausando gasto recurrente', e, stackTrace);
      emit(const RecurringExpensesError('Error al pausar gasto recurrente'));
    }
  }

  Future<void> _onResumeRecurringExpense(
    ResumeRecurringExpenseEvent event,
    Emitter<RecurringExpensesState> emit,
  ) async {
    try {
      emit(const RecurringExpensesLoading());
      _logger.info('Reanudando gasto recurrente: ${event.recurringExpense.id}');

      final updated = event.recurringExpense.copyWith(
        isActive: true,
        updatedAt: DateTime.now(),
      );

      await updateRecurringExpense(updated);

      // Recargar la lista
      final recurringExpenses = await getAllRecurringExpenses(NoParams());

      emit(RecurringExpenseOperationSuccess(
        message: 'Gasto recurrente reanudado',
        recurringExpenses: recurringExpenses,
      ));
      _logger.info('Gasto recurrente reanudado');
    } catch (e, stackTrace) {
      _logger.error('Error reanudando gasto recurrente', e, stackTrace);
      emit(const RecurringExpensesError('Error al reanudar gasto recurrente'));
    }
  }

  Future<void> _onGenerateExpenses(
    GenerateExpensesEvent event,
    Emitter<RecurringExpensesState> emit,
  ) async {
    try {
      emit(const RecurringExpensesLoading());
      _logger.info('Generando gastos desde recurrencias');

      final count = await generateExpensesFromRecurring(NoParams());

      // Recargar la lista
      final recurringExpenses = await getAllRecurringExpenses(NoParams());

      emit(ExpensesGenerated(
        count: count,
        recurringExpenses: recurringExpenses,
      ));
      _logger.info('Gastos generados: $count');
    } catch (e, stackTrace) {
      _logger.error('Error generando gastos', e, stackTrace);
      emit(const RecurringExpensesError('Error al generar gastos'));
    }
  }
}

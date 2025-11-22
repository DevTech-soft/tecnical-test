import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/app_logger.dart';
import '../../domain/entities/expense_filter.dart';
import '../../domain/usecases/search_expenses.dart';
import 'filter_event.dart';
import 'filter_state.dart';

class FilterBloc extends Bloc<FilterEvent, FilterState> {
  final SearchExpenses searchExpenses;
  final _logger = AppLogger('FilterBloc');
  ExpenseFilter _currentFilter = const ExpenseFilter.empty();

  FilterBloc({required this.searchExpenses}) : super(const FilterInitial()) {
    on<SearchExpensesEvent>(_onSearchExpenses);
    on<UpdateSearchQueryEvent>(_onUpdateSearchQuery);
    on<UpdateCategoriesFilterEvent>(_onUpdateCategoriesFilter);
    on<UpdateDateRangeFilterEvent>(_onUpdateDateRangeFilter);
    on<UpdateAmountRangeFilterEvent>(_onUpdateAmountRangeFilter);
    on<UpdateSortOptionEvent>(_onUpdateSortOption);
    on<ClearAllFiltersEvent>(_onClearAllFilters);
    on<ClearSpecificFilterEvent>(_onClearSpecificFilter);
  }

  ExpenseFilter get currentFilter => _currentFilter;

  Future<void> _onSearchExpenses(
    SearchExpensesEvent event,
    Emitter<FilterState> emit,
  ) async {
    try {
      emit(const FilterLoading());
      _currentFilter = event.filter;

      final expenses = await searchExpenses(_currentFilter);

      emit(FilterSuccess(
        expenses: expenses,
        currentFilter: _currentFilter,
      ));
    } catch (e, stackTrace) {
      _logger.error('Error buscando gastos', e, stackTrace);
      emit(FilterError('Error al buscar gastos: ${e.toString()}'));
    }
  }

  Future<void> _onUpdateSearchQuery(
    UpdateSearchQueryEvent event,
    Emitter<FilterState> emit,
  ) async {
    final newFilter = _currentFilter.copyWith(searchQuery: event.query);
    add(SearchExpensesEvent(newFilter));
  }

  Future<void> _onUpdateCategoriesFilter(
    UpdateCategoriesFilterEvent event,
    Emitter<FilterState> emit,
  ) async {
    final newFilter = _currentFilter.copyWith(categories: event.categories);
    add(SearchExpensesEvent(newFilter));
  }

  Future<void> _onUpdateDateRangeFilter(
    UpdateDateRangeFilterEvent event,
    Emitter<FilterState> emit,
  ) async {
    final newFilter = _currentFilter.copyWith(
      startDate: event.startDate,
      endDate: event.endDate,
    );
    add(SearchExpensesEvent(newFilter));
  }

  Future<void> _onUpdateAmountRangeFilter(
    UpdateAmountRangeFilterEvent event,
    Emitter<FilterState> emit,
  ) async {
    final newFilter = _currentFilter.copyWith(
      minAmount: event.minAmount,
      maxAmount: event.maxAmount,
    );
    add(SearchExpensesEvent(newFilter));
  }

  Future<void> _onUpdateSortOption(
    UpdateSortOptionEvent event,
    Emitter<FilterState> emit,
  ) async {
    final newFilter = _currentFilter.copyWith(sortBy: event.sortOption);
    add(SearchExpensesEvent(newFilter));
  }

  Future<void> _onClearAllFilters(
    ClearAllFiltersEvent event,
    Emitter<FilterState> emit,
  ) async {
    _currentFilter = const ExpenseFilter.empty();
    add(SearchExpensesEvent(_currentFilter));
  }

  Future<void> _onClearSpecificFilter(
    ClearSpecificFilterEvent event,
    Emitter<FilterState> emit,
  ) async {
    ExpenseFilter newFilter;

    switch (event.filterType) {
      case FilterType.search:
        newFilter = _currentFilter.copyWith(clearSearch: true);
        break;
      case FilterType.categories:
        newFilter = _currentFilter.copyWith(clearCategories: true);
        break;
      case FilterType.dateRange:
        newFilter = _currentFilter.copyWith(clearDateRange: true);
        break;
      case FilterType.amountRange:
        newFilter = _currentFilter.copyWith(clearAmountRange: true);
        break;
    }

    add(SearchExpensesEvent(newFilter));
  }
}

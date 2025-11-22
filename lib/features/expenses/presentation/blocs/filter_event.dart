import 'package:equatable/equatable.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/expense_filter.dart';

abstract class FilterEvent extends Equatable {
  const FilterEvent();

  @override
  List<Object?> get props => [];
}

/// Evento para buscar gastos con filtro
class SearchExpensesEvent extends FilterEvent {
  final ExpenseFilter filter;

  const SearchExpensesEvent(this.filter);

  @override
  List<Object?> get props => [filter];
}

/// Evento para actualizar la búsqueda por texto
class UpdateSearchQueryEvent extends FilterEvent {
  final String query;

  const UpdateSearchQueryEvent(this.query);

  @override
  List<Object?> get props => [query];
}

/// Evento para actualizar categorías seleccionadas
class UpdateCategoriesFilterEvent extends FilterEvent {
  final List<Category> categories;

  const UpdateCategoriesFilterEvent(this.categories);

  @override
  List<Object?> get props => [categories];
}

/// Evento para actualizar rango de fechas
class UpdateDateRangeFilterEvent extends FilterEvent {
  final DateTime? startDate;
  final DateTime? endDate;

  const UpdateDateRangeFilterEvent({this.startDate, this.endDate});

  @override
  List<Object?> get props => [startDate, endDate];
}

/// Evento para actualizar rango de montos
class UpdateAmountRangeFilterEvent extends FilterEvent {
  final double? minAmount;
  final double? maxAmount;

  const UpdateAmountRangeFilterEvent({this.minAmount, this.maxAmount});

  @override
  List<Object?> get props => [minAmount, maxAmount];
}

/// Evento para actualizar el ordenamiento
class UpdateSortOptionEvent extends FilterEvent {
  final ExpenseSortOption sortOption;

  const UpdateSortOptionEvent(this.sortOption);

  @override
  List<Object?> get props => [sortOption];
}

/// Evento para limpiar todos los filtros
class ClearAllFiltersEvent extends FilterEvent {
  const ClearAllFiltersEvent();
}

/// Evento para limpiar un filtro específico
class ClearSpecificFilterEvent extends FilterEvent {
  final FilterType filterType;

  const ClearSpecificFilterEvent(this.filterType);

  @override
  List<Object?> get props => [filterType];
}

/// Tipos de filtros que se pueden limpiar individualmente
enum FilterType {
  search,
  categories,
  dateRange,
  amountRange,
}

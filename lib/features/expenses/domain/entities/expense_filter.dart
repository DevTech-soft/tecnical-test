import 'package:equatable/equatable.dart';
import 'category.dart';

/// Filtro de gastos con múltiples opciones
class ExpenseFilter extends Equatable {
  /// Texto de búsqueda (busca en notas y categoría)
  final String? searchQuery;

  /// Categorías seleccionadas para filtrar
  final List<Category>? categories;

  /// Fecha de inicio del rango
  final DateTime? startDate;

  /// Fecha de fin del rango
  final DateTime? endDate;

  /// Monto mínimo
  final double? minAmount;

  /// Monto máximo
  final double? maxAmount;

  /// Ordenamiento (amount_asc, amount_desc, date_asc, date_desc, category)
  final ExpenseSortOption sortBy;

  const ExpenseFilter({
    this.searchQuery,
    this.categories,
    this.startDate,
    this.endDate,
    this.minAmount,
    this.maxAmount,
    this.sortBy = ExpenseSortOption.dateDesc,
  });

  /// Filtro vacío (sin filtros aplicados)
  const ExpenseFilter.empty()
      : searchQuery = null,
        categories = null,
        startDate = null,
        endDate = null,
        minAmount = null,
        maxAmount = null,
        sortBy = ExpenseSortOption.dateDesc;

  /// Verifica si hay algún filtro activo
  bool get hasActiveFilters =>
      searchQuery != null && searchQuery!.isNotEmpty ||
      categories != null && categories!.isNotEmpty ||
      startDate != null ||
      endDate != null ||
      minAmount != null ||
      maxAmount != null;

  /// Cuenta los filtros activos
  int get activeFiltersCount {
    int count = 0;
    if (searchQuery != null && searchQuery!.isNotEmpty) count++;
    if (categories != null && categories!.isNotEmpty) count++;
    if (startDate != null || endDate != null) count++;
    if (minAmount != null || maxAmount != null) count++;
    return count;
  }

  /// Copia con nuevos valores
  ExpenseFilter copyWith({
    String? searchQuery,
    List<Category>? categories,
    DateTime? startDate,
    DateTime? endDate,
    double? minAmount,
    double? maxAmount,
    ExpenseSortOption? sortBy,
    bool clearSearch = false,
    bool clearCategories = false,
    bool clearDateRange = false,
    bool clearAmountRange = false,
  }) {
    return ExpenseFilter(
      searchQuery: clearSearch ? null : searchQuery ?? this.searchQuery,
      categories: clearCategories ? null : categories ?? this.categories,
      startDate: clearDateRange ? null : startDate ?? this.startDate,
      endDate: clearDateRange ? null : endDate ?? this.endDate,
      minAmount: clearAmountRange ? null : minAmount ?? this.minAmount,
      maxAmount: clearAmountRange ? null : maxAmount ?? this.maxAmount,
      sortBy: sortBy ?? this.sortBy,
    );
  }

  /// Limpia todos los filtros
  ExpenseFilter clearAll() => const ExpenseFilter.empty();

  @override
  List<Object?> get props => [
        searchQuery,
        categories,
        startDate,
        endDate,
        minAmount,
        maxAmount,
        sortBy,
      ];
}

/// Opciones de ordenamiento
enum ExpenseSortOption {
  /// Monto ascendente (menor a mayor)
  amountAsc,

  /// Monto descendente (mayor a menor)
  amountDesc,

  /// Fecha ascendente (más antigua primero)
  dateAsc,

  /// Fecha descendente (más reciente primero)
  dateDesc,

  /// Por categoría (alfabético)
  category,
}

/// Extensión para obtener el nombre legible de cada opción
extension ExpenseSortOptionX on ExpenseSortOption {
  String get displayName {
    switch (this) {
      case ExpenseSortOption.amountAsc:
        return 'Monto: Menor a Mayor';
      case ExpenseSortOption.amountDesc:
        return 'Monto: Mayor a Menor';
      case ExpenseSortOption.dateAsc:
        return 'Fecha: Más Antigua';
      case ExpenseSortOption.dateDesc:
        return 'Fecha: Más Reciente';
      case ExpenseSortOption.category:
        return 'Categoría';
    }
  }
}

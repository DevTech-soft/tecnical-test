import '../../../../core/usecases/usecase.dart';
import '../entities/expense.dart';
import '../entities/expense_filter.dart';
import '../entities/category.dart';
import '../repositories/expense_repository.dart';

/// Use case para buscar y filtrar gastos.
///
/// Esta clase contiene TODA la lógica de negocio para:
/// - Filtrar por texto (búsqueda en notas y categorías)
/// - Filtrar por categorías múltiples
/// - Filtrar por rangos de fechas
/// - Filtrar por rangos de montos
/// - Ordenar resultados según criterio especificado
class SearchExpenses implements UseCase<List<Expense>, ExpenseFilter> {
  final ExpenseRepository repository;

  SearchExpenses(this.repository);

  @override
  Future<List<Expense>> call(ExpenseFilter filter) async {
    final allExpenses = await repository.getAllExpenses();

    final filtered = _applyFilters(allExpenses, filter);

    final sorted = _applySorting(filtered, filter.sortBy);

    return sorted;
  }

  List<Expense> _applyFilters(List<Expense> expenses, ExpenseFilter filter) {
    return expenses.where((expense) {
      // Filtro de búsqueda por texto
      if (!_matchesSearchQuery(expense, filter.searchQuery)) {
        return false;
      }

      // Filtro por categorías
      if (!_matchesCategories(expense, filter.categories)) {
        return false;
      }

      // Filtro por rango de fechas
      if (!_matchesDateRange(expense, filter.startDate, filter.endDate)) {
        return false;
      }

      // Filtro por rango de montos
      if (!_matchesAmountRange(expense, filter.minAmount, filter.maxAmount)) {
        return false;
      }

      return true;
    }).toList();
  }

  /// Verifica si el gasto coincide con la búsqueda por texto
  bool _matchesSearchQuery(Expense expense, String? searchQuery) {
    if (searchQuery == null || searchQuery.isEmpty) {
      return true; // Sin filtro de búsqueda
    }

    final query = searchQuery.toLowerCase();

    // Buscar en las notas
    final matchesNote = expense.note?.toLowerCase().contains(query) ?? false;

    // Buscar en el nombre de la categoría
    final category = CategoryHelper.getCategoryById(expense.categoryId);
    final matchesCategory = category.name.toLowerCase().contains(query);

    return matchesNote || matchesCategory;
  }

  /// Verifica si el gasto pertenece a las categorías seleccionadas
  bool _matchesCategories(Expense expense, List<Category>? categories) {
    if (categories == null || categories.isEmpty) {
      return true; // Sin filtro de categorías
    }

    final categoryIds = categories.map((c) => c.id).toList();
    return categoryIds.contains(expense.categoryId);
  }

  /// Verifica si el gasto está dentro del rango de fechas
  bool _matchesDateRange(Expense expense, DateTime? startDate, DateTime? endDate) {
    if (startDate != null && expense.date.isBefore(startDate)) {
      return false;
    }

    if (endDate != null) {
      // Incluir todo el día final (hasta las 23:59:59)
      final endOfDay = DateTime(
        endDate.year,
        endDate.month,
        endDate.day,
        23,
        59,
        59,
      );
      if (expense.date.isAfter(endOfDay)) {
        return false;
      }
    }

    return true;
  }

  /// Verifica si el gasto está dentro del rango de montos
  bool _matchesAmountRange(Expense expense, double? minAmount, double? maxAmount) {
    if (minAmount != null && expense.amount < minAmount) {
      return false;
    }

    if (maxAmount != null && expense.amount > maxAmount) {
      return false;
    }

    return true;
  }

  /// Aplica el ordenamiento según la opción especificada
  List<Expense> _applySorting(List<Expense> expenses, ExpenseSortOption sortBy) {
    final sortedList = List<Expense>.from(expenses);

    switch (sortBy) {
      case ExpenseSortOption.amountAsc:
        sortedList.sort((a, b) => a.amount.compareTo(b.amount));
        break;

      case ExpenseSortOption.amountDesc:
        sortedList.sort((a, b) => b.amount.compareTo(a.amount));
        break;

      case ExpenseSortOption.dateAsc:
        sortedList.sort((a, b) => a.date.compareTo(b.date));
        break;

      case ExpenseSortOption.dateDesc:
        sortedList.sort((a, b) => b.date.compareTo(a.date));
        break;

      case ExpenseSortOption.category:
        sortedList.sort((a, b) {
          final catA = CategoryHelper.getCategoryById(a.categoryId);
          final catB = CategoryHelper.getCategoryById(b.categoryId);
          return catA.name.compareTo(catB.name);
        });
        break;
    }

    return sortedList;
  }
}

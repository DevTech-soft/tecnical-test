import '../../../../core/usecases/usecase.dart';
import '../entities/budget.dart';
import '../repositories/budget_repository.dart';

class GetCurrentBudget extends UseCase<Budget?, GetCurrentBudgetParams> {
  final BudgetRepository repository;

  GetCurrentBudget(this.repository);

  @override
  Future<Budget?> call(GetCurrentBudgetParams params) async {
    final now = DateTime.now();
    final month = params.month ?? now.month;
    final year = params.year ?? now.year;

    if (params.categoryId == null) {
      // Obtener presupuesto general
      return await repository.getGeneralBudget(
        month: month,
        year: year,
      );
    } else {
      // Obtener presupuesto de categoría específica
      return await repository.getCategoryBudget(
        categoryId: params.categoryId!,
        month: month,
        year: year,
      );
    }
  }
}

class GetCurrentBudgetParams {
  final String? categoryId;
  final int? month; // null = mes actual
  final int? year; // null = año actual

  GetCurrentBudgetParams({
    this.categoryId,
    this.month,
    this.year,
  });
}

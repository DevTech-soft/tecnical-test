import '../../../../core/errors/exceptions.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/validators/input_validators.dart';
import '../entities/budget.dart';
import '../repositories/budget_repository.dart';

class CreateBudget extends UseCase<Budget, CreateBudgetParams> {
  final BudgetRepository repository;

  CreateBudget(this.repository);

  @override
  Future<Budget> call(CreateBudgetParams params) async {
    // Validar todos los parámetros del presupuesto
    InputValidators.validateBudget(
      amount: params.amount,
      month: params.month,
      year: params.year,
      categoryId: params.categoryId,
    );

    // Verificar si ya existe un presupuesto para este período
    if (params.categoryId == null) {
      final exists = await repository.hasGeneralBudget(
        month: params.month,
        year: params.year,
      );
      if (exists) {
        throw CacheException(
          message: 'Ya existe un presupuesto general para ${params.month}/${params.year}',
          code: 'DUPLICATE_BUDGET',
        );
      }
    } else {
      final exists = await repository.hasCategoryBudget(
        categoryId: params.categoryId!,
        month: params.month,
        year: params.year,
      );
      if (exists) {
        throw CacheException(
          message: 'Ya existe un presupuesto para esta categoría en ${params.month}/${params.year}',
          code: 'DUPLICATE_CATEGORY_BUDGET',
        );
      }
    }

    final now = DateTime.now();
    final budget = Budget(
      id: params.id,
      amount: params.amount,
      month: params.month,
      year: params.year,
      categoryId: params.categoryId,
      createdAt: now,
      updatedAt: now,
    );

    return await repository.createBudget(budget);
  }
}

class CreateBudgetParams {
  final String id;
  final double amount;
  final int month;
  final int year;
  final String? categoryId;

  CreateBudgetParams({
    required this.id,
    required this.amount,
    required this.month,
    required this.year,
    this.categoryId,
  });
}

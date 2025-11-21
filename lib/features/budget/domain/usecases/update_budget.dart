import '../../../../core/errors/exceptions.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/validators/input_validators.dart';
import '../entities/budget.dart';
import '../repositories/budget_repository.dart';

class UpdateBudget extends UseCase<Budget, UpdateBudgetParams> {
  final BudgetRepository repository;

  UpdateBudget(this.repository);

  @override
  Future<Budget> call(UpdateBudgetParams params) async {
    // Validar que el monto sea positivo si se está actualizando
    if (params.amount != null) {
      InputValidators.validateAmount(params.amount!);
    }

    // Validar período si se está actualizando
    if (params.month != null || params.year != null) {
      // Si se actualiza uno, necesitamos ambos para validar
      final currentBudget = await repository.getBudgetById(params.budgetId);
      if (currentBudget == null) {
        throw CacheException.notFound();
      }

      final month = params.month ?? currentBudget.month;
      final year = params.year ?? currentBudget.year;
      InputValidators.validateBudgetPeriod(month: month, year: year);
    }

    // Obtener el presupuesto actual
    final currentBudget = await repository.getBudgetById(params.budgetId);
    if (currentBudget == null) {
      throw CacheException.notFound();
    }

    // Crear presupuesto actualizado
    final updatedBudget = currentBudget.copyWith(
      amount: params.amount ?? currentBudget.amount,
      month: params.month ?? currentBudget.month,
      year: params.year ?? currentBudget.year,
      updatedAt: DateTime.now(),
    );

    return await repository.updateBudget(updatedBudget);
  }
}

class UpdateBudgetParams {
  final String budgetId;
  final double? amount;
  final int? month;
  final int? year;

  UpdateBudgetParams({
    required this.budgetId,
    this.amount,
    this.month,
    this.year,
  });
}

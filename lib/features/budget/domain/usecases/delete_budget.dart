import '../../../../core/usecases/usecase.dart';
import '../repositories/budget_repository.dart';

class DeleteBudget extends UseCase<void, DeleteBudgetParams> {
  final BudgetRepository repository;

  DeleteBudget(this.repository);

  @override
  Future<void> call(DeleteBudgetParams params) async {
    return await repository.deleteBudget(params.budgetId);
  }
}

class DeleteBudgetParams {
  final String budgetId;

  DeleteBudgetParams({required this.budgetId});
}

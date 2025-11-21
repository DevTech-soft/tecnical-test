import '../../../../core/usecases/usecase.dart';
import '../../../expenses/domain/repositories/expense_repository.dart';
import '../entities/budget.dart';
import '../entities/budget_alert_level.dart';
import '../entities/budget_status.dart';

class CalculateBudgetStatus extends UseCase<BudgetStatus, CalculateBudgetStatusParams> {
  final ExpenseRepository expenseRepository;

  CalculateBudgetStatus(this.expenseRepository);

  @override
  Future<BudgetStatus> call(CalculateBudgetStatusParams params) async {
    final budget = params.budget;

    // Obtener gastos del período
    final expenses = await expenseRepository.getExpensesByDateRange(
      startDate: budget.periodStart,
      endDate: budget.periodEnd,
    );

    // Filtrar por categoría si el presupuesto es específico
    final relevantExpenses = budget.isCategorySpecific
        ? expenses.where((e) => e.categoryId == budget.categoryId).toList()
        : expenses;

    // Calcular total gastado
    final spent = relevantExpenses.fold<double>(
      0.0,
      (sum, expense) => sum + expense.amount,
    );

    // Calcular restante
    final remaining = budget.amount - spent;

    // Calcular porcentaje gastado
    final percentage = budget.amount > 0 ? spent / budget.amount : 0.0;

    // Determinar nivel de alerta
    final alertLevel = getBudgetAlertLevelFromPercentage(percentage);

    // Calcular días restantes en el período
    final now = DateTime.now();
    final daysRemaining = budget.periodEnd.difference(now).inDays;

    // Calcular gasto promedio diario
    final daysElapsed = now.difference(budget.periodStart).inDays + 1;
    final dailyAverage = daysElapsed > 0 ? spent / daysElapsed : 0.0;

    // Calcular gasto diario recomendado para no exceder
    final recommendedDailySpending = daysRemaining > 0
        ? remaining / daysRemaining
        : 0.0;

    return BudgetStatus(
      budget: budget,
      spent: spent,
      remaining: remaining,
      percentage: percentage,
      alertLevel: alertLevel,
      daysRemaining: daysRemaining,
      dailyAverage: dailyAverage,
      recommendedDailySpending: recommendedDailySpending > 0
          ? recommendedDailySpending
          : 0.0,
    );
  }
}

class CalculateBudgetStatusParams {
  final Budget budget;

  CalculateBudgetStatusParams({required this.budget});
}

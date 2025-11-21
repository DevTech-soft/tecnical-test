import 'package:equatable/equatable.dart';
import 'budget.dart';
import 'budget_alert_level.dart';

class BudgetStatus extends Equatable {
  final Budget budget;
  final double spent; // Total gastado en el período
  final double remaining; // Monto restante
  final double percentage; // Porcentaje gastado (0.0 - 1.0+)
  final BudgetAlertLevel alertLevel; // Nivel de alerta
  final int daysRemaining; // Días restantes en el período
  final double dailyAverage; // Gasto promedio diario
  final double recommendedDailySpending; // Gasto diario recomendado para no exceder

  const BudgetStatus({
    required this.budget,
    required this.spent,
    required this.remaining,
    required this.percentage,
    required this.alertLevel,
    required this.daysRemaining,
    required this.dailyAverage,
    required this.recommendedDailySpending,
  });

  /// Retorna true si el presupuesto ha sido excedido
  bool get isExceeded => percentage >= 1.0;

  /// Retorna true si el presupuesto está en zona segura (< 50%)
  bool get isSafe => alertLevel == BudgetAlertLevel.safe;

  /// Retorna true si el presupuesto está en riesgo (>= 75%)
  bool get isAtRisk =>
      alertLevel == BudgetAlertLevel.warning ||
      alertLevel == BudgetAlertLevel.critical ||
      alertLevel == BudgetAlertLevel.exceeded;

  /// Retorna el monto proyectado al final del mes basado en el gasto promedio diario
  double get projectedTotal {
    final daysInMonth = budget.periodEnd.day;
    return dailyAverage * daysInMonth;
  }

  /// Retorna true si la proyección indica que se excederá el presupuesto
  bool get willLikelyExceed => projectedTotal > budget.amount;

  /// Retorna el porcentaje en formato de 0-100 (para mostrar en UI)
  double get percentageDisplay => percentage * 100;

  /// Retorna un mensaje descriptivo del estado del presupuesto
  String get statusMessage {
    if (isExceeded) {
      final excess = spent - budget.amount;
      return 'Has excedido tu presupuesto por \$${excess.toStringAsFixed(2)}';
    } else if (remaining <= 0) {
      return 'Has alcanzado tu límite de presupuesto';
    } else if (willLikelyExceed && !isExceeded) {
      return 'A este ritmo, excederás tu presupuesto';
    } else if (isSafe) {
      return 'Tu gasto está bajo control';
    } else {
      return alertLevel.description;
    }
  }

  @override
  List<Object?> get props => [
        budget,
        spent,
        remaining,
        percentage,
        alertLevel,
        daysRemaining,
        dailyAverage,
        recommendedDailySpending,
      ];
}

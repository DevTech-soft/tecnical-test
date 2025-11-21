enum BudgetAlertLevel {
  safe, // 0-49% gastado - Verde
  info, // 50-74% gastado - Azul
  warning, // 75-89% gastado - Amarillo
  critical, // 90-99% gastado - Naranja
  exceeded, // 100%+ gastado - Rojo
}

extension BudgetAlertLevelExtension on BudgetAlertLevel {
  String get label {
    switch (this) {
      case BudgetAlertLevel.safe:
        return 'Seguro';
      case BudgetAlertLevel.info:
        return 'Información';
      case BudgetAlertLevel.warning:
        return 'Advertencia';
      case BudgetAlertLevel.critical:
        return 'Crítico';
      case BudgetAlertLevel.exceeded:
        return 'Excedido';
    }
  }

  String get description {
    switch (this) {
      case BudgetAlertLevel.safe:
        return 'Tu gasto está bajo control';
      case BudgetAlertLevel.info:
        return 'Has gastado la mitad de tu presupuesto';
      case BudgetAlertLevel.warning:
        return 'Te estás acercando al límite de tu presupuesto';
      case BudgetAlertLevel.critical:
        return '¡Cuidado! Estás por exceder tu presupuesto';
      case BudgetAlertLevel.exceeded:
        return '¡Has excedido tu presupuesto!';
    }
  }

  double get threshold {
    switch (this) {
      case BudgetAlertLevel.safe:
        return 0.0;
      case BudgetAlertLevel.info:
        return 0.5; // 50%
      case BudgetAlertLevel.warning:
        return 0.75; // 75%
      case BudgetAlertLevel.critical:
        return 0.9; // 90%
      case BudgetAlertLevel.exceeded:
        return 1.0; // 100%
    }
  }
}

/// Helper function to get BudgetAlertLevel from percentage
BudgetAlertLevel getBudgetAlertLevelFromPercentage(double percentage) {
  if (percentage >= 1.0) {
    return BudgetAlertLevel.exceeded;
  } else if (percentage >= 0.9) {
    return BudgetAlertLevel.critical;
  } else if (percentage >= 0.75) {
    return BudgetAlertLevel.warning;
  } else if (percentage >= 0.5) {
    return BudgetAlertLevel.info;
  } else {
    return BudgetAlertLevel.safe;
  }
}

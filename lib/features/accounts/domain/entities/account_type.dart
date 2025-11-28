enum AccountType {
  cash,
  credit,
  savings;

  String get displayName {
    switch (this) {
      case AccountType.cash:
        return 'Efectivo';
      case AccountType.credit:
        return 'Crédito';
      case AccountType.savings:
        return 'Ahorros';
    }
  }

  String get icon {
    switch (this) {
      case AccountType.cash:
        return '💵';
      case AccountType.credit:
        return '💳';
      case AccountType.savings:
        return '🏦';
    }
  }

  static AccountType fromString(String type) {
    switch (type.toLowerCase()) {
      case 'cash':
        return AccountType.cash;
      case 'credit':
        return AccountType.credit;
      case 'savings':
        return AccountType.savings;
      default:
        throw ArgumentError('Invalid account type: $type');
    }
  }
}

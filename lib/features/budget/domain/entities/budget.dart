import 'package:equatable/equatable.dart';

class Budget extends Equatable {
  final String id;
  final double amount; // Monto del presupuesto
  final int month; // 1-12
  final int year; // e.g., 2025
  final String? categoryId; // null = presupuesto general, si tiene valor = presupuesto por categoría
  final DateTime createdAt;
  final DateTime updatedAt;

  const Budget({
    required this.id,
    required this.amount,
    required this.month,
    required this.year,
    this.categoryId,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Retorna true si este presupuesto es general (no está asociado a una categoría específica)
  bool get isGeneral => categoryId == null;

  /// Retorna true si este presupuesto es para una categoría específica
  bool get isCategorySpecific => categoryId != null;

  /// Retorna la fecha de inicio del período del presupuesto
  DateTime get periodStart => DateTime(year, month, 1);

  /// Retorna la fecha de fin del período del presupuesto
  DateTime get periodEnd {
    // Último día del mes
    final nextMonth = month == 12 ? 1 : month + 1;
    final nextYear = month == 12 ? year + 1 : year;
    return DateTime(nextYear, nextMonth, 0, 23, 59, 59);
  }

  /// Retorna true si el presupuesto corresponde al mes y año actual
  bool get isCurrentPeriod {
    final now = DateTime.now();
    return month == now.month && year == now.year;
  }

  /// Retorna el período en formato legible: "Enero 2025"
  String get periodLabel {
    const months = [
      'Enero',
      'Febrero',
      'Marzo',
      'Abril',
      'Mayo',
      'Junio',
      'Julio',
      'Agosto',
      'Septiembre',
      'Octubre',
      'Noviembre',
      'Diciembre',
    ];
    return '${months[month - 1]} $year';
  }

  /// Crea una copia del presupuesto con los campos actualizados
  Budget copyWith({
    String? id,
    double? amount,
    int? month,
    int? year,
    String? categoryId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Budget(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      month: month ?? this.month,
      year: year ?? this.year,
      categoryId: categoryId ?? this.categoryId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        amount,
        month,
        year,
        categoryId,
        createdAt,
        updatedAt,
      ];
}

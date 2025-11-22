import 'package:equatable/equatable.dart';
import 'frequency_type.dart';

/// Entidad que representa un gasto recurrente (plantilla)
///
/// Los gastos recurrentes son plantillas que generan gastos reales
/// de forma automática según su frecuencia configurada.
class RecurringExpense extends Equatable {
  /// ID único del gasto recurrente
  final String id;

  /// Monto del gasto
  final double amount;

  /// ID de la categoría
  final String categoryId;

  /// Nota o descripción (opcional)
  final String? note;

  /// Frecuencia de recurrencia
  final FrequencyType frequency;

  /// Fecha de inicio de la recurrencia
  final DateTime startDate;

  /// Fecha de fin de la recurrencia (opcional)
  /// Si es null, la recurrencia es indefinida
  final DateTime? endDate;

  /// Última fecha en que se generó un gasto desde esta recurrencia
  final DateTime? lastGenerated;

  /// Indica si la recurrencia está activa
  /// Si es false, está pausada y no generará gastos
  final bool isActive;

  /// Fecha de creación del registro
  final DateTime createdAt;

  /// Fecha de última actualización
  final DateTime updatedAt;

  const RecurringExpense({
    required this.id,
    required this.amount,
    required this.categoryId,
    this.note,
    required this.frequency,
    required this.startDate,
    this.endDate,
    this.lastGenerated,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Verifica si la recurrencia debe generar un gasto ahora
  bool shouldGenerateNow() {
    // Si está pausada, no generar
    if (!isActive) return false;

    // Si tiene fecha de fin y ya pasó, no generar
    if (endDate != null && DateTime.now().isAfter(endDate!)) {
      return false;
    }

    // Si nunca se ha generado y la fecha de inicio ya pasó, generar
    if (lastGenerated == null) {
      return DateTime.now().isAfter(startDate) ||
             DateTime.now().isAtSameMomentAs(startDate);
    }

    // Verificar si debe generarse según la frecuencia
    return frequency.shouldGenerate(lastGenerated!, DateTime.now());
  }

  /// Obtiene la próxima fecha de generación
  DateTime? get nextGenerationDate {
    if (!isActive) return null;
    if (endDate != null && DateTime.now().isAfter(endDate!)) return null;

    if (lastGenerated == null) {
      return startDate;
    }

    return frequency.nextDate(lastGenerated!);
  }

  /// Verifica si la recurrencia está vencida (pasó la fecha de fin)
  bool get isExpired {
    if (endDate == null) return false;
    return DateTime.now().isAfter(endDate!);
  }

  /// Verifica si la recurrencia está pendiente de inicio
  bool get isPending {
    return DateTime.now().isBefore(startDate);
  }

  /// Copia con nuevos valores
  RecurringExpense copyWith({
    String? id,
    double? amount,
    String? categoryId,
    String? note,
    FrequencyType? frequency,
    DateTime? startDate,
    DateTime? endDate,
    DateTime? lastGenerated,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool clearEndDate = false,
    bool clearNote = false,
    bool clearLastGenerated = false,
  }) {
    return RecurringExpense(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      categoryId: categoryId ?? this.categoryId,
      note: clearNote ? null : note ?? this.note,
      frequency: frequency ?? this.frequency,
      startDate: startDate ?? this.startDate,
      endDate: clearEndDate ? null : endDate ?? this.endDate,
      lastGenerated: clearLastGenerated ? null : lastGenerated ?? this.lastGenerated,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        amount,
        categoryId,
        note,
        frequency,
        startDate,
        endDate,
        lastGenerated,
        isActive,
        createdAt,
        updatedAt,
      ];
}

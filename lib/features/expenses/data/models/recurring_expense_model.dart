import 'package:hive/hive.dart';
import '../../domain/entities/frequency_type.dart';
import '../../domain/entities/recurring_expense.dart';

part 'recurring_expense_model.g.dart';

@HiveType(typeId: 2) // typeId 0 es ExpenseModel, 1 es BudgetModel
class RecurringExpenseModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final double amount;

  @HiveField(2)
  final String categoryId;

  @HiveField(3)
  final String? note;

  @HiveField(4)
  final String frequency; // Guardamos como String para Hive

  @HiveField(5)
  final DateTime startDate;

  @HiveField(6)
  final DateTime? endDate;

  @HiveField(7)
  final DateTime? lastGenerated;

  @HiveField(8)
  final bool isActive;

  @HiveField(9)
  final DateTime createdAt;

  @HiveField(10)
  final DateTime updatedAt;

  RecurringExpenseModel({
    required this.id,
    required this.amount,
    required this.categoryId,
    this.note,
    required this.frequency,
    required this.startDate,
    this.endDate,
    this.lastGenerated,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Convierte el modelo a entidad de dominio
  RecurringExpense toEntity() {
    return RecurringExpense(
      id: id,
      amount: amount,
      categoryId: categoryId,
      note: note,
      frequency: _frequencyTypeFromString(frequency),
      startDate: startDate,
      endDate: endDate,
      lastGenerated: lastGenerated,
      isActive: isActive,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// Crea un modelo desde una entidad de dominio
  factory RecurringExpenseModel.fromEntity(RecurringExpense entity) {
    return RecurringExpenseModel(
      id: entity.id,
      amount: entity.amount,
      categoryId: entity.categoryId,
      note: entity.note,
      frequency: _frequencyTypeToString(entity.frequency),
      startDate: entity.startDate,
      endDate: entity.endDate,
      lastGenerated: entity.lastGenerated,
      isActive: entity.isActive,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  /// Convierte String a FrequencyType
  static FrequencyType _frequencyTypeFromString(String frequency) {
    return FrequencyType.values.firstWhere(
      (e) => e.toString().split('.').last == frequency,
      orElse: () => FrequencyType.monthly, // Default
    );
  }

  /// Convierte FrequencyType a String
  static String _frequencyTypeToString(FrequencyType frequency) {
    return frequency.toString().split('.').last;
  }
}

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

  @HiveField(11)
  final String accountId;

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
    required this.accountId,
  });

  /// Convierte el modelo a entidad de dominio
  RecurringExpense toEntity() {
    return RecurringExpense(
      id: id,
      amount: amount,
      categoryId: categoryId,
      accountId: accountId,
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
      accountId: entity.accountId,
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

  /// Serializa el modelo a JSON para Firestore
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'categoryId': categoryId,
      'accountId': accountId,
      'note': note,
      'frequency': frequency,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'lastGenerated': lastGenerated?.toIso8601String(),
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Deserializa desde JSON de Firestore
  factory RecurringExpenseModel.fromJson(Map<String, dynamic> json) {
    return RecurringExpenseModel(
      id: json['id'] as String,
      amount: (json['amount'] as num).toDouble(),
      categoryId: json['categoryId'] as String,
      accountId: json['accountId'] as String,
      note: json['note'] as String?,
      frequency: json['frequency'] as String,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate'] as String) : null,
      lastGenerated: json['lastGenerated'] != null ? DateTime.parse(json['lastGenerated'] as String) : null,
      isActive: json['isActive'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}

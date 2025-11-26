import 'package:hive/hive.dart';
import '../../domain/entities/budget.dart';

part 'budget_model.g.dart';

@HiveType(typeId: 1)
class BudgetModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  double amount;

  @HiveField(2)
  int month;

  @HiveField(3)
  int year;

  @HiveField(4)
  String? categoryId;

  @HiveField(5)
  DateTime createdAt;

  @HiveField(6)
  DateTime updatedAt;

  BudgetModel({
    required this.id,
    required this.amount,
    required this.month,
    required this.year,
    this.categoryId,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Convierte el modelo a una entidad de dominio
  Budget toEntity() {
    return Budget(
      id: id,
      amount: amount,
      month: month,
      year: year,
      categoryId: categoryId,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// Crea un modelo desde una entidad de dominio
  factory BudgetModel.fromEntity(Budget budget) {
    return BudgetModel(
      id: budget.id,
      amount: budget.amount,
      month: budget.month,
      year: budget.year,
      categoryId: budget.categoryId,
      createdAt: budget.createdAt,
      updatedAt: budget.updatedAt,
    );
  }

  /// Crea una copia del modelo con los campos actualizados
  BudgetModel copyWith({
    String? id,
    double? amount,
    int? month,
    int? year,
    String? categoryId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return BudgetModel(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      month: month ?? this.month,
      year: year ?? this.year,
      categoryId: categoryId ?? this.categoryId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Serializa el modelo a JSON para Firestore
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'month': month,
      'year': year,
      'categoryId': categoryId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Deserializa desde JSON de Firestore
  factory BudgetModel.fromJson(Map<String, dynamic> json) {
    return BudgetModel(
      id: json['id'] as String,
      amount: (json['amount'] as num).toDouble(),
      month: json['month'] as int,
      year: json['year'] as int,
      categoryId: json['categoryId'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}

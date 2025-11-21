import 'package:hive/hive.dart';
import '../../domain/entities/expense.dart';

part 'expense_model.g.dart';

@HiveType(typeId: 0)
class ExpenseModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  double amount;

  @HiveField(2)
  String categoryId;

  @HiveField(3)
  String? note;

  @HiveField(4)
  DateTime date;

  ExpenseModel({
    required this.id,
    required this.amount,
    required this.categoryId,
    this.note,
    required this.date,
  });

  factory ExpenseModel.fromEntity(Expense e) => ExpenseModel(
    id: e.id,
    amount: e.amount,
    categoryId: e.categoryId,
    note: e.note,
    date: e.date,
  );

  factory ExpenseModel.fromJson(Map<String, dynamic> json) => ExpenseModel(
    id: json['id'] as String,
    amount: (json['amount'] as num).toDouble(),
    categoryId: json['categoryId'] as String,
    note: json['note'] as String?,
    date: DateTime.parse(json['date'] as String),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'amount': amount,
    'categoryId': categoryId,
    'note': note,
    'date': date.toIso8601String(),
  };

  Expense toEntity() => Expense(
    id: id,
    amount: amount,
    categoryId: categoryId,
    note: note,
    date: date,
  );
}

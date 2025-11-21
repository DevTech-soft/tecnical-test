import 'package:equatable/equatable.dart';

class Expense extends Equatable {
  final String id;
  final double amount;
  final String categoryId;
  final String? note;
  final DateTime date;

  const Expense({
    required this.id,
    required this.amount,
    required this.categoryId,
    this.note,
    required this.date,
  });

  @override
  List<Object?> get props => [id, amount, categoryId, note, date];
}

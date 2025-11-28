import 'package:equatable/equatable.dart';
import 'account_type.dart';

class Account extends Equatable {
  final String id;
  final String name;
  final AccountType type;
  final String? description;
  final double balance;
  final String icon;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Account({
    required this.id,
    required this.name,
    required this.type,
    this.description,
    required this.balance,
    required this.icon,
    required this.createdAt,
    required this.updatedAt,
  });

  Account copyWith({
    String? id,
    String? name,
    AccountType? type,
    String? description,
    double? balance,
    String? icon,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Account(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      description: description ?? this.description,
      balance: balance ?? this.balance,
      icon: icon ?? this.icon,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        type,
        description,
        balance,
        icon,
        createdAt,
        updatedAt,
      ];
}

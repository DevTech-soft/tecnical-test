import 'package:hive/hive.dart';
import '../../domain/entities/account.dart';
import '../../domain/entities/account_type.dart';

part 'account_model.g.dart';

@HiveType(typeId: 4)
class AccountModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String type;

  @HiveField(3)
  String? description;

  @HiveField(4)
  double balance;

  @HiveField(5)
  String icon;

  @HiveField(6)
  DateTime createdAt;

  @HiveField(7)
  DateTime updatedAt;

  AccountModel({
    required this.id,
    required this.name,
    required this.type,
    this.description,
    required this.balance,
    required this.icon,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AccountModel.fromEntity(Account account) => AccountModel(
        id: account.id,
        name: account.name,
        type: account.type.name,
        description: account.description,
        balance: account.balance,
        icon: account.icon,
        createdAt: account.createdAt,
        updatedAt: account.updatedAt,
      );

  factory AccountModel.fromJson(Map<String, dynamic> json) => AccountModel(
        id: json['id'] as String,
        name: json['name'] as String,
        type: json['type'] as String,
        description: json['description'] as String?,
        balance: (json['balance'] as num).toDouble(),
        icon: json['icon'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
        updatedAt: DateTime.parse(json['updatedAt'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'type': type,
        'description': description,
        'balance': balance,
        'icon': icon,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  Account toEntity() => Account(
        id: id,
        name: name,
        type: AccountType.fromString(type),
        description: description,
        balance: balance,
        icon: icon,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );
}

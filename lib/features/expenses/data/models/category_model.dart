import 'package:hive/hive.dart';
import 'package:flutter/material.dart';
import '../../domain/entities/category.dart';

part 'category_model.g.dart';

@HiveType(typeId: 3)
class CategoryModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  int iconCodePoint;

  @HiveField(3)
  String iconFontFamily;

  @HiveField(4)
  int colorValue;

  @HiveField(5)
  bool isCustom; // true si fue creada por el usuario, false si es predefinida

  CategoryModel({
    required this.id,
    required this.name,
    required this.iconCodePoint,
    required this.iconFontFamily,
    required this.colorValue,
    this.isCustom = false,
  });

  // Convertir IconData a valores serializables
  factory CategoryModel.fromEntity(ExpenseCategory category, {bool isCustom = false}) {
    return CategoryModel(
      id: category.id,
      name: category.name,
      iconCodePoint: category.icon.codePoint,
      iconFontFamily: category.icon.fontFamily ?? 'MaterialIcons',
      colorValue: category.color.value,
      isCustom: isCustom,
    );
  }

  // Reconstruir IconData desde valores serializados
  ExpenseCategory toEntity() {
    return ExpenseCategory(
      id: id,
      name: name,
      icon: IconData(
        iconCodePoint,
        fontFamily: iconFontFamily,
      ),
      color: Color(colorValue),
    );
  }

  // Para sincronización con Firestore
  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as String,
      name: json['name'] as String,
      iconCodePoint: json['iconCodePoint'] as int,
      iconFontFamily: json['iconFontFamily'] as String,
      colorValue: json['colorValue'] as int,
      isCustom: json['isCustom'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'iconCodePoint': iconCodePoint,
      'iconFontFamily': iconFontFamily,
      'colorValue': colorValue,
      'isCustom': isCustom,
    };
  }

  CategoryModel copyWith({
    String? id,
    String? name,
    int? iconCodePoint,
    String? iconFontFamily,
    int? colorValue,
    bool? isCustom,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      iconCodePoint: iconCodePoint ?? this.iconCodePoint,
      iconFontFamily: iconFontFamily ?? this.iconFontFamily,
      colorValue: colorValue ?? this.colorValue,
      isCustom: isCustom ?? this.isCustom,
    );
  }
}

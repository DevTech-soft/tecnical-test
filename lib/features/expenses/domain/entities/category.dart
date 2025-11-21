import 'package:flutter/material.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/theme/app_colors.dart';

class ExpenseCategory extends Equatable {
  final String id;
  final String name;
  final IconData icon;
  final Color color;

  const ExpenseCategory({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
  });

  @override
  List<Object?> get props => [id, name, icon, color];
}

// Alias para facilitar el uso
typedef Category = ExpenseCategory;

class CategoryHelper {
  CategoryHelper._();

  static const ExpenseCategory food = ExpenseCategory(
    id: 'food',
    name: 'Alimentación',
    icon: Icons.restaurant,
    color: AppColors.categoryFood,
  );

  static const ExpenseCategory transport = ExpenseCategory(
    id: 'transport',
    name: 'Transporte',
    icon: Icons.directions_car,
    color: AppColors.categoryTransport,
  );

  static const ExpenseCategory home = ExpenseCategory(
    id: 'home',
    name: 'Hogar',
    icon: Icons.home,
    color: AppColors.categoryHome,
  );

  static const ExpenseCategory shopping = ExpenseCategory(
    id: 'shopping',
    name: 'Compras',
    icon: Icons.shopping_bag,
    color: AppColors.categoryShopping,
  );

  static const ExpenseCategory entertainment = ExpenseCategory(
    id: 'entertainment',
    name: 'Entretenimiento',
    icon: Icons.movie,
    color: AppColors.categoryEntertainment,
  );

  static const ExpenseCategory health = ExpenseCategory(
    id: 'health',
    name: 'Salud',
    icon: Icons.favorite,
    color: AppColors.categoryHealth,
  );

  static const ExpenseCategory education = ExpenseCategory(
    id: 'education',
    name: 'Educación',
    icon: Icons.school,
    color: AppColors.categoryEducation,
  );

  static const ExpenseCategory other = ExpenseCategory(
    id: 'other',
    name: 'Otros',
    icon: Icons.more_horiz,
    color: AppColors.categoryOther,
  );

  static List<ExpenseCategory> get allCategories => [
        food,
        transport,
        home,
        shopping,
        entertainment,
        health,
        education,
        other,
      ];

  // Alias para compatibilidad
  static List<ExpenseCategory> get defaultCategories => allCategories;

  static ExpenseCategory getCategoryById(String id) {
    try {
      return allCategories.firstWhere((cat) => cat.id == id);
    } catch (e) {
      return other;
    }
  }

  static ExpenseCategory? getCategoryByIdOrNull(String? id) {
    if (id == null) return null;
    try {
      return allCategories.firstWhere((cat) => cat.id == id);
    } catch (e) {
      return null;
    }
  }
}

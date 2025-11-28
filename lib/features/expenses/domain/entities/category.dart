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
    icon: Icons.layers_outlined,
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

  // Lista de todas las categorías cargadas (predefinidas + personalizadas)
  static List<ExpenseCategory> _loadedCategories = [];

  /// Actualiza la lista de categorías cargadas (debe ser llamado por CategoryBloc)
  static void updateLoadedCategories(List<ExpenseCategory> categories) {
    _loadedCategories = categories;
  }

  /// Busca una categoría por ID en todas las categorías cargadas
  /// Si no está cargada, busca en las predefinidas como fallback
  static ExpenseCategory getCategoryById(String id) {
    // Primero buscar en las categorías cargadas (incluye personalizadas)
    try {
      return _loadedCategories.firstWhere((cat) => cat.id == id);
    } catch (e) {
      // Si no se encuentra, buscar en las predefinidas como fallback
      try {
        return allCategories.firstWhere((cat) => cat.id == id);
      } catch (e) {
        return other;
      }
    }
  }

  static ExpenseCategory? getCategoryByIdOrNull(String? id) {
    if (id == null) return null;

    // Primero buscar en las categorías cargadas (incluye personalizadas)
    try {
      return _loadedCategories.firstWhere((cat) => cat.id == id);
    } catch (e) {
      // Si no se encuentra, buscar en las predefinidas como fallback
      try {
        return allCategories.firstWhere((cat) => cat.id == id);
      } catch (e) {
        return null;
      }
    }
  }
}

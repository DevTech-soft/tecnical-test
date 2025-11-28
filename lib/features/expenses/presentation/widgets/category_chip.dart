import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/category.dart';
import '../../../../core/theme/app_spacing.dart';
import '../blocs/category_bloc.dart';
import '../blocs/category_state.dart';

class CategoryChip extends StatelessWidget {
  final ExpenseCategory category;
  final bool isSelected;
  final VoidCallback? onTap;

  const CategoryChip({
    super.key,
    required this.category,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        category.icon,
        size: AppSpacing.iconSM,
        color: category.color,
      ),

      title: Text(
        category.name,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: category.color,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
        ),
      ),
    );
  }
}

class CategorySelector extends StatelessWidget {
  final ExpenseCategory? selectedCategory;
  final ValueChanged<ExpenseCategory>? onCategorySelected;

  const CategorySelector({
    super.key,
    this.selectedCategory,
    this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CategoryBloc, CategoryState>(
      builder: (context, state) {
        List<ExpenseCategory> categories = [];

        if (state is CategoryLoaded) {
          categories = state.categories;
        } else if (state is CategoryOperationSuccess) {
          categories = state.categories;
        } else if (state is CategoryLoading || state is CategoryInitial) {
          // Mostrar shimmer o loading mientras carga
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(AppSpacing.md),
              child: CircularProgressIndicator(),
            ),
          );
        } else if (state is CategoryError) {
          // Fallback a categorías predefinidas en caso de error
          categories = CategoryHelper.allCategories;
        }

        // Si no hay categorías, usar las predefinidas como fallback
        if (categories.isEmpty) {
          categories = CategoryHelper.allCategories;
        }

        return Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Categoría', style: Theme.of(context).textTheme.titleMedium),
              AppSpacing.verticalSpaceSM,
              SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Column(
                  children:
                      categories.map((category) {
                        final isSelected = selectedCategory?.id == category.id;
                        return Padding(
                          padding: const EdgeInsets.only(right: AppSpacing.sm),
                          child: CategoryChip(
                            category: category,
                            isSelected: isSelected,
                            onTap: () {
                              if (onCategorySelected != null) {
                                onCategorySelected!(category);
                              }
                            },
                          ),
                        );
                      }).toList(),
                ),
              ),
              AppSpacing.verticalSpaceSM,
              Container(
                child: TextButton.icon(
                  onPressed: () {
                    // Navegar a la página de gestión de categorías
                    Navigator.pushNamed(context, '/manage_categories');
                  },
                  icon: const Icon(Icons.edit),
                  label: const Text('Gestionar Categorías'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

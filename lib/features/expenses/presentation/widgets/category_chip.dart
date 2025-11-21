import 'package:flutter/material.dart';
import '../../domain/entities/category.dart';
import '../../../../core/theme/app_spacing.dart';

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
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppSpacing.borderRadiusMD,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: isSelected
                ? category.color
                : category.color.withOpacity(0.15),
            borderRadius: AppSpacing.borderRadiusMD,
            border: Border.all(
              color: isSelected
                  ? category.color
                  : category.color.withOpacity(0.3),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                category.icon,
                size: AppSpacing.iconSM,
                color: isSelected ? Colors.white : category.color,
              ),
              AppSpacing.horizontalSpaceSM,
              Text(
                category.name,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: isSelected ? Colors.white : category.color,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    ),
              ),
            ],
          ),
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
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: CategoryHelper.allCategories.map((category) {
        return CategoryChip(
          category: category,
          isSelected: selectedCategory?.id == category.id,
          onTap: () => onCategorySelected?.call(category),
        );
      }).toList(),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../../domain/entities/expense.dart';
import '../../domain/entities/category.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/date_formatter.dart';

class ExpenseCard extends StatelessWidget {
  final Expense expense;
  final VoidCallback? onDelete;
  final VoidCallback? onTap;

  const ExpenseCard({
    super.key,
    required this.expense,
    this.onDelete,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final category = CategoryHelper.getCategoryById(expense.categoryId);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Slidable(
      key: ValueKey(expense.id),
      endActionPane: ActionPane(
        motion: const DrawerMotion(),
        extentRatio: 0.25,
        children: [
          SlidableAction(
            onPressed: (_) => onDelete?.call(),
            backgroundColor: AppColors.error,
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: 'Eliminar',
            borderRadius: AppSpacing.borderRadiusLG,
          ),
        ],
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: AppSpacing.borderRadiusLG,
          boxShadow: isDark ? AppColors.cardShadowDark : AppColors.cardShadowLight,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: AppSpacing.borderRadiusLG,
            child: Padding(
              padding: AppSpacing.paddingMD,
              child: Row(
                children: [
                  // Category Icon
                  Container(
                    width: AppSpacing.iconXL,
                    height: AppSpacing.iconXL,
                    decoration: BoxDecoration(
                      color: category.color.withOpacity(0.2),
                      borderRadius: AppSpacing.borderRadiusFull,
                    ),
                    child: Icon(
                      category.icon,
                      color: category.color,
                      size: AppSpacing.iconMD,
                    ),
                  ),

                  AppSpacing.horizontalSpaceMD,

                  // Expense Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          category.name,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        if (expense.note != null && expense.note!.isNotEmpty) ...[
                          AppSpacing.verticalSpaceXS,
                          Text(
                            expense.note!,
                            style: Theme.of(context).textTheme.bodySmall,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                        AppSpacing.verticalSpaceXS,
                        Text(
                          DateFormatter.formatDate(expense.date),
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: isDark
                                    ? AppColors.textSecondaryDark
                                    : AppColors.textSecondaryLight,
                              ),
                        ),
                      ],
                    ),
                  ),

                  AppSpacing.horizontalSpaceMD,

                  // Amount
                  Text(
                    DateFormatter.formatCurrency(expense.amount),
                    style: AppTypography.currencySmall.copyWith(
                      color: AppColors.error,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

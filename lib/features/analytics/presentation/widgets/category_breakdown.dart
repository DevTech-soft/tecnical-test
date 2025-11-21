import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../expenses/domain/entities/expense.dart';
import '../../../expenses/domain/entities/category.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/widgets/custom_card.dart';

class CategoryBreakdown extends StatelessWidget {
  final List<Expense> expenses;

  const CategoryBreakdown({
    super.key,
    required this.expenses,
  });

  Map<String, double> get categoryTotals {
    final Map<String, double> totals = {};
    for (final expense in expenses) {
      totals[expense.categoryId] =
          (totals[expense.categoryId] ?? 0) + expense.amount;
    }
    return totals;
  }

  List<MapEntry<String, double>> get sortedCategories {
    final sorted = categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sorted;
  }

  double get totalAmount {
    return categoryTotals.values.fold(0, (a, b) => a + b);
  }

  @override
  Widget build(BuildContext context) {
    if (expenses.isEmpty) return const SizedBox.shrink();

    return CustomCard(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      elevation: AppSpacing.elevation1,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Gastos por Categoría',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          AppSpacing.verticalSpaceLG,

          // Pie Chart
          SizedBox(
            height: 200,
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 2,
                      centerSpaceRadius: 50,
                      sections: sortedCategories.take(5).map((entry) {
                        final category =
                            CategoryHelper.getCategoryById(entry.key);
                        final percentage = (entry.value / totalAmount) * 100;

                        return PieChartSectionData(
                          color: category.color,
                          value: entry.value,
                          title: '${percentage.toStringAsFixed(0)}%',
                          radius: 50,
                          titleStyle: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                AppSpacing.horizontalSpaceMD,
                Expanded(
                  flex: 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: sortedCategories.take(5).map((entry) {
                      final category =
                          CategoryHelper.getCategoryById(entry.key);
                      return Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                        child: Row(
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: category.color,
                                shape: BoxShape.circle,
                              ),
                            ),
                            AppSpacing.horizontalSpaceXS,
                            Expanded(
                              child: Text(
                                category.name,
                                style: Theme.of(context).textTheme.labelSmall,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),

          AppSpacing.verticalSpaceLG,
          const Divider(),
          AppSpacing.verticalSpaceSM,

          // Category List
          ...sortedCategories.map((entry) {
            final category = CategoryHelper.getCategoryById(entry.key);
            final percentage = (entry.value / totalAmount) * 100;
            return _buildCategoryItem(
              context,
              category,
              entry.value,
              percentage,
            );
          }),
        ],
      ),
    );
  }

  Widget _buildCategoryItem(
    BuildContext context,
    ExpenseCategory category,
    double amount,
    double percentage,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        children: [
          Container(
            width: AppSpacing.iconMD,
            height: AppSpacing.iconMD,
            decoration: BoxDecoration(
              color: category.color.withOpacity(0.2),
              borderRadius: AppSpacing.borderRadiusSM,
            ),
            child: Icon(
              category.icon,
              size: AppSpacing.iconSM,
              color: category.color,
            ),
          ),
          AppSpacing.horizontalSpaceMD,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      category.name,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                    Text(
                      DateFormatter.formatCurrency(amount),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ],
                ),
                AppSpacing.verticalSpaceXS,
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: AppSpacing.borderRadiusSM,
                        child: LinearProgressIndicator(
                          value: percentage / 100,
                          backgroundColor:
                              isDark ? AppColors.grey700 : AppColors.grey200,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(category.color),
                          minHeight: 6,
                        ),
                      ),
                    ),
                    AppSpacing.horizontalSpaceSM,
                    Text(
                      '${percentage.toStringAsFixed(1)}%',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondaryLight,
                          ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

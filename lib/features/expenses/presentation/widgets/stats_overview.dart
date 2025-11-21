import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../domain/entities/expense.dart';
import '../../domain/entities/category.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/widgets/custom_card.dart';

class StatsOverview extends StatelessWidget {
  final List<Expense> expenses;

  const StatsOverview({
    super.key,
    required this.expenses,
  });

  Map<String, double> get categoryTotals {
    final Map<String, double> totals = {};
    for (final expense in expenses) {
      totals[expense.categoryId] = (totals[expense.categoryId] ?? 0) + expense.amount;
    }
    return totals;
  }

  List<MapEntry<String, double>> get topCategories {
    final sorted = categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sorted.take(3).toList();
  }

  @override
  Widget build(BuildContext context) {
    if (expenses.isEmpty) return const SizedBox.shrink();

    return CustomCard(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
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
          AppSpacing.verticalSpaceMD,
          SizedBox(
            height: 120,
            child: _buildPieChart(context),
          ),
          AppSpacing.verticalSpaceLG,
          ...topCategories.map((entry) {
            final category = CategoryHelper.getCategoryById(entry.key);
            final percentage = (entry.value / categoryTotals.values.fold(0.0, (a, b) => a + b)) * 100;
            return _buildCategoryItem(context, category, entry.value, percentage);
          }),
        ],
      ),
    );
  }

  Widget _buildPieChart(BuildContext context) {
    if (categoryTotals.isEmpty) return const SizedBox.shrink();

    return PieChart(
      PieChartData(
        sectionsSpace: 2,
        centerSpaceRadius: 40,
        sections: categoryTotals.entries.map((entry) {
          final category = CategoryHelper.getCategoryById(entry.key);
          final total = categoryTotals.values.fold(0.0, (a, b) => a + b);
          final percentage = (entry.value / total) * 100;

          return PieChartSectionData(
            color: category.color,
            value: entry.value,
            title: '${percentage.toStringAsFixed(0)}%',
            radius: 40,
            titleStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          );
        }).toList(),
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
                Text(
                  category.name,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                ),
                AppSpacing.verticalSpaceXS,
                ClipRRect(
                  borderRadius: AppSpacing.borderRadiusSM,
                  child: LinearProgressIndicator(
                    value: percentage / 100,
                    backgroundColor: isDark ? AppColors.grey700 : AppColors.grey200,
                    valueColor: AlwaysStoppedAnimation<Color>(category.color),
                    minHeight: 4,
                  ),
                ),
              ],
            ),
          ),
          AppSpacing.horizontalSpaceMD,
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                DateFormatter.formatCurrency(amount),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
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
    );
  }
}

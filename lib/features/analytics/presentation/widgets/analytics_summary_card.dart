import 'package:flutter/material.dart';
import '../pages/analytics_page.dart';
import '../../../expenses/domain/entities/expense.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/widgets/custom_card.dart';

class AnalyticsSummaryCard extends StatelessWidget {
  final List<Expense> expenses;
  final AnalyticsPeriod period;

  const AnalyticsSummaryCard({
    super.key,
    required this.expenses,
    required this.period,
  });

  double get totalAmount {
    return expenses.fold(0, (sum, expense) => sum + expense.amount);
  }

  double get averageExpense {
    if (expenses.isEmpty) return 0;
    return totalAmount / expenses.length;
  }

  int get daysWithExpenses {
    final Set<DateTime> uniqueDays = {};
    for (final expense in expenses) {
      uniqueDays.add(DateTime(
        expense.date.year,
        expense.date.month,
        expense.date.day,
      ));
    }
    return uniqueDays.length;
  }

  double get dailyAverage {
    if (daysWithExpenses == 0) return 0;
    return totalAmount / daysWithExpenses;
  }

  String get highestExpenseCategory {
    if (expenses.isEmpty) return 'N/A';

    final Map<String, double> categoryTotals = {};
    for (final expense in expenses) {
      categoryTotals[expense.categoryId] =
          (categoryTotals[expense.categoryId] ?? 0) + expense.amount;
    }

    final highest = categoryTotals.entries.reduce(
      (a, b) => a.value > b.value ? a : b,
    );

    return highest.key;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Column(
        children: [
          // Main Total Card
          GradientCard(
            gradient: AppColors.primaryGradient,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total del Período',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white.withOpacity(0.9),
                      ),
                ),
                AppSpacing.verticalSpaceSM,
                Text(
                  DateFormatter.formatCurrency(totalAmount),
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                ),
                AppSpacing.verticalSpaceLG,
                Row(
                  children: [
                    Expanded(
                      child: _buildStatItem(
                        context,
                        'Gastos',
                        '${expenses.length}',
                        Icons.receipt_long,
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 40,
                      color: Colors.white.withOpacity(0.2),
                    ),
                    Expanded(
                      child: _buildStatItem(
                        context,
                        'Promedio',
                        DateFormatter.formatCurrency(averageExpense),
                        Icons.trending_up,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          AppSpacing.verticalSpaceMD,

          // Stats Grid
          Row(
            children: [
              Expanded(
                child: CustomCard(
                  elevation: AppSpacing.elevation1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(AppSpacing.sm),
                            decoration: BoxDecoration(
                              color: AppColors.info.withOpacity(0.1),
                              borderRadius: AppSpacing.borderRadiusSM,
                            ),
                            child: Icon(
                              Icons.calendar_today,
                              size: AppSpacing.iconSM,
                              color: AppColors.info,
                            ),
                          ),
                          AppSpacing.horizontalSpaceSM,
                          Text(
                            'Promedio/día',
                            style: Theme.of(context).textTheme.labelMedium,
                          ),
                        ],
                      ),
                      AppSpacing.verticalSpaceSM,
                      Text(
                        DateFormatter.formatCurrency(dailyAverage),
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
              AppSpacing.horizontalSpaceSM,
              Expanded(
                child: CustomCard(
                  elevation: AppSpacing.elevation1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(AppSpacing.sm),
                            decoration: BoxDecoration(
                              color: AppColors.warning.withOpacity(0.1),
                              borderRadius: AppSpacing.borderRadiusSM,
                            ),
                            child: Icon(
                              Icons.event_available,
                              size: AppSpacing.iconSM,
                              color: AppColors.warning,
                            ),
                          ),
                          AppSpacing.horizontalSpaceSM,
                          Expanded(
                            child: Text(
                              'Días activos',
                              style: Theme.of(context).textTheme.labelMedium,
                            ),
                          ),
                        ],
                      ),
                      AppSpacing.verticalSpaceSM,
                      Text(
                        '$daysWithExpenses días',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Column(
      children: [
        Icon(
          icon,
          size: AppSpacing.iconMD,
          color: Colors.white.withOpacity(0.8),
        ),
        AppSpacing.verticalSpaceXS,
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Colors.white.withOpacity(0.8),
              ),
        ),
        AppSpacing.verticalSpaceXS,
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
        ),
      ],
    );
  }
}

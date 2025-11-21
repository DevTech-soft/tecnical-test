import 'package:flutter/material.dart';
import '../../domain/entities/expense.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/widgets/custom_card.dart';

class ExpenseSummaryCard extends StatelessWidget {
  final List<Expense> expenses;

  const ExpenseSummaryCard({
    super.key,
    required this.expenses,
  });

  double get totalAmount {
    return expenses.fold(0, (sum, expense) => sum + expense.amount);
  }

  int get expenseCount => expenses.length;

  double get averageExpense {
    if (expenses.isEmpty) return 0;
    return totalAmount / expenseCount;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GradientCard(
      gradient: AppColors.primaryGradient,
      margin: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Balance Total',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white.withOpacity(0.9),
                ),
          ),
          AppSpacing.verticalSpaceSM,
          Text(
            DateFormatter.formatCurrency(totalAmount),
            style: AppTypography.currencyLarge.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
          AppSpacing.verticalSpaceLG,
          Container(
            height: 1,
            color: Colors.white.withOpacity(0.2),
          ),
          AppSpacing.verticalSpaceMD,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatItem(
                context,
                'Gastos',
                expenseCount.toString(),
              ),
              Container(
                width: 1,
                height: 40,
                color: Colors.white.withOpacity(0.2),
              ),
              _buildStatItem(
                context,
                'Promedio',
                DateFormatter.formatCurrency(averageExpense),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, String label, String value) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
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
      ),
    );
  }
}

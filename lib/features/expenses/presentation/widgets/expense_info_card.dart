import 'package:dayli_expenses/core/theme/app_colors.dart';
import 'package:dayli_expenses/core/theme/app_spacing.dart';
import 'package:dayli_expenses/core/utils/date_formatter.dart';
import 'package:flutter/material.dart';

class ExpenseInfoCard extends StatelessWidget {
  final int totalGeneralExpense;
  final String title;
  final Widget child;
  final Widget? trailing;
  final String subtitle;
  const ExpenseInfoCard({
    super.key,
    required this.totalGeneralExpense,
    required this.title,
    required this.child,
    required this.subtitle,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Theme.of(context).cardColor,
        border: Border.all(color: AppColors.grey200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(color: AppColors.grey100),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  child: Icon(
                    Icons.account_balance_wallet,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ),
                AppSpacing.horizontalSpaceSM,
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                    Text(
                      DateFormatter.formatCurrency(
                        totalGeneralExpense.toDouble(),
                      ),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          AppSpacing.verticalSpaceMD,
          Padding(
            padding: const EdgeInsets.symmetric(horizontal:AppSpacing.md),
            child: Text(
              subtitle,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).textTheme.bodySmall?.color,
              ),
            ),
          ),
          AppSpacing.verticalSpaceMD,
          child,
          AppSpacing.verticalSpaceMD,
        ],
      ),
    );
  }
}

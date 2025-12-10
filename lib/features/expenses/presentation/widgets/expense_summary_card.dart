import 'package:dayli_expenses/features/accounts/domain/entities/account.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../domain/entities/expense.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/widgets/custom_card.dart';

class ExpenseSummaryCard extends StatelessWidget {
  final List<Account> accounts;

  const ExpenseSummaryCard({
    super.key,
    required this.accounts,
  });

  double get totalAmount {
    return accounts.fold(0, (sum, account) => sum + account.balance);
  }

  int get accountCount => accounts.length;

  double get averageBalance {
    if (accounts.isEmpty) return 0;
    return totalAmount / accountCount;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GradientCard(
      gradient: AppColors.primaryGradient,
      
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Balance Actual',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
                AppSpacing.verticalSpaceSM,
                Text(
                  DateFormatter.formatCurrency(totalAmount),
                  style: AppTypography.currencyLarge.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 12.sp,
                  ),
                ),
                AppSpacing.verticalSpaceLG,
                Container(
                  height: 1,
                  color: Colors.white.withValues(alpha: 0.2),
                ),
                AppSpacing.verticalSpaceMD,
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildStatItem(context, 'Cuentas', accountCount.toString()),
                    Container(
                      width: 1,
                      height: 40,
                      color: Colors.white.withValues(alpha: 0.2),
                    ),
                    _buildStatItem(
                      context,
                      'Promedio',
                      DateFormatter.formatCurrency(averageBalance),
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

  Widget _buildStatItem(BuildContext context, String label, String value) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.8),
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

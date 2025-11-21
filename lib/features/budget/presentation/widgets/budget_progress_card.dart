import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../domain/entities/budget_alert_level.dart';
import '../../domain/entities/budget_status.dart';

class BudgetProgressCard extends StatelessWidget {
  final BudgetStatus budgetStatus;
  final VoidCallback? onTap;

  const BudgetProgressCard({
    Key? key,
    required this.budgetStatus,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final alertColor = _getAlertColor(budgetStatus.alertLevel);
    final progressPercentage = budgetStatus.percentage.clamp(0.0, 1.0);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(AppSpacing.lg.w),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              alertColor.withValues(alpha:0.1),
              alertColor.withValues(alpha:0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: alertColor.withValues(alpha:0.3),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: alertColor.withValues(alpha:0.1),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header con título y nivel de alerta
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.account_balance_wallet_rounded,
                      color: alertColor,
                      size: 24.sp,
                    ),
                    SizedBox(width: AppSpacing.sm.w),
                    Text(
                      'Presupuesto Mensual',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimaryLight,
                      ),
                    ),
                  ],
                ),
                _buildAlertBadge(budgetStatus.alertLevel, isDark),
              ],
            ),

            SizedBox(height: AppSpacing.lg.h),

            // Montos
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildAmountColumn(
                  label: 'Gastado',
                  amount: budgetStatus.spent,
                  color: alertColor,
                  isDark: isDark,
                ),
                Container(
                  width: 1,
                  height: 40.h,
                  color: (isDark ? AppColors.grey700 : AppColors.grey300)
                      .withValues(alpha:0.5),
                ),
                _buildAmountColumn(
                  label: 'Presupuesto',
                  amount: budgetStatus.budget.amount,
                  color: isDark ? AppColors.grey400 : AppColors.grey700,
                  isDark: isDark,
                ),
                Container(
                  width: 1,
                  height: 40.h,
                  color: (isDark ? AppColors.grey700 : AppColors.grey300)
                      .withValues(alpha:0.5),
                ),
                _buildAmountColumn(
                  label: budgetStatus.remaining > 0 ? 'Restante' : 'Excedido',
                  amount: budgetStatus.remaining.abs(),
                  color: budgetStatus.remaining > 0
                      ? AppColors.success
                      : AppColors.error,
                  isDark: isDark,
                ),
              ],
            ),

            SizedBox(height: AppSpacing.lg.h),

            // Barra de progreso
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${budgetStatus.percentageDisplay.toStringAsFixed(1)}% usado',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: alertColor,
                      ),
                    ),
                    Text(
                      '${budgetStatus.daysRemaining} días restantes',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: AppSpacing.sm.h),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10.r),
                  child: SizedBox(
                    height: 12.h,
                    child: LinearProgressIndicator(
                      value: progressPercentage,
                      backgroundColor: isDark
                          ? AppColors.grey800.withValues(alpha:0.3)
                          : AppColors.grey200,
                      valueColor: AlwaysStoppedAnimation<Color>(alertColor),
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: AppSpacing.md.h),

            // Mensaje de estado
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.md.w,
                vertical: AppSpacing.sm.h,
              ),
              decoration: BoxDecoration(
                color: alertColor.withValues(alpha:0.1),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: alertColor.withValues(alpha:0.2),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _getAlertIcon(budgetStatus.alertLevel),
                    color: alertColor,
                    size: 16.sp,
                  ),
                  SizedBox(width: AppSpacing.sm.w),
                  Expanded(
                    child: Text(
                      budgetStatus.statusMessage,
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: alertColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: AppSpacing.md.h),

            // Información adicional
            Row(
              children: [
                Expanded(
                  child: _buildInfoChip(
                    icon: Icons.trending_up,
                    label: 'Promedio diario',
                    value: '\$${budgetStatus.dailyAverage.toStringAsFixed(2)}',
                    isDark: isDark,
                  ),
                ),
                SizedBox(width: AppSpacing.sm.w),
                Expanded(
                  child: _buildInfoChip(
                    icon: Icons.recommend,
                    label: 'Recomendado/día',
                    value:
                        '\$${budgetStatus.recommendedDailySpending.toStringAsFixed(2)}',
                    isDark: isDark,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAmountColumn({
    required String label,
    required double amount,
    required Color color,
    required bool isDark,
  }) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11.sp,
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            '\$${amount.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertBadge(BudgetAlertLevel level, bool isDark) {
    final color = _getAlertColor(level);
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.sm.w,
        vertical: 4.h,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha:0.15),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: color.withValues(alpha:0.3)),
      ),
      child: Text(
        level.label,
        style: TextStyle(
          fontSize: 11.sp,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    required String value,
    required bool isDark,
  }) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.sm.w),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.grey800.withValues(alpha:0.3)
            : AppColors.grey100.withValues(alpha:0.5),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 14.sp,
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
              SizedBox(width: 4.w),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 10.sp,
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: 4.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.bold,
              color: isDark
                  ? AppColors.textPrimaryDark
                  : AppColors.textPrimaryLight,
            ),
          ),
        ],
      ),
    );
  }

  Color _getAlertColor(BudgetAlertLevel level) {
    switch (level) {
      case BudgetAlertLevel.safe:
        return AppColors.success;
      case BudgetAlertLevel.info:
        return AppColors.info;
      case BudgetAlertLevel.warning:
        return AppColors.warning;
      case BudgetAlertLevel.critical:
        return const Color(0xFFFF6B35); // Naranja más intenso
      case BudgetAlertLevel.exceeded:
        return AppColors.error;
    }
  }

  IconData _getAlertIcon(BudgetAlertLevel level) {
    switch (level) {
      case BudgetAlertLevel.safe:
        return Icons.check_circle;
      case BudgetAlertLevel.info:
        return Icons.info;
      case BudgetAlertLevel.warning:
        return Icons.warning_amber;
      case BudgetAlertLevel.critical:
        return Icons.warning;
      case BudgetAlertLevel.exceeded:
        return Icons.error;
    }
  }
}

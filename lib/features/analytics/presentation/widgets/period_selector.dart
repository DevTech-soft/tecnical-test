import 'package:flutter/material.dart';
import '../pages/analytics_page.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';

class PeriodSelector extends StatelessWidget {
  final AnalyticsPeriod selectedPeriod;
  final ValueChanged<AnalyticsPeriod> onPeriodChanged;

  const PeriodSelector({
    super.key,
    required this.selectedPeriod,
    required this.onPeriodChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.xs),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.grey100,
        borderRadius: AppSpacing.borderRadiusMD,
      ),
      child: Row(
        children: [
          _buildPeriodButton(
            context,
            'Semana',
            AnalyticsPeriod.week,
            selectedPeriod == AnalyticsPeriod.week,
          ),
          AppSpacing.horizontalSpaceXS,
          _buildPeriodButton(
            context,
            'Mes',
            AnalyticsPeriod.month,
            selectedPeriod == AnalyticsPeriod.month,
          ),
          AppSpacing.horizontalSpaceXS,
          _buildPeriodButton(
            context,
            'Año',
            AnalyticsPeriod.year,
            selectedPeriod == AnalyticsPeriod.year,
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodButton(
    BuildContext context,
    String label,
    AnalyticsPeriod period,
    bool isSelected,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onPeriodChanged(period),
          borderRadius: AppSpacing.borderRadiusSM,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primary
                  : Colors.transparent,
              borderRadius: AppSpacing.borderRadiusSM,
            ),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: isSelected
                        ? Colors.white
                        : (isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight),
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  ),
            ),
          ),
        ),
      ),
    );
  }
}

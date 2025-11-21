import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/date_formatter.dart';

class DateFilterSelector extends StatelessWidget {
  final DateTime selectedDate;
  final VoidCallback onTap;
  final bool isScrolled;

  const DateFilterSelector({
    super.key,
    required this.selectedDate,
    required this.onTap,
    this.isScrolled = false,
  });

  String _getDateLabel() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    final selectedDay = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
    );

    if (selectedDay == today) {
      return 'Hoy';
    } else if (selectedDay == yesterday) {
      return 'Ayer';
    } else if (now.difference(selectedDate).inDays < 7) {
      return DateFormatter.formatDateShort(selectedDate);
    } else {
      return DateFormatter.formatDateShort(selectedDate);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppSpacing.borderRadiusMD,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
         
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.calendar_today,
                size: AppSpacing.iconSM,
                color: AppColors.primary,
              ),
              AppSpacing.horizontalSpaceSM,
              Text(
                _getDateLabel(),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimaryLight,
                      fontWeight: FontWeight.w600,
                    ),
              ),
              AppSpacing.horizontalSpaceXS,
              Icon(
                Icons.arrow_drop_down,
                size: AppSpacing.iconMD,
                color: AppColors.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

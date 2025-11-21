import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

class ShimmerLoading extends StatelessWidget {
  final Widget child;

  const ShimmerLoading({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Shimmer.fromColors(
      baseColor: isDark ? AppColors.grey800 : AppColors.grey300,
      highlightColor: isDark ? AppColors.grey700 : AppColors.grey100,
      child: child,
    );
  }
}

class ShimmerBox extends StatelessWidget {
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;

  const ShimmerBox({
    super.key,
    this.width,
    this.height,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return ShimmerLoading(
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: borderRadius ?? AppSpacing.borderRadiusMD,
        ),
      ),
    );
  }
}

class ShimmerExpenseCard extends StatelessWidget {
  const ShimmerExpenseCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      padding: AppSpacing.paddingMD,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: AppSpacing.borderRadiusLG,
      ),
      child: Row(
        children: [
          ShimmerBox(
            width: AppSpacing.iconXL,
            height: AppSpacing.iconXL,
            borderRadius: AppSpacing.borderRadiusFull,
          ),
          AppSpacing.horizontalSpaceMD,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const ShimmerBox(width: 120, height: 20),
                AppSpacing.verticalSpaceXS,
                const ShimmerBox(width: 80, height: 14),
              ],
            ),
          ),
          const ShimmerBox(width: 80, height: 24),
        ],
      ),
    );
  }
}

class ShimmerExpenseList extends StatelessWidget {
  final int itemCount;

  const ShimmerExpenseList({
    super.key,
    this.itemCount = 5,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: itemCount,
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      itemBuilder: (context, index) => const ShimmerExpenseCard(),
    );
  }
}

class ShimmerSummaryCard extends StatelessWidget {
  const ShimmerSummaryCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(AppSpacing.md),
      padding: AppSpacing.paddingLG,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: AppSpacing.borderRadiusLG,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ShimmerBox(width: 100, height: 16),
          AppSpacing.verticalSpaceSM,
          const ShimmerBox(width: 180, height: 36),
          AppSpacing.verticalSpaceLG,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const ShimmerBox(width: 60, height: 12),
                    AppSpacing.verticalSpaceXS,
                    const ShimmerBox(width: 80, height: 20),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const ShimmerBox(width: 60, height: 12),
                    AppSpacing.verticalSpaceXS,
                    const ShimmerBox(width: 80, height: 20),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

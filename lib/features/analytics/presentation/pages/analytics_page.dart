import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../expenses/presentation/blocs/expenses_bloc.dart';
import '../../../expenses/domain/entities/expense.dart';
import '../widgets/trend_chart.dart';
import '../widgets/category_breakdown.dart';
import '../widgets/period_selector.dart';
import '../widgets/analytics_summary_card.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../injection_container.dart';

enum AnalyticsPeriod { week, month, year }

class AnalyticsPage extends StatefulWidget {
  const AnalyticsPage({super.key});

  @override
  State<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage> {
  late final ExpensesBloc _expensesBloc;
  AnalyticsPeriod _selectedPeriod = AnalyticsPeriod.month;

  @override
  void initState() {
    super.initState();
    _expensesBloc = sl<ExpensesBloc>()..add(LoadExpensesEvent());
  }

  @override
  void dispose() {
    _expensesBloc.close();
    super.dispose();
  }

  List<Expense> _filterExpensesByPeriod(List<Expense> expenses) {
    final now = DateTime.now();
    DateTime startDate;

    switch (_selectedPeriod) {
      case AnalyticsPeriod.week:
        startDate = now.subtract(const Duration(days: 7));
        break;
      case AnalyticsPeriod.month:
        startDate = DateTime(now.year, now.month, 1);
        break;
      case AnalyticsPeriod.year:
        startDate = DateTime(now.year, 1, 1);
        break;
    }

    return expenses.where((expense) => expense.date.isAfter(startDate)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocProvider.value(
      value: _expensesBloc,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: CustomScrollView(
          slivers: [
            // AppBar
            SliverAppBar(
              expandedHeight: 100.h,
              floating: true,
              pinned: true,
              elevation: 0,
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              flexibleSpace: FlexibleSpaceBar(
                titlePadding: const EdgeInsets.only(
                  left: AppSpacing.md,
                  bottom: AppSpacing.md,
                ),
                title: Text(
                  'Análisis',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimaryLight,
                      ),
                ),
                background: Container(
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient.scale(0.1),
                  ),
                ),
              ),
            ),

            // Period Selector
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: PeriodSelector(
                  selectedPeriod: _selectedPeriod,
                  onPeriodChanged: (period) {
                    setState(() {
                      _selectedPeriod = period;
                    });
                  },
                ),
              ),
            ),

            // Content
            BlocBuilder<ExpensesBloc, ExpensesState>(
              builder: (context, state) {
                if (state is ExpensesLoading) {
                  return const SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                if (state is ExpensesLoaded) {
                  final filteredExpenses = _filterExpensesByPeriod(state.expenses);

                  if (filteredExpenses.isEmpty) {
                    return SliverFillRemaining(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.analytics_outlined,
                              size: 80,
                              color: AppColors.primary.withValues(alpha:  0.3),
                            ),
                            AppSpacing.verticalSpaceLG,
                            Text(
                              'Sin datos para analizar',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            AppSpacing.verticalSpaceSM,
                            Text(
                              'Agrega gastos para ver tus estadísticas',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: isDark
                                        ? AppColors.textSecondaryDark
                                        : AppColors.textSecondaryLight,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return SliverList(
                    delegate: SliverChildListDelegate([
                      // Summary Cards
                      AnalyticsSummaryCard(
                        expenses: filteredExpenses,
                        period: _selectedPeriod,
                      ),

                      AppSpacing.verticalSpaceMD,

                      // Trend Chart
                      TrendChart(
                        expenses: filteredExpenses,
                        period: _selectedPeriod,
                      ),

                      AppSpacing.verticalSpaceMD,

                      // Category Breakdown
                      CategoryBreakdown(expenses: filteredExpenses),

                      AppSpacing.verticalSpaceXL,
                    ]),
                  );
                }

                if (state is ExpensesError) {
                  return SliverFillRemaining(
                    child: Center(
                      child: Text('Error: ${state.userMessage}'),
                    ),
                  );
                }

                return const SliverFillRemaining(child: SizedBox.shrink());
              },
            ),
          ],
        ),
      ),
    );
  }
}

// Extension to scale gradient opacity
extension on LinearGradient {
  LinearGradient scale(double factor) {
    return LinearGradient(
      colors: colors.map((c) => c.withValues(alpha:  factor)).toList(),
      begin: begin,
      end: end,
    );
  }
}

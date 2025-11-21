import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../injection_container.dart';
import '../bloc/budget_bloc.dart';
import '../bloc/budget_event.dart';
import '../bloc/budget_state.dart';
import '../widgets/budget_progress_card.dart';
import '../widgets/no_budget_card.dart';
import 'budget_settings_page.dart';

class BudgetPage extends StatefulWidget {
  const BudgetPage({super.key});

  @override
  State<BudgetPage> createState() => _BudgetPageState();
}

class _BudgetPageState extends State<BudgetPage> {
  late final BudgetBloc _budgetBloc;

  @override
  void initState() {
    super.initState();
    _budgetBloc = sl<BudgetBloc>()..add(const LoadCurrentBudgetEvent());
  }

  @override
  void dispose() {
    _budgetBloc.close();
    super.dispose();
  }

  void _navigateToBudgetSettings() async {
    // Obtener el presupuesto actual si existe
    final currentBudget = _budgetBloc.state is BudgetLoaded
        ? (_budgetBloc.state as BudgetLoaded).budget
        : null;

    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: _budgetBloc,
          child: BudgetSettingsPage(existingBudget: currentBudget),
        ),
      ),
    );

    // Si se creó/actualizó el presupuesto, recargar
    if (result == true) {
      _budgetBloc.add(const LoadCurrentBudgetEvent());
      _budgetBloc.add(const CalculateBudgetStatusEvent());
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocProvider.value(
      value: _budgetBloc,
      child: Scaffold(
        backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
        body: CustomScrollView(
          slivers: [
            // App Bar
            SliverAppBar(
              expandedHeight: 100.h,
              floating: true,
              pinned: true,
              elevation: 0,
               backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              flexibleSpace: FlexibleSpaceBar(
                centerTitle: false,
                titlePadding: EdgeInsets.only(
                  left: AppSpacing.lg.w,
                  bottom: AppSpacing.md.h,
                ),
                title: Text(
                  'Presupuestos',
                  style: TextStyle(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimaryLight,
                  ),
                ),
              ),
            ),

            // Contenido
            SliverPadding(
              padding: EdgeInsets.all(AppSpacing.lg.w),
              sliver: SliverToBoxAdapter(
                child: BlocBuilder<BudgetBloc, BudgetState>(
                  builder: (context, state) {
                    if (state is BudgetLoading) {
                      return Center(
                        child: Padding(
                          padding: EdgeInsets.all(AppSpacing.xxxl.h),
                          child: const CircularProgressIndicator(),
                        ),
                      );
                    }

                    if (state is BudgetLoaded) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Widget principal de presupuesto
                          if (state.hasBudget && state.status != null)
                            BudgetProgressCard(
                              budgetStatus: state.status!,
                              onTap: _navigateToBudgetSettings,
                            )
                          else
                            NoBudgetCard(
                              onCreateBudget: _navigateToBudgetSettings,
                            ),

                          SizedBox(height: AppSpacing.xl.h),

                          // Información adicional
                          if (state.hasBudget && state.status != null) ...[
                            _buildInfoSection(
                              title: 'Consejos de Ahorro',
                              icon: Icons.lightbulb_outline,
                              isDark: isDark,
                              children: [
                                _buildTipCard(
                                  icon: Icons.trending_down,
                                  title: 'Reduce gastos innecesarios',
                                  description:
                                      'Revisa tus gastos y elimina aquellos que no son esenciales',
                                  color: AppColors.info,
                                  isDark: isDark,
                                ),
                                SizedBox(height: AppSpacing.sm.h),
                                _buildTipCard(
                                  icon: Icons.savings_outlined,
                                  title: 'Ahorra un porcentaje fijo',
                                  description:
                                      'Destina al menos el 20% de tus ingresos al ahorro',
                                  color: AppColors.success,
                                  isDark: isDark,
                                ),
                                SizedBox(height: AppSpacing.sm.h),
                                _buildTipCard(
                                  icon: Icons.compare_arrows,
                                  title: 'Compara antes de comprar',
                                  description:
                                      'Busca las mejores ofertas antes de hacer una compra',
                                  color: AppColors.warning,
                                  isDark: isDark,
                                ),
                              ],
                            ),
                          ],
                        ],
                      );
                    }

                    if (state is BudgetError) {
                      return Center(
                        child: Padding(
                          padding: EdgeInsets.all(AppSpacing.xl.h),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.error_outline,
                                size: 64.sp,
                                color: AppColors.error,
                              ),
                              SizedBox(height: AppSpacing.md.h),
                              Text(
                                'Error al cargar presupuesto',
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w600,
                                  color: isDark
                                      ? AppColors.textPrimaryDark
                                      : AppColors.textPrimaryLight,
                                ),
                              ),
                              SizedBox(height: AppSpacing.sm.h),
                              Text(
                                state.userMessage,
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: isDark
                                      ? AppColors.textSecondaryDark
                                      : AppColors.textSecondaryLight,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: AppSpacing.lg.h),
                              ElevatedButton(
                                onPressed: () {
                                  _budgetBloc.add(const LoadCurrentBudgetEvent());
                                },
                                child: const Text('Reintentar'),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    return const SizedBox.shrink();
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection({
    required String title,
    required IconData icon,
    required bool isDark,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              color: AppColors.primary,
              size: 24.sp,
            ),
            SizedBox(width: AppSpacing.sm.w),
            Text(
              title,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimaryLight,
              ),
            ),
          ],
        ),
        SizedBox(height: AppSpacing.md.h),
        ...children,
      ],
    );
  }

  Widget _buildTipCard({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
    required bool isDark,
  }) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.md.w),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(AppSpacing.sm.w),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(
              icon,
              color: color,
              size: 24.sp,
            ),
          ),
          SizedBox(width: AppSpacing.md.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

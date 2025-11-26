import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../injection_container.dart';
import '../../domain/entities/budget_alert_level.dart';
import '../../domain/entities/budget_status.dart';
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
                            // Estadísticas rápidas
                            _buildQuickStats(state.status!, isDark),
                            SizedBox(height: AppSpacing.xl.h),

                            // Consejos dinámicos de ahorro
                            _buildInfoSection(
                              title: 'Consejos Personalizados',
                              icon: Icons.lightbulb_outline,
                              isDark: isDark,
                              children: _buildDynamicTips(state.status!, isDark),
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
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(AppSpacing.md.w),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  color.withValues(alpha: 0.3),
                  color.withValues(alpha: 0.15),
                ],
              ),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(
              icon,
              color: color,
              size: 28.sp,
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
                    fontSize: 15.sp,
                    fontWeight: FontWeight.bold,
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimaryLight,
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats(BudgetStatus status, bool isDark) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.lg.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withValues(alpha: 0.08),
            AppColors.secondary.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.15),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.analytics_outlined,
                color: AppColors.primary,
                size: 24.sp,
              ),
              SizedBox(width: AppSpacing.sm.w),
              Text(
                'Análisis Rápido',
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
          SizedBox(height: AppSpacing.lg.h),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  icon: Icons.calendar_today,
                  label: 'Días transcurridos',
                  value: '${DateTime.now().day} días',
                  color: AppColors.info,
                  isDark: isDark,
                ),
              ),
              SizedBox(width: AppSpacing.sm.w),
              Expanded(
                child: _buildStatCard(
                  icon: Icons.speed,
                  label: 'Ritmo de gasto',
                  value: _getSpendingPaceLabel(status),
                  color: _getSpendingPaceColor(status),
                  isDark: isDark,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.sm.h),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  icon: Icons.trending_up,
                  label: 'Gasto diario',
                  value: '\$${status.dailyAverage.toStringAsFixed(0)}',
                  color: AppColors.warning,
                  isDark: isDark,
                ),
              ),
              SizedBox(width: AppSpacing.sm.w),
              Expanded(
                child: _buildStatCard(
                  icon: Icons.track_changes,
                  label: 'Meta diaria',
                  value: '\$${status.recommendedDailySpending.toStringAsFixed(0)}',
                  color: AppColors.success,
                  isDark: isDark,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required bool isDark,
  }) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.md.w),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.grey800.withValues(alpha: 0.4)
            : Colors.white.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: color,
            size: 20.sp,
          ),
          SizedBox(height: AppSpacing.sm.h),
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
            value,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildDynamicTips(BudgetStatus status, bool isDark) {
    final tips = <Widget>[];

    // Consejos basados en el nivel de alerta
    if (status.alertLevel == BudgetAlertLevel.safe) {
      tips.add(_buildTipCard(
        icon: Icons.check_circle_outline,
        title: '¡Excelente control!',
        description: 'Mantienes un buen ritmo de gastos. Considera aumentar tu ahorro mensual.',
        color: AppColors.success,
        isDark: isDark,
      ));
    } else if (status.alertLevel == BudgetAlertLevel.warning ||
               status.alertLevel == BudgetAlertLevel.critical) {
      tips.add(_buildTipCard(
        icon: Icons.warning_amber_rounded,
        title: 'Modera tus gastos',
        description: 'Estás gastando más rápido de lo planeado. Revisa tus gastos recientes y evita compras innecesarias.',
        color: AppColors.warning,
        isDark: isDark,
      ));
    } else if (status.alertLevel == BudgetAlertLevel.exceeded) {
      tips.add(_buildTipCard(
        icon: Icons.priority_high,
        title: 'Presupuesto excedido',
        description: 'Has superado tu límite. Considera ajustar tu presupuesto o reducir gastos significativamente.',
        color: AppColors.error,
        isDark: isDark,
      ));
    }

    tips.add(SizedBox(height: AppSpacing.sm.h));

    // Consejo sobre gasto diario
    if (status.dailyAverage > status.recommendedDailySpending) {
      tips.add(_buildTipCard(
        icon: Icons.insights,
        title: 'Ajusta tu ritmo diario',
        description: 'Tu gasto diario promedio (\$${status.dailyAverage.toStringAsFixed(0)}) supera lo recomendado (\$${status.recommendedDailySpending.toStringAsFixed(0)}). Intenta reducirlo.',
        color: AppColors.info,
        isDark: isDark,
      ));
      tips.add(SizedBox(height: AppSpacing.sm.h));
    }

    // Consejos generales de ahorro
    tips.add(_buildTipCard(
      icon: Icons.savings_outlined,
      title: 'Regla del 50/30/20',
      description: '50% necesidades, 30% deseos, 20% ahorros. Una fórmula probada para finanzas saludables.',
      color: const Color(0xFF7E57C2),
      isDark: isDark,
    ));

    tips.add(SizedBox(height: AppSpacing.sm.h));

    tips.add(_buildTipCard(
      icon: Icons.compare_arrows,
      title: 'Compara antes de comprar',
      description: 'Busca ofertas y descuentos. Usar comparadores puede ahorrarte hasta un 30%.',
      color: const Color(0xFF26A69A),
      isDark: isDark,
    ));

    return tips;
  }

  String _getSpendingPaceLabel(BudgetStatus status) {
    final daysInMonth = DateTime(
      DateTime.now().year,
      DateTime.now().month + 1,
      0,
    ).day;
    final daysElapsed = DateTime.now().day;
    final expectedPercentage = (daysElapsed / daysInMonth) * 100;
    final actualPercentage = status.percentageDisplay;

    if (actualPercentage <= expectedPercentage - 10) {
      return 'Bajo';
    } else if (actualPercentage <= expectedPercentage + 10) {
      return 'Normal';
    } else {
      return 'Alto';
    }
  }

  Color _getSpendingPaceColor(BudgetStatus status) {
    final pace = _getSpendingPaceLabel(status);
    switch (pace) {
      case 'Bajo':
        return AppColors.success;
      case 'Normal':
        return AppColors.info;
      case 'Alto':
        return AppColors.error;
      default:
        return AppColors.info;
    }
  }
}

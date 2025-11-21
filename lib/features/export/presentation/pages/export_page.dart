import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/error_display.dart';
import '../../../../injection_container.dart';
import '../../../expenses/domain/entities/category.dart';
import '../../../expenses/presentation/blocs/expenses_bloc.dart';
import '../bloc/export_bloc.dart';

class ExportPage extends StatelessWidget {
  const ExportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<ExportBloc>(),
      child: const _ExportPageContent(),
    );
  }
}

class _ExportPageContent extends StatefulWidget {
  const _ExportPageContent();

  @override
  State<_ExportPageContent> createState() => _ExportPageContentState();
}

class _ExportPageContentState extends State<_ExportPageContent> {
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    // Por defecto, exportar el mes actual
    final now = DateTime.now();
    _startDate = DateTime(now.year, now.month, 1);
    _endDate = DateTime(now.year, now.month + 1, 0);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Exportar Datos'),
        elevation: 0,
      ),
      body: BlocListener<ExportBloc, ExportState>(
        listener: (context, state) {
          if (state is ExportSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.success,
                action: SnackBarAction(
                  label: 'Compartir',
                  textColor: Colors.white,
                  onPressed: () {
                    context.read<ExportBloc>().add(
                          ShareFileEvent(filePath: state.filePath),
                        );
                  },
                ),
              ),
            );
          } else if (state is ShareSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.success,
              ),
            );
          } else if (state is ExportError) {
            ErrorSnackBar.show(context, state.failure);
          }
        },
        child: SingleChildScrollView(
          padding: EdgeInsets.all(AppSpacing.lg.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Información
              Container(
                padding: EdgeInsets.all(AppSpacing.md.w),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.surfaceDark
                      : AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: theme.colorScheme.primary.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: theme.colorScheme.primary,
                      size: 24.sp,
                    ),
                    SizedBox(width: AppSpacing.sm.w),
                    Expanded(
                      child: Text(
                        'Exporta tus gastos a CSV o PDF para respaldarlos o compartirlos',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: AppSpacing.lg.h),

              // Selector de período
              Text(
                'Período a Exportar',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: AppSpacing.md.h),

              Row(
                children: [
                  Expanded(
                    child: _DateSelector(
                      label: 'Fecha Inicio',
                      date: _startDate,
                      onDateSelected: (date) {
                        setState(() => _startDate = date);
                      },
                    ),
                  ),
                  SizedBox(width: AppSpacing.md.w),
                  Expanded(
                    child: _DateSelector(
                      label: 'Fecha Fin',
                      date: _endDate,
                      onDateSelected: (date) {
                        setState(() => _endDate = date);
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: AppSpacing.lg.h),

              // Botones de exportación
              Text(
                'Formato de Exportación',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: AppSpacing.md.h),

              BlocBuilder<ExportBloc, ExportState>(
                builder: (context, exportState) {
                  final isLoading = exportState is ExportLoading;

                  return Column(
                    children: [
                      // Exportar a CSV
                      _ExportButton(
                        icon: Icons.table_chart,
                        title: 'Exportar a CSV',
                        subtitle: 'Archivo de valores separados por comas',
                        color: Colors.green,
                        isLoading: isLoading,
                        onPressed: () => _exportToCsv(context),
                      ),
                      SizedBox(height: AppSpacing.md.h),

                      // Exportar a PDF
                      _ExportButton(
                        icon: Icons.picture_as_pdf,
                        title: 'Exportar a PDF',
                        subtitle: 'Reporte detallado en formato PDF',
                        color: Colors.red,
                        isLoading: isLoading,
                        onPressed: () => _exportToPdf(context),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _exportToCsv(BuildContext context) {
    final expensesState = context.read<ExpensesBloc>().state;
    if (expensesState is! ExpensesLoaded) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No hay gastos para exportar')),
      );
      return;
    }

    // Filtrar gastos por fecha
    final expenses = expensesState.expenses.where((expense) {
      return expense.date.isAfter(_startDate!.subtract(const Duration(days: 1))) &&
          expense.date.isBefore(_endDate!.add(const Duration(days: 1)));
    }).toList();

    if (expenses.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No hay gastos en el período seleccionado')),
      );
      return;
    }

    // Obtener mapa de categorías
    final categories = _getCategoriesMap();

    context.read<ExportBloc>().add(
          ExportToCsvEvent(
            expenses: expenses,
            categories: categories,
          ),
        );
  }

  void _exportToPdf(BuildContext context) {
    final expensesState = context.read<ExpensesBloc>().state;
    if (expensesState is! ExpensesLoaded) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No hay gastos para exportar')),
      );
      return;
    }

    // Filtrar gastos por fecha
    final expenses = expensesState.expenses.where((expense) {
      return expense.date.isAfter(_startDate!.subtract(const Duration(days: 1))) &&
          expense.date.isBefore(_endDate!.add(const Duration(days: 1)));
    }).toList();

    if (expenses.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No hay gastos en el período seleccionado')),
      );
      return;
    }

    // Obtener mapa de categorías
    final categories = _getCategoriesMap();

    context.read<ExportBloc>().add(
          ExportToPdfEvent(
            expenses: expenses,
            categories: categories,
            startDate: _startDate!,
            endDate: _endDate!,
          ),
        );
  }

  Map<String, Category> _getCategoriesMap() {
    return {
      for (final category in CategoryHelper.defaultCategories) category.id: category,
    };
  }
}

class _DateSelector extends StatelessWidget {
  final String label;
  final DateTime? date;
  final ValueChanged<DateTime> onDateSelected;

  const _DateSelector({
    required this.label,
    required this.date,
    required this.onDateSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('dd/MM/yyyy');

    return InkWell(
      onTap: () async {
        final selectedDate = await showDatePicker(
          context: context,
          initialDate: date ?? DateTime.now(),
          firstDate: DateTime(2020),
          lastDate: DateTime.now(),
        );

        if (selectedDate != null) {
          onDateSelected(selectedDate);
        }
      },
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.all(AppSpacing.md.w),
        decoration: BoxDecoration(
          border: Border.all(color: theme.colorScheme.outline),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            SizedBox(height: 4.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  date != null ? dateFormat.format(date!) : 'Seleccionar',
                  style: theme.textTheme.bodyLarge,
                ),
                Icon(
                  Icons.calendar_today,
                  size: 20.sp,
                  color: theme.colorScheme.primary,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ExportButton extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final bool isLoading;
  final VoidCallback onPressed;

  const _ExportButton({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.isLoading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: InkWell(
        onTap: isLoading ? null : onPressed,
        borderRadius: BorderRadius.circular(12.r),
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.md.w),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.r),
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
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
              if (isLoading)
                SizedBox(
                  width: 24.w,
                  height: 24.h,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                )
              else
                Icon(
                  Icons.arrow_forward_ios,
                  size: 20.sp,
                  color: theme.colorScheme.onSurface.withOpacity(0.4),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

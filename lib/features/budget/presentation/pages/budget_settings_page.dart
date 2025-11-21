import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../injection_container.dart';
import '../../domain/entities/budget.dart';
import '../bloc/budget_bloc.dart';
import '../bloc/budget_event.dart';
import '../bloc/budget_state.dart';

class BudgetSettingsPage extends StatefulWidget {
  final Budget? existingBudget;

  const BudgetSettingsPage({
    Key? key,
    this.existingBudget,
  }) : super(key: key);

  @override
  State<BudgetSettingsPage> createState() => _BudgetSettingsPageState();
}

class _BudgetSettingsPageState extends State<BudgetSettingsPage> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  late int _selectedMonth;
  late int _selectedYear;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _isEditing = widget.existingBudget != null;

    if (_isEditing) {
      _amountController.text =
          widget.existingBudget!.amount.toStringAsFixed(2);
      _selectedMonth = widget.existingBudget!.month;
      _selectedYear = widget.existingBudget!.year;
    } else {
      final now = DateTime.now();
      _selectedMonth = now.month;
      _selectedYear = now.year;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            _isEditing ? 'Editar Presupuesto' : 'Crear Presupuesto',
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      body: BlocListener<BudgetBloc, BudgetState>(
        listener: (context, state) {
          if (state is BudgetOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.success,
              ),
            );
            Navigator.pop(context, true); // Retorna true para indicar éxito
          } else if (state is BudgetError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.userMessage),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        child: SingleChildScrollView(
            padding: EdgeInsets.all(AppSpacing.lg.w),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Descripción
                  Container(
                    padding: EdgeInsets.all(AppSpacing.md.w),
                    decoration: BoxDecoration(
                      color: AppColors.info.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(
                        color: AppColors.info.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: AppColors.info,
                          size: 24.sp,
                        ),
                        SizedBox(width: AppSpacing.md.w),
                        Expanded(
                          child: Text(
                            'Define cuánto deseas gastar este mes. Te avisaremos cuando te acerques al límite.',
                            style: TextStyle(
                              fontSize: 13.sp,
                              color: AppColors.info,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: AppSpacing.xl.h),

                  // Campo de monto
                  Text(
                    'Monto del Presupuesto',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimaryLight,
                    ),
                  ),
                  SizedBox(height: AppSpacing.sm.h),
                  TextFormField(
                    controller: _amountController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                    ],
                    decoration: InputDecoration(
                      hintText: '0.00',
                      prefixIcon: Icon(
                        Icons.attach_money,
                        color: AppColors.primary,
                      ),
                      filled: true,
                      fillColor: isDark
                          ? AppColors.surfaceDark
                          : AppColors.surfaceLight,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide(
                          color: isDark
                              ? AppColors.grey700
                              : AppColors.grey300,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide(
                          color: AppColors.primary,
                          width: 2,
                        ),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide(color: AppColors.error),
                      ),
                    ),
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimaryLight,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Ingresa un monto';
                      }
                      final amount = double.tryParse(value);
                      if (amount == null || amount <= 0) {
                        return 'El monto debe ser mayor a cero';
                      }
                      return null;
                    },
                  ),

                  SizedBox(height: AppSpacing.xl.h),

                  // Selector de período
                  Text(
                    'Período',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimaryLight,
                    ),
                  ),
                  SizedBox(height: AppSpacing.sm.h),
                  Row(
                    children: [
                      // Mes
                      Expanded(
                        flex: 2,
                        child: _buildPeriodSelector(
                          label: 'Mes',
                          value: _getMonthName(_selectedMonth),
                          onTap: () => _showMonthPicker(context),
                          isDark: isDark,
                        ),
                      ),
                      SizedBox(width: AppSpacing.md.w),
                      // Año
                      Expanded(
                        child: _buildPeriodSelector(
                          label: 'Año',
                          value: _selectedYear.toString(),
                          onTap: () => _showYearPicker(context),
                          isDark: isDark,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: AppSpacing.xl.h),

                  // Información de niveles de alerta
                  _buildAlertInfoSection(isDark),

                  SizedBox(height: AppSpacing.xxxl.h),

                  // Botones
                  BlocBuilder<BudgetBloc, BudgetState>(
                    builder: (context, state) {
                      final isLoading = state is BudgetLoading;

                      return Column(
                        children: [
                          // Botón guardar
                          SizedBox(
                            width: double.infinity,
                            height: 56.h,
                            child: ElevatedButton(
                              onPressed: isLoading ? null : _saveBudget,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16.r),
                                ),
                                elevation: 2,
                              ),
                              child: isLoading
                                  ? SizedBox(
                                      height: 24.h,
                                      width: 24.w,
                                      child: const CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                          Colors.white,
                                        ),
                                      ),
                                    )
                                  : Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          _isEditing ? Icons.save : Icons.add_circle,
                                          size: 24.sp,
                                        ),
                                        SizedBox(width: AppSpacing.sm.w),
                                        Text(
                                          _isEditing
                                              ? 'Guardar Cambios'
                                              : 'Crear Presupuesto',
                                          style: TextStyle(
                                            fontSize: 16.sp,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                            ),
                          ),

                          // Botón eliminar (solo si está editando)
                          if (_isEditing) ...[
                            SizedBox(height: AppSpacing.md.h),
                            TextButton.icon(
                              onPressed: isLoading ? null : _deleteBudget,
                              icon: Icon(
                                Icons.delete_outline,
                                color: AppColors.error,
                                size: 20.sp,
                              ),
                              label: Text(
                                'Eliminar Presupuesto',
                                style: TextStyle(
                                  color: AppColors.error,
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      );
  }

  Widget _buildPeriodSelector({
    required String label,
    required String value,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(AppSpacing.md.w),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isDark ? AppColors.grey700 : AppColors.grey300,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12.sp,
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
            ),
            SizedBox(height: 4.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimaryLight,
                  ),
                ),
                Icon(
                  Icons.arrow_drop_down,
                  color: AppColors.primary,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlertInfoSection(bool isDark) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.md.w),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.surfaceDark.withOpacity(0.5)
            : AppColors.grey50,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Niveles de Alerta',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: isDark
                  ? AppColors.textPrimaryDark
                  : AppColors.textPrimaryLight,
            ),
          ),
          SizedBox(height: AppSpacing.sm.h),
          _buildAlertLevelRow('50% - Información', AppColors.info),
          _buildAlertLevelRow('75% - Advertencia', AppColors.warning),
          _buildAlertLevelRow('90% - Crítico', const Color(0xFFFF6B35)),
          _buildAlertLevelRow('100%+ - Excedido', AppColors.error),
        ],
      ),
    );
  }

  Widget _buildAlertLevelRow(String text, Color color) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        children: [
          Container(
            width: 12.w,
            height: 12.h,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: AppSpacing.sm.w),
          Text(
            text,
            style: TextStyle(
              fontSize: 12.sp,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  void _showMonthPicker(BuildContext context) {
    final months = [
      'Enero',
      'Febrero',
      'Marzo',
      'Abril',
      'Mayo',
      'Junio',
      'Julio',
      'Agosto',
      'Septiembre',
      'Octubre',
      'Noviembre',
      'Diciembre',
    ];

    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        height: 300.h,
        padding: EdgeInsets.all(AppSpacing.md.w),
        child: Column(
          children: [
            Text(
              'Seleccionar Mes',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: AppSpacing.md.h),
            Expanded(
              child: ListView.builder(
                itemCount: months.length,
                itemBuilder: (context, index) {
                  final month = index + 1;
                  final isSelected = month == _selectedMonth;
                  return ListTile(
                    title: Text(months[index]),
                    selected: isSelected,
                    selectedTileColor: AppColors.primary.withOpacity(0.1),
                    onTap: () {
                      setState(() => _selectedMonth = month);
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showYearPicker(BuildContext context) {
    final currentYear = DateTime.now().year;
    final years = List.generate(5, (index) => currentYear - 2 + index);

    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        height: 300.h,
        padding: EdgeInsets.all(AppSpacing.md.w),
        child: Column(
          children: [
            Text(
              'Seleccionar Año',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: AppSpacing.md.h),
            Expanded(
              child: ListView.builder(
                itemCount: years.length,
                itemBuilder: (context, index) {
                  final year = years[index];
                  final isSelected = year == _selectedYear;
                  return ListTile(
                    title: Text(year.toString()),
                    selected: isSelected,
                    selectedTileColor: AppColors.primary.withOpacity(0.1),
                    onTap: () {
                      setState(() => _selectedYear = year);
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getMonthName(int month) {
    const months = [
      'Enero',
      'Febrero',
      'Marzo',
      'Abril',
      'Mayo',
      'Junio',
      'Julio',
      'Agosto',
      'Septiembre',
      'Octubre',
      'Noviembre',
      'Diciembre',
    ];
    return months[month - 1];
  }

  void _saveBudget() {
    if (_formKey.currentState!.validate()) {
      final amount = double.parse(_amountController.text);

      if (_isEditing) {
        context.read<BudgetBloc>().add(
              UpdateBudgetEvent(
                budgetId: widget.existingBudget!.id,
                amount: amount,
                month: _selectedMonth,
                year: _selectedYear,
              ),
            );
      } else {
        context.read<BudgetBloc>().add(
              CreateBudgetEvent(
                amount: amount, 
                month: _selectedMonth,
                year: _selectedYear,
              ),
            );
      }
    }
  }

  void _deleteBudget() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Presupuesto'),
        content: const Text(
          '¿Estás seguro de que deseas eliminar este presupuesto? Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Cerrar diálogo
              context.read<BudgetBloc>().add(
                    DeleteBudgetEvent(budgetId: widget.existingBudget!.id),
                  );
            },
            child: Text(
              'Eliminar',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../blocs/expenses_bloc.dart';
import '../../domain/entities/expense.dart';
import '../../domain/entities/category.dart';
import '../widgets/category_chip.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../accounts/presentation/bloc/account_bloc.dart';
import '../../../accounts/presentation/bloc/account_state.dart';
import '../../../accounts/domain/entities/account.dart';

class AddExpensePage extends StatefulWidget {
  const AddExpensePage({super.key});
  @override
  State<AddExpensePage> createState() => _AddExpensePageState();
}

class _AddExpensePageState extends State<AddExpensePage> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  ExpenseCategory _selectedCategory = CategoryHelper.food;
  DateTime _selectedDate = DateTime.now();
  Account? _selectedAccount;

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedAccount == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor selecciona una cuenta'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final id = const Uuid().v4();
    final amount = double.tryParse(_amountController.text) ?? 0.0;
    final expense = Expense(
      id: id,
      amount: amount,
      categoryId: _selectedCategory.id,
      accountId: _selectedAccount!.id,
      note: _noteController.text.isEmpty ? null : _noteController.text,
      date: _selectedDate,
    );

    context.read<ExpensesBloc>().add(AddExpenseEvent(expense));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Gasto agregado correctamente'),
        duration: Duration(seconds: 2),
      ),
    );

    Navigator.pop(context);
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      final TimeOfDay? time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDate),
      );

      if (time != null) {
        setState(() {
          _selectedDate = DateTime(
            picked.year,
            picked.month,
            picked.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Agregar Gasto'),
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _save,
            child: Text(
              'Guardar',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: AppSpacing.paddingMD,
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Amount Input Card
              Container(
                padding: AppSpacing.paddingLG,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient.scale(0.15),
                  borderRadius: AppSpacing.borderRadiusLG,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Monto',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    AppSpacing.verticalSpaceSM,
                    Row(
                      children: [
                        Text(
                          '\$',
                          style: Theme.of(context).textTheme.displayMedium?.copyWith(
                                color: isDark
                                    ? AppColors.textPrimaryDark
                                    : AppColors.textPrimaryLight,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                        AppSpacing.horizontalSpaceSM,
                        Expanded(
                          child: TextFormField(
                            controller: _amountController,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            style: Theme.of(context).textTheme.displayMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                            decoration: InputDecoration(
                              hintText: '0.00',
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              filled: false,
                              hintStyle: Theme.of(context)
                                  .textTheme
                                  .displayMedium
                                  ?.copyWith(
                                    color: isDark
                                        ? AppColors.textDisabledDark
                                        : AppColors.textDisabledLight,
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                            validator: (v) {
                              if (v == null || v.isEmpty) {
                                return 'Ingrese un monto';
                              }
                              final amount = double.tryParse(v);
                              if (amount == null || amount <= 0) {
                                return 'Ingrese un monto válido';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              AppSpacing.verticalSpaceXL,

              // Category Selection
              Text(
                'Categoría',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              AppSpacing.verticalSpaceMD,
              CategorySelector(
                selectedCategory: _selectedCategory,
                onCategorySelected: (category) {
                  setState(() {
                    _selectedCategory = category;
                  });
                },
              ),

              AppSpacing.verticalSpaceXL,

              // Account Selection
              Text(
                'Cuenta',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              AppSpacing.verticalSpaceMD,
              BlocBuilder<AccountBloc, AccountState>(
                builder: (context, state) {
                  if (state is AccountLoaded) {
                    final accounts = state.accounts;

                    if (accounts.isEmpty) {
                      return Container(
                        padding: AppSpacing.paddingMD,
                        decoration: BoxDecoration(
                          color: AppColors.warning.withOpacity(0.1),
                          borderRadius: AppSpacing.borderRadiusMD,
                          border: Border.all(color: AppColors.warning),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.warning, color: AppColors.warning),
                            AppSpacing.horizontalSpaceSM,
                            Expanded(
                              child: Text(
                                'No tienes cuentas. Crea una primero.',
                                style: TextStyle(color: AppColors.warning),
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.sm,
                      children: accounts.map((account) {
                        final isSelected = _selectedAccount?.id == account.id;
                        return ChoiceChip(
                          label: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(account.icon),
                              const SizedBox(width: 4),
                              Text(account.name),
                            ],
                          ),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              _selectedAccount = selected ? account : null;
                            });
                          },
                          selectedColor: AppColors.primary.withOpacity(0.2),
                          backgroundColor: isDark ? AppColors.cardDark : AppColors.cardLight,
                          side: BorderSide(
                            color: isSelected ? AppColors.primary : AppColors.grey300,
                          ),
                        );
                      }).toList(),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),

              AppSpacing.verticalSpaceXL,

              // Date Selection
              Text(
                'Fecha y Hora',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              AppSpacing.verticalSpaceMD,
              InkWell(
                onTap: _selectDate,
                borderRadius: AppSpacing.borderRadiusMD,
                child: Container(
                  padding: AppSpacing.paddingMD,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.cardDark : AppColors.cardLight,
                    borderRadius: AppSpacing.borderRadiusMD,
                    border: Border.all(
                      color: isDark ? AppColors.grey700 : AppColors.grey300,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        color: AppColors.primary,
                        size: AppSpacing.iconMD,
                      ),
                      AppSpacing.horizontalSpaceMD,
                      Expanded(
                        child: Text(
                          DateFormatter.formatDate(_selectedDate),
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: AppSpacing.iconSM,
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                      ),
                    ],
                  ),
                ),
              ),

              AppSpacing.verticalSpaceXL,

              // Note Input
              Text(
                'Nota (opcional)',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              AppSpacing.verticalSpaceMD,
              TextFormField(
                controller: _noteController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Agrega una descripción...',
                  prefixIcon: Icon(
                    Icons.notes,
                    color: AppColors.primary,
                  ),
                ),
              ),

              AppSpacing.verticalSpaceXL,

              // Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _save,
                  icon: const Icon(Icons.check),
                  label: const Text('Guardar Gasto'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                  ),
                ),
              ),

              AppSpacing.verticalSpaceMD,
            ],
          ),
        ),
      ),
    );
  }
}

// Extension to scale gradient opacity
extension on LinearGradient {
  LinearGradient scale(double factor) {
    return LinearGradient(
      colors: colors.map((c) => c.withOpacity(factor)).toList(),
      begin: begin,
      end: end,
    );
  }
}

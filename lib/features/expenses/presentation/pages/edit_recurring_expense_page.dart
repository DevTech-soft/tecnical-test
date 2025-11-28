import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/frequency_type.dart';
import '../../domain/entities/recurring_expense.dart';
import '../blocs/recurring_expenses_bloc.dart';
import '../blocs/recurring_expenses_event.dart';
import '../../../accounts/presentation/bloc/account_bloc.dart';
import '../../../accounts/presentation/bloc/account_state.dart';
import '../../../accounts/domain/entities/account.dart';

class EditRecurringExpensePage extends StatefulWidget {
  final RecurringExpense recurringExpense;

  const EditRecurringExpensePage({
    super.key,
    required this.recurringExpense,
  });

  @override
  State<EditRecurringExpensePage> createState() => _EditRecurringExpensePageState();
}

class _EditRecurringExpensePageState extends State<EditRecurringExpensePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _amountController;
  late TextEditingController _noteController;

  late Category _selectedCategory;
  late FrequencyType _selectedFrequency;
  late DateTime _startDate;
  DateTime? _endDate;
  late bool _hasEndDate;
  Account? _selectedAccount;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(
      text: widget.recurringExpense.amount.toStringAsFixed(0),
    );
    _noteController = TextEditingController(
      text: widget.recurringExpense.note ?? '',
    );
    _selectedCategory = CategoryHelper.getCategoryById(widget.recurringExpense.categoryId);
    _selectedFrequency = widget.recurringExpense.frequency;
    _startDate = widget.recurringExpense.startDate;
    _endDate = widget.recurringExpense.endDate;
    _hasEndDate = widget.recurringExpense.endDate != null;

    // Get the selected account from AccountBloc
    final accountState = context.read<AccountBloc>().state;
    if (accountState is AccountLoaded) {
      _selectedAccount = accountState.accounts
          .firstWhere((acc) => acc.id == widget.recurringExpense.accountId,
              orElse: () => accountState.accounts.first);
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Gasto Recurrente'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: _confirmDelete,
            tooltip: 'Eliminar',
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Categoría
            _buildCategorySection(),
            const SizedBox(height: 24),

            // Monto
            _buildAmountSection(),
            const SizedBox(height: 24),

            // Cuenta
            _buildAccountSection(),
            const SizedBox(height: 24),

            // Frecuencia
            _buildFrequencySection(),
            const SizedBox(height: 24),

            // Fecha de inicio
            _buildStartDateSection(),
            const SizedBox(height: 24),

            // Fecha de fin (opcional)
            _buildEndDateSection(),
            const SizedBox(height: 24),

            // Nota
            _buildNoteSection(),
            const SizedBox(height: 24),

            // Info de última generación
            if (widget.recurringExpense.lastGenerated != null)
              _buildLastGeneratedInfo(),

            const SizedBox(height: 32),

            // Botones
            _buildActionButtons(),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildCategorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Categoría',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButtonFormField<Category>(
            value: _selectedCategory,
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            items: CategoryHelper.allCategories.map((category) {
              return DropdownMenuItem(
                value: category,
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: category.color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        category.icon,
                        color: category.color,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(category.name),
                  ],
                ),
              );
            }).toList(),
            onChanged: (category) {
              if (category != null) {
                setState(() {
                  _selectedCategory = category;
                });
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAmountSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Monto',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _amountController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: 'Ingresa el monto',
            prefixText: '\$ ',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Por favor ingresa un monto';
            }
            final amount = double.tryParse(value);
            if (amount == null || amount <= 0) {
              return 'Por favor ingresa un monto válido';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildFrequencySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Frecuencia',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButtonFormField<FrequencyType>(
            value: _selectedFrequency,
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            items: FrequencyType.values.map((frequency) {
              return DropdownMenuItem(
                value: frequency,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      frequency.displayName,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    Text(
                      frequency.description,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
            onChanged: (frequency) {
              if (frequency != null) {
                setState(() {
                  _selectedFrequency = frequency;
                });
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStartDateSection() {
    final dateFormat = DateFormat('dd/MM/yyyy');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Fecha de inicio',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        InkWell(
          onTap: () => _selectStartDate(),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today, color: AppColors.primary),
                const SizedBox(width: 12),
                Text(
                  dateFormat.format(_startDate),
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEndDateSection() {
    final dateFormat = DateFormat('dd/MM/yyyy');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Fecha de fin',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(width: 8),
            Text(
              '(opcional)',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        CheckboxListTile(
          value: _hasEndDate,
          onChanged: (value) {
            setState(() {
              _hasEndDate = value ?? false;
              if (!_hasEndDate) {
                _endDate = null;
              } else if (_endDate == null) {
                _endDate = _startDate.add(const Duration(days: 365));
              }
            });
          },
          title: const Text('Establecer fecha de finalización'),
          contentPadding: EdgeInsets.zero,
          controlAffinity: ListTileControlAffinity.leading,
        ),
        if (_hasEndDate) ...[
          const SizedBox(height: 12),
          InkWell(
            onTap: () => _selectEndDate(),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.calendar_today, color: AppColors.primary),
                  const SizedBox(width: 12),
                  Text(
                    _endDate != null
                        ? dateFormat.format(_endDate!)
                        : 'Seleccionar fecha',
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildNoteSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Nota',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(width: 8),
            Text(
              '(opcional)',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _noteController,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'Ej: Netflix Premium, Renta del apartamento...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLastGeneratedInfo() {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: Colors.blue[700]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Última generación',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[700],
                  ),
                ),
                Text(
                  dateFormat.format(widget.recurringExpense.lastGenerated!),
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.blue[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Cuenta',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        BlocBuilder<AccountBloc, AccountState>(
          builder: (context, state) {
            if (state is AccountLoaded) {
              final accounts = state.accounts;

              if (accounts.isEmpty) {
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.warning),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.warning, color: AppColors.warning),
                      const SizedBox(width: 12),
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
                spacing: 12,
                runSpacing: 12,
                children: accounts.map((account) {
                  final isSelected = _selectedAccount?.id == account.id;
                  return ChoiceChip(
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(account.icon),
                        const SizedBox(width: 6),
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
                    backgroundColor: Colors.white,
                    side: BorderSide(
                      color: isSelected ? AppColors.primary : Colors.grey.shade300,
                      width: isSelected ? 2 : 1,
                    ),
                  );
                }).toList(),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Cancelar'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: _saveRecurringExpense,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Guardar Cambios'),
          ),
        ),
      ],
    );
  }

  Future<void> _selectStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (picked != null && mounted) {
      setState(() {
        _startDate = picked;
        // Si la fecha de fin es anterior a la nueva fecha de inicio, actualizarla
        if (_hasEndDate && _endDate != null && _endDate!.isBefore(_startDate)) {
          _endDate = _startDate.add(const Duration(days: 365));
        }
      });
    }
  }

  Future<void> _selectEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? _startDate.add(const Duration(days: 365)),
      firstDate: _startDate,
      lastDate: DateTime(2100),
    );

    if (picked != null && mounted) {
      setState(() {
        _endDate = picked;
      });
    }
  }

  void _saveRecurringExpense() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Validar cuenta seleccionada
    if (_selectedAccount == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor selecciona una cuenta'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Validar fecha de fin
    if (_hasEndDate && _endDate != null && _endDate!.isBefore(_startDate)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('La fecha de fin debe ser posterior a la fecha de inicio'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final amount = double.parse(_amountController.text);
    final note = _noteController.text.trim().isEmpty ? null : _noteController.text.trim();

    final updatedRecurringExpense = widget.recurringExpense.copyWith(
      amount: amount,
      categoryId: _selectedCategory.id,
      accountId: _selectedAccount!.id,
      note: note,
      frequency: _selectedFrequency,
      startDate: _startDate,
      endDate: _endDate,
      updatedAt: DateTime.now(),
    );

    context.read<RecurringExpensesBloc>().add(
          UpdateRecurringExpenseEvent(updatedRecurringExpense),
        );

    Navigator.pop(context);
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Gasto Recurrente'),
        content: const Text(
          '¿Estás seguro de que deseas eliminar este gasto recurrente?\n\n'
          'Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Cerrar diálogo
              context.read<RecurringExpensesBloc>().add(
                    DeleteRecurringExpenseEvent(widget.recurringExpense.id),
                  );
              Navigator.pop(context); // Cerrar página de edición
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}

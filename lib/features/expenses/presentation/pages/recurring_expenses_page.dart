import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/error_display.dart';
import '../../../../core/errors/failures.dart';
import '../../../../injection_container.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/frequency_type.dart';
import '../../domain/entities/recurring_expense.dart';
import '../blocs/recurring_expenses_bloc.dart';
import '../blocs/recurring_expenses_event.dart';
import '../blocs/recurring_expenses_state.dart';
import 'add_recurring_expense_page.dart';
import 'edit_recurring_expense_page.dart';

class RecurringExpensesPage extends StatelessWidget {
  const RecurringExpensesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<RecurringExpensesBloc>()
        ..add(const LoadRecurringExpensesEvent()),
      child: const _RecurringExpensesView(),
    );
  }
}

class _RecurringExpensesView extends StatelessWidget {
  const _RecurringExpensesView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gastos Recurrentes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context
                  .read<RecurringExpensesBloc>()
                  .add(const GenerateExpensesEvent());
            },
            tooltip: 'Generar gastos pendientes',
          ),
        ],
      ),
      body: BlocConsumer<RecurringExpensesBloc, RecurringExpensesState>(
        listener: (context, state) {
          if (state is RecurringExpenseOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ),
            );
          } else if (state is ExpensesGenerated) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${state.count} gasto(s) generado(s)'),
                backgroundColor: state.count > 0 ? Colors.green : Colors.blue,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is RecurringExpensesLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is RecurringExpensesError) {
            return ErrorDisplay(
              failure: UnexpectedFailure(message: state.message),
              onRetry: () => context
                  .read<RecurringExpensesBloc>()
                  .add(const LoadRecurringExpensesEvent()),
            );
          }

          final recurringExpenses = _getRecurringExpenses(state);

          if (recurringExpenses.isEmpty) {
            return _buildEmptyState(context);
          }

          return _buildList(context, recurringExpenses);
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'recurring_expenses_fab',
        onPressed: () => _navigateToAdd(context),
        icon: const Icon(Icons.add),
        label: const Text('Nuevo Recurrente'),
      ),
    );
  }

  List<RecurringExpense> _getRecurringExpenses(RecurringExpensesState state) {
    if (state is RecurringExpensesLoaded) {
      return state.recurringExpenses;
    } else if (state is RecurringExpenseOperationSuccess) {
      return state.recurringExpenses;
    } else if (state is ExpensesGenerated) {
      return state.recurringExpenses;
    }
    return [];
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.repeat,
              size: 100,
              color: AppColors.primary.withOpacity(0.3),
            ),
            const SizedBox(height: 24),
            Text(
              'Sin gastos recurrentes',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),
            Text(
              'Crea gastos recurrentes para suscripciones,\nrentas y gastos periódicos',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey,
                  ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => _navigateToAdd(context),
              icon: const Icon(Icons.add),
              label: const Text('Crear Gasto Recurrente'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildList(
    BuildContext context,
    List<RecurringExpense> recurringExpenses,
  ) {
    // Separar activos e inactivos
    final active = recurringExpenses.where((e) => e.isActive).toList();
    final inactive = recurringExpenses.where((e) => !e.isActive).toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (active.isNotEmpty) ...[
          Text(
            'Activos (${active.length})',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          ...active.map((recurring) => _buildRecurringCard(context, recurring)),
          const SizedBox(height: 24),
        ],
        if (inactive.isNotEmpty) ...[
          Text(
            'Pausados (${inactive.length})',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.grey,
                ),
          ),
          const SizedBox(height: 12),
          ...inactive.map((recurring) => _buildRecurringCard(context, recurring)),
        ],
        const SizedBox(height: 80), // Espacio para el FAB
      ],
    );
  }

  Widget _buildRecurringCard(
    BuildContext context,
    RecurringExpense recurring,
  ) {
    final category = CategoryHelper.getCategoryById(recurring.categoryId);
    final currencyFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 0);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _navigateToEdit(context, recurring),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Icono de categoría
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: category.color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      category.icon,
                      color: category.color,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Monto y frecuencia
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          currencyFormat.format(recurring.amount),
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        Text(
                          recurring.frequency.displayName,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.grey,
                              ),
                        ),
                      ],
                    ),
                  ),
                  // Estado
                  if (!recurring.isActive)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'PAUSADO',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                ],
              ),
              if (recurring.note != null) ...[
                const SizedBox(height: 8),
                Text(
                  recurring.note!,
                  style: Theme.of(context).textTheme.bodyMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 12),
              // Próxima generación
              Row(
                children: [
                  Icon(
                    Icons.schedule,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _getNextGenerationText(recurring),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                  const Spacer(),
                  // Botón de pausar/reanudar
                  IconButton(
                    icon: Icon(
                      recurring.isActive ? Icons.pause_circle : Icons.play_circle,
                      color: recurring.isActive ? Colors.orange : Colors.green,
                    ),
                    onPressed: () => _toggleActive(context, recurring),
                    tooltip: recurring.isActive ? 'Pausar' : 'Reanudar',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getNextGenerationText(RecurringExpense recurring) {
    if (!recurring.isActive) {
      return 'Pausado';
    }

    final next = recurring.nextGenerationDate;
    if (next == null) {
      return 'Finalizado';
    }

    final now = DateTime.now();
    final difference = next.difference(now);

    if (difference.inDays > 0) {
      return 'Próximo en ${difference.inDays} día(s)';
    } else if (difference.inHours > 0) {
      return 'Próximo en ${difference.inHours} hora(s)';
    } else if (difference.isNegative) {
      return 'Pendiente de generar';
    } else {
      return 'Hoy';
    }
  }

  void _toggleActive(BuildContext context, RecurringExpense recurring) {
    if (recurring.isActive) {
      context.read<RecurringExpensesBloc>().add(
            PauseRecurringExpenseEvent(recurring),
          );
    } else {
      context.read<RecurringExpensesBloc>().add(
            ResumeRecurringExpenseEvent(recurring),
          );
    }
  }

  void _navigateToAdd(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<RecurringExpensesBloc>(),
          child: const AddRecurringExpensePage(),
        ),
      ),
    );
  }

  void _navigateToEdit(BuildContext context, RecurringExpense recurring) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<RecurringExpensesBloc>(),
          child: EditRecurringExpensePage(recurringExpense: recurring),
        ),
      ),
    );
  }
}

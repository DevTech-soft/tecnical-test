import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/expenses_bloc.dart';
import '../blocs/filter_bloc.dart';
import 'add_expense_page.dart';
import 'edit_expense_page.dart';
import 'search_expenses_page.dart';
import 'recurring_expenses_page.dart';
import '../../domain/entities/expense.dart';
import '../widgets/expense_card.dart';
import '../widgets/expense_summary_card.dart';
import '../widgets/empty_state.dart';
import '../widgets/stats_overview.dart';
import '../widgets/date_filter_selector.dart';
import '../../../../injection_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/shimmer_loading.dart';
import '../../../../core/widgets/responsive_builder.dart';
import '../../../export/presentation/pages/export_page.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ScrollController _scrollController = ScrollController();
  bool _isScrolled = false;
  late final ExpensesBloc _expensesBloc;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _expensesBloc = sl<ExpensesBloc>()..add(LoadExpensesEvent());
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _expensesBloc.close();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.offset > 10 && !_isScrolled) {
      setState(() => _isScrolled = true);
    } else if (_scrollController.offset <= 10 && _isScrolled) {
      setState(() => _isScrolled = false);
    }
  }

  void _navigateToAddExpense() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) => BlocProvider.value(
              value: _expensesBloc,
              child: const AddExpensePage(),
            ),
      ),
    ).then((_) {
      // Reload expenses after adding
      _expensesBloc.add(LoadExpensesEvent());
    });
  }

  void _navigateToEditExpense(Expense expense) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) => BlocProvider.value(
              value: _expensesBloc,
              child: EditExpensePage(expense: expense),
            ),
      ),
    ).then((_) {
      // Reload expenses after editing
      _expensesBloc.add(LoadExpensesEvent());
    });
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppColors.textPrimaryLight,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  List<Expense> _filterExpensesByDate(List<Expense> expenses) {
    final selectedDay = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
    );

    return expenses.where((expense) {
      final expenseDay = DateTime(
        expense.date.year,
        expense.date.month,
        expense.date.day,
      );
      return expenseDay == selectedDay;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _expensesBloc,
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: ResponsiveBuilder(
            builder: (context, deviceType) {
              return CustomScrollView(
                controller: _scrollController,
                slivers: [
                  _buildAppBar(context),
                  SliverToBoxAdapter(
                    child: BlocBuilder<ExpensesBloc, ExpensesState>(
                      builder: (context, state) {
                        if (state is ExpensesLoading) {
                          return _buildLoadingState();
                        }
                        if (state is ExpensesLoaded) {
                          final allExpenses = state.expenses;
                          final filteredExpenses = _filterExpensesByDate(
                            allExpenses,
                          );

                          if (filteredExpenses.isEmpty) {
                            return SizedBox(
                              height: MediaQuery.of(context).size.height - 200,
                              child: EmptyState(
                                title: 'Sin gastos',
                                message:
                                    'No hay gastos registrados para esta fecha.\nSelecciona otra fecha o agrega un nuevo gasto.',
                                icon: Icons.calendar_month,
                                actionLabel: 'Agregar Gasto',
                                onActionPressed: _navigateToAddExpense,
                              ),
                            );
                          }
                          return Column(
                            children: [
                              ExpenseSummaryCard(expenses: filteredExpenses),
                              AppSpacing.verticalSpaceSM,
                              StatsOverview(expenses: filteredExpenses),
                              AppSpacing.verticalSpaceMD,
                              Padding(
                                padding: AppSpacing.paddingHorizontalMD,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Transacciones',
                                      style: Theme.of(
                                        context,
                                      ).textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text(
                                      '${filteredExpenses.length} ${filteredExpenses.length == 1 ? 'gasto' : 'gastos'}',
                                      style: Theme.of(
                                        context,
                                      ).textTheme.labelMedium?.copyWith(
                                        color: AppColors.textSecondaryLight,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              AppSpacing.verticalSpaceSM,
                            ],
                          );
                        }
                        if (state is ExpensesError) {
                          return _buildErrorState(state.userMessage);
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                  BlocBuilder<ExpensesBloc, ExpensesState>(
                    builder: (context, state) {
                      if (state is ExpensesLoaded) {
                        final filteredExpenses = _filterExpensesByDate(
                          state.expenses,
                        );

                        if (filteredExpenses.isNotEmpty) {
                          return SliverList(
                            delegate: SliverChildBuilderDelegate((
                              context,
                              index,
                            ) {
                              final expense = filteredExpenses[index];
                              return ExpenseCard(
                                expense: expense,
                                onTap: () => _navigateToEditExpense(expense),
                                onDelete: () {
                                  _showDeleteConfirmation(context, expense.id);
                                },
                              );
                            }, childCount: filteredExpenses.length),
                          );
                        }
                      }
                      return const SliverToBoxAdapter(child: SizedBox.shrink());
                    },
                  ),
                  const SliverToBoxAdapter(
                    child: SizedBox(height: AppSpacing.xxxl),
                  ),
                ],
              );
            },
          ),
          floatingActionButton: _buildFAB(context),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SliverAppBar(
      expandedHeight: 100,
      floating: true,
      pinned: true,
      elevation: _isScrolled ? 2 : 0,
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      actions: [
        IconButton(
          icon: Icon(
            Icons.search,
            color:
                _isScrolled
                    ? (isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimaryLight)
                    : Colors.white,
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => BlocProvider(
                  create: (_) => sl<FilterBloc>(),
                  child: const SearchExpensesPage(),
                ),
              ),
            );
          },
          tooltip: 'Buscar gastos',
        ),
        PopupMenuButton<String>(
          icon: Icon(
            Icons.more_vert,
            color:
                _isScrolled
                    ? (isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimaryLight)
                    : Colors.white,
          ),
          onSelected: (value) {
            if (value == 'recurring') {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const RecurringExpensesPage(),
                ),
              );
            } else if (value == 'export') {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (_) => BlocProvider.value(
                        value: _expensesBloc,
                        child: const ExportPage(),
                      ),
                ),
              );
            } else if (value == 'logout') {
              // Mostrar diálogo de confirmación
              showDialog(
                context: context,
                builder:
                    (dialogContext) => AlertDialog(
                      title: const Text('Cerrar sesión'),
                      content: const Text(
                        '¿Estás seguro de que quieres cerrar sesión?',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(dialogContext),
                          child: const Text('Cancelar'),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(dialogContext);
                            context.read<AuthBloc>().add(
                              const SignOutRequested(),
                            );
                          },
                          child: const Text('Cerrar sesión'),
                        ),
                      ],
                    ),
              );
            }
          },
          itemBuilder:
              (context) => [
                const PopupMenuItem(
                  value: 'recurring',
                  child: Row(
                    children: [
                      Icon(Icons.repeat, size: 20),
                      SizedBox(width: 12),
                      Text('Gastos Recurrentes'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'export',
                  child: Row(
                    children: [
                      Icon(Icons.file_download, size: 20),
                      SizedBox(width: 12),
                      Text('Exportar Datos'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'settings',
                  child: Row(
                    children: [
                      Icon(Icons.settings, size: 20),
                      SizedBox(width: 12),
                      Text('Configuración'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'logout',
                  child: Row(
                    children: [
                      Icon(Icons.logout, size: 20),
                      SizedBox(width: 12),
                      Text('Cerrar sesión'),
                    ],
                  ),
                ),
              ],
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        titlePadding: const EdgeInsets.only(bottom: AppSpacing.md),
        title: DateFilterSelector(
          selectedDate: _selectedDate,
          onTap: _selectDate,
          isScrolled: _isScrolled,
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: _isScrolled ? null : AppColors.primaryGradient.scale(0.1),
          ),
        ),
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Buenos días';
    } else if (hour < 18) {
      return 'Buenas tardes';
    } else {
      return 'Buenas noches';
    }
  }

  Widget _buildFAB(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: _navigateToAddExpense,
      icon: const Icon(Icons.add),
      label: Text(_isScrolled ? '' : 'Agregar Gasto'),
      elevation: AppSpacing.elevation3,
    );
  }

  Widget _buildLoadingState() {
    return Column(
      children: [
        const ShimmerSummaryCard(),
        AppSpacing.verticalSpaceMD,
        ...List.generate(5, (index) => const ShimmerExpenseCard()),
      ],
    );
  }

  Widget _buildErrorState(String message) {
    return SizedBox(
      height: 400,
      child: EmptyState(
        title: 'Error',
        message: message,
        icon: Icons.error_outline,
        actionLabel: 'Reintentar',
        onActionPressed: () {
          _expensesBloc.add(LoadExpensesEvent());
        },
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, String expenseId) {
    showDialog(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            title: const Text('Confirmar eliminación'),
            content: const Text(
              '¿Estás seguro de que deseas eliminar este gasto?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () {
                  _expensesBloc.add(DeleteExpenseEvent(expenseId));
                  Navigator.pop(dialogContext);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Gasto eliminado correctamente'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                ),
                child: const Text('Eliminar'),
              ),
            ],
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

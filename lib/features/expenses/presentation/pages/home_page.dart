import 'package:dayli_expenses/core/utils/date_formatter.dart';
import 'package:dayli_expenses/features/expenses/domain/entities/category.dart';
import 'package:dayli_expenses/features/expenses/presentation/widgets/expense_info_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/expenses_bloc.dart';
import '../blocs/filter_bloc.dart';
import '../blocs/category_bloc.dart';
import 'add_expense_page.dart';
import 'edit_expense_page.dart';
import 'search_expenses_page.dart';
import 'recurring_expenses_page.dart';
import 'manage_categories_page.dart';
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
import '../../../accounts/presentation/bloc/account_bloc.dart';
import '../../../accounts/presentation/bloc/account_event.dart';
import '../../../accounts/presentation/bloc/account_state.dart';
import '../../../accounts/presentation/pages/account_onboarding_page.dart';
import '../../../accounts/presentation/pages/manage_accounts_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ScrollController _scrollController = ScrollController();
  bool _isScrolled = false;
  late final ExpensesBloc _expensesBloc;
  late final AccountBloc _accountBloc;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _expensesBloc = sl<ExpensesBloc>()..add(LoadExpensesEvent());
    _accountBloc = sl<AccountBloc>()..add(LoadAccounts());
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



  void _navigateToEditExpense(Expense expense) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) => MultiBlocProvider(
              providers: [
                BlocProvider.value(value: _expensesBloc),
                BlocProvider.value(value: context.read<CategoryBloc>()),
              ],
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
    return BlocBuilder<AccountBloc, AccountState>(
      builder: (context, accountState) {
        if (accountState is AccountLoaded && !accountState.hasAccounts) {
          return const AccountOnboardingPage();
        }

        return MultiBlocProvider(
          providers: [
            BlocProvider.value(value: _accountBloc),
            BlocProvider.value(value: _expensesBloc),
          ],
          child: SafeArea(
            child: Scaffold(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              body: ResponsiveBuilder(
                builder: (context, deviceType) {
                  return CustomScrollView(
                    controller: _scrollController,
                    slivers: [
                      _buildAppBar(context),
                      SliverPadding(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        sliver: SliverList(
                          delegate: SliverChildListDelegate([
                            BlocBuilder<AccountBloc, AccountState>(
                              builder: (context, accountState) {
                                if (accountState is AccountLoading) {
                                  return _buildLoadingState();
                                }
                                if (accountState is AccountLoaded) {
                                  final accounts = accountState.accounts;

                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      ExpenseSummaryCard(accounts: accounts),
                                      AppSpacing.verticalSpaceXL,
                                      Text(
                                        'Este mes',
                                        style: Theme.of(
                                          context,
                                        ).textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.textPrimaryLight,
                                        ),
                                      ),
                                      AppSpacing.verticalSpaceMD,
                                      // BlocBuilder<ExpensesBloc, ExpensesState>(
                                      //   builder: (context, expenseState) {
                                      //     if (expenseState is ExpensesLoaded) {
                                      //       final filteredExpenses =
                                      //           _filterExpensesByDate(
                                      //             expenseState.expenses,
                                      //           );
                                      //       return StatsOverview(
                                      //         expenses: filteredExpenses,
                                      //       );
                                      //     }
                                      //     return const SizedBox.shrink();
                                      //   },
                                      // ),
                                      BlocBuilder<ExpensesBloc, ExpensesState>(
                                        builder: (context, state) {
                                          if (state is ExpensesLoaded) {
                                            final allExpenses = state.expenses;

                                            final totalExpenses = allExpenses
                                                .fold<double>(
                                                  0,
                                                  (sum, expense) =>
                                                      sum + expense.amount,
                                                );

                                            final recentExpenses =
                                                allExpenses.take(2).toList();

                                            return ExpenseInfoCard(
                                              title: 'Gasto General',
                                              totalGeneralExpense:
                                                  totalExpenses.toInt(),
                                              subtitle: 'Gastos principales',
                                              child:
                                                  recentExpenses.isEmpty
                                                      ? Padding(
                                                        padding:
                                                            const EdgeInsets.symmetric(
                                                              vertical:
                                                                  AppSpacing.md,
                                                            ),
                                                        child: Center(
                                                          child: Text(
                                                            'No hay gastos registrados',
                                                            style: Theme.of(
                                                                  context,
                                                                )
                                                                .textTheme
                                                                .bodyMedium
                                                                ?.copyWith(
                                                                  color:
                                                                      AppColors
                                                                          .textSecondaryLight,
                                                                ),
                                                          ),
                                                        ),
                                                      )
                                                      : Padding(
                                                        padding:
                                                            const EdgeInsets.symmetric(
                                                              horizontal:
                                                                  AppSpacing.md,
                                                            ),
                                                        child: Row(
                                                          children:
                                                              recentExpenses.map((
                                                                expense,
                                                              ) {
                                                                final category =
                                                                    CategoryHelper.getCategoryById(
                                                                      expense
                                                                          .categoryId,
                                                                    );

                                                                return Padding(
                                                                  padding:
                                                                      const EdgeInsets.only(
                                                                        right:
                                                                            32,
                                                                      ),
                                                                  child: Row(
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                    children: [
                                                                      Container(
                                                                        width:
                                                                            10,
                                                                        height:
                                                                            10,
                                                                        margin: const EdgeInsets.only(
                                                                          top:
                                                                              4,
                                                                        ),
                                                                        decoration: BoxDecoration(
                                                                          color:
                                                                              category.color,
                                                                          shape:
                                                                              BoxShape.circle,
                                                                        ),
                                                                      ),

                                                                      const SizedBox(
                                                                        width:
                                                                            8,
                                                                      ),

                                                                      Column(
                                                                        crossAxisAlignment:
                                                                            CrossAxisAlignment.start,
                                                                        children: [
                                                                          Text(
                                                                            category.name,
                                                                            style: Theme.of(
                                                                              context,
                                                                            ).textTheme.bodyMedium?.copyWith(
                                                                              fontWeight:
                                                                                  FontWeight.bold,
                                                                              color:
                                                                                  AppColors.textPrimaryLight,
                                                                            ),
                                                                          ),
                                                                          const SizedBox(
                                                                            height:
                                                                                4,
                                                                          ),
                                                                          Text(
                                                                            DateFormatter.formatCurrency(
                                                                              expense.amount,
                                                                            ),
                                                                            style: Theme.of(
                                                                              context,
                                                                            ).textTheme.bodyMedium?.copyWith(
                                                                              fontWeight:
                                                                                  FontWeight.normal,
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ],
                                                                  ),
                                                                );
                                                              }).toList(),
                                                        ),
                                                      ),
                                            );
                                          }
                                          return const SizedBox.shrink();
                                        },
                                      ),
                                      AppSpacing.verticalSpaceMD,

                                      AppSpacing.verticalSpaceSM,
                                    ],
                                  );
                                }
                                if (accountState is AccountError) {
                                  return _buildErrorState(accountState.message);
                                }
                                return const SizedBox.shrink();
                              },
                            ),
                            const SizedBox(height: AppSpacing.xxxl),
                          ]),
                        ),
                      ),
                    ],
                  );
                },
              ),
              // floatingActionButton: _buildFAB(context),
            ),
          ),
        );
      },
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
                    : AppColors.textPrimaryLight,
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (_) => BlocProvider(
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
                    : AppColors.textPrimaryLight,
          ),
          onSelected: (value) {
            if (value == 'export') {
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
        centerTitle: false,
        titlePadding: const EdgeInsets.only(
          bottom: AppSpacing.md,
          left: AppSpacing.md,
        ),
        title: Text("Inicio", style: Theme.of(context).textTheme.titleLarge),
        // DateFilterSelector(
        //   selectedDate: _selectedDate,
        //   onTap: _selectDate,
        //   isScrolled: _isScrolled,
        // ),
        background: Container(
          decoration: BoxDecoration(
            gradient: _isScrolled ? null : AppColors.primaryGradient.scale(0.1),
          ),
        ),
      ),
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

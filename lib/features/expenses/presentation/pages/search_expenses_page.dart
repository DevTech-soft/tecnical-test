import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/widgets/error_display.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/expense_filter.dart';
import '../blocs/filter_bloc.dart';
import '../blocs/filter_event.dart';
import '../blocs/filter_state.dart';
import '../widgets/expense_card.dart';
import '../widgets/empty_state.dart';

class SearchExpensesPage extends StatefulWidget {
  const SearchExpensesPage({super.key});

  @override
  State<SearchExpensesPage> createState() => _SearchExpensesPageState();
}

class _SearchExpensesPageState extends State<SearchExpensesPage> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _minAmountController = TextEditingController();
  final TextEditingController _maxAmountController = TextEditingController();

  List<Category> _selectedCategories = [];
  DateTime? _startDate;
  DateTime? _endDate;
  ExpenseSortOption _currentSort = ExpenseSortOption.dateDesc;

  @override
  void initState() {
    super.initState();
    // Buscar todos los gastos al inicio
    context.read<FilterBloc>().add(
          const SearchExpensesEvent(ExpenseFilter.empty()),
        );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _minAmountController.dispose();
    _maxAmountController.dispose();
    super.dispose();
  }

  void _performSearch() {
    // Verificar que el widget esté montado antes de usar el context
    if (!mounted) return;

    final filter = ExpenseFilter(
      searchQuery: _searchController.text.isEmpty ? null : _searchController.text,
      categories: _selectedCategories.isEmpty ? null : _selectedCategories,
      startDate: _startDate,
      endDate: _endDate,
      minAmount: _minAmountController.text.isEmpty
          ? null
          : double.tryParse(_minAmountController.text),
      maxAmount: _maxAmountController.text.isEmpty
          ? null
          : double.tryParse(_maxAmountController.text),
      sortBy: _currentSort,
    );

    context.read<FilterBloc>().add(SearchExpensesEvent(filter));
  }

  void _clearFilters() {
    if (!mounted) return;

    setState(() {
      _searchController.clear();
      _selectedCategories = [];
      _startDate = null;
      _endDate = null;
      _minAmountController.clear();
      _maxAmountController.clear();
      _currentSort = ExpenseSortOption.dateDesc;
    });

    context.read<FilterBloc>().add(const ClearAllFiltersEvent());
  }

  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _startDate != null && _endDate != null
          ? DateTimeRange(start: _startDate!, end: _endDate!)
          : null,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && mounted) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
      _performSearch();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buscar Gastos'),
        actions: [
          BlocBuilder<FilterBloc, FilterState>(
            builder: (context, state) {
              if (state is FilterSuccess && state.currentFilter.hasActiveFilters) {
                return IconButton(
                  icon: const Icon(Icons.clear_all),
                  onPressed: _clearFilters,
                  tooltip: 'Limpiar filtros',
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Barra de búsqueda
          _buildSearchBar(),

          // Filtros activos
          _buildActiveFiltersChips(),

          // Resultados
          Expanded(
            child: BlocBuilder<FilterBloc, FilterState>(
              builder: (context, state) {
                if (state is FilterLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is FilterError) {
                  return Center(
                    child: ErrorDisplay(
                      failure: UnexpectedFailure(message: state.message),
                      onRetry: _performSearch,
                    ),
                  );
                }

                if (state is FilterSuccess) {
                  if (state.expenses.isEmpty) {
                    return EmptyState(
                      title: 'Sin resultados',
                      icon: Icons.search_off,
                      message: state.currentFilter.hasActiveFilters
                          ? 'No se encontraron gastos con estos filtros'
                          : 'No hay gastos registrados',
                      actionLabel: state.currentFilter.hasActiveFilters
                          ? 'Limpiar filtros'
                          : null,
                      onActionPressed: state.currentFilter.hasActiveFilters
                          ? _clearFilters
                          : null,
                    );
                  }

                  return Column(
                    children: [
                      // Contador y ordenamiento
                      _buildResultsHeader(state.expenses.length),

                      // Lista de resultados
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: state.expenses.length,
                          itemBuilder: (context, index) {
                            return ExpenseCard(
                              expense: state.expenses[index],
                            );
                          },
                        ),
                      ),
                    ],
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'search_expenses_fab',
        onPressed: () => _showFilterBottomSheet(context),
        icon: const Icon(Icons.filter_list),
        label: const Text('Filtros'),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Theme.of(context).cardColor,
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Buscar por nota o categoría...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    _performSearch();
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          filled: true,
        ),
        onChanged: (value) {
          // Búsqueda en tiempo real con debounce
          Future.delayed(const Duration(milliseconds: 500), () {
            if (value == _searchController.text) {
              _performSearch();
            }
          });
        },
      ),
    );
  }

  Widget _buildActiveFiltersChips() {
    return BlocBuilder<FilterBloc, FilterState>(
      builder: (context, state) {
        if (state is! FilterSuccess || !state.currentFilter.hasActiveFilters) {
          return const SizedBox.shrink();
        }

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (state.currentFilter.categories != null &&
                  state.currentFilter.categories!.isNotEmpty)
                ...state.currentFilter.categories!.map(
                  (category) => Chip(
                    label: Text(category.name),
                    avatar: Icon(
                      category.icon,
                      color: category.color,
                      size: 18,
                    ),
                    onDeleted: () {
                      setState(() {
                        _selectedCategories.remove(category);
                      });
                      _performSearch();
                    },
                  ),
                ),
              if (_startDate != null || _endDate != null)
                Chip(
                  label: Text(
                    '${_startDate != null ? '${_startDate!.day}/${_startDate!.month}' : ''} - ${_endDate != null ? '${_endDate!.day}/${_endDate!.month}' : ''}',
                  ),
                  avatar: const Icon(Icons.date_range, size: 18),
                  onDeleted: () {
                    setState(() {
                      _startDate = null;
                      _endDate = null;
                    });
                    _performSearch();
                  },
                ),
              if (_minAmountController.text.isNotEmpty ||
                  _maxAmountController.text.isNotEmpty)
                Chip(
                  label: Text(
                    '\$${_minAmountController.text.isNotEmpty ? _minAmountController.text : '0'} - \$${_maxAmountController.text.isNotEmpty ? _maxAmountController.text : '∞'}',
                  ),
                  avatar: const Icon(Icons.attach_money, size: 18),
                  onDeleted: () {
                    setState(() {
                      _minAmountController.clear();
                      _maxAmountController.clear();
                    });
                    _performSearch();
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildResultsHeader(int count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Text(
            '$count resultado${count != 1 ? 's' : ''}',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const Spacer(),
          PopupMenuButton<ExpenseSortOption>(
            icon: const Icon(Icons.sort),
            onSelected: (option) {
              setState(() {
                _currentSort = option;
              });
              // Ejecutar después del frame actual para evitar errores de widget desmontado
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _performSearch();
              });
            },
            itemBuilder: (context) => ExpenseSortOption.values
                .map(
                  (option) => PopupMenuItem(
                    value: option,
                    child: Row(
                      children: [
                        if (_currentSort == option)
                          const Icon(Icons.check, size: 18)
                        else
                          const SizedBox(width: 18),
                        const SizedBox(width: 8),
                        Text(option.displayName),
                      ],
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => _buildFilterSheet(scrollController),
      ),
    );
  }

  Widget _buildFilterSheet(ScrollController scrollController) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: ListView(
        controller: scrollController,
        children: [
          // Header
          Row(
            children: [
              Text(
                'Filtros',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const Spacer(),
              TextButton(
                onPressed: () {
                  _clearFilters();
                  Navigator.pop(context);
                },
                child: const Text('Limpiar todo'),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Categorías
          Text(
            'Categorías',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: CategoryHelper.allCategories.map((category) {
              final isSelected = _selectedCategories.contains(category);
              return FilterChip(
                label: Text(category.name),
                avatar: Icon(
                  category.icon,
                  color: isSelected ? Colors.white : category.color,
                  size: 18,
                ),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedCategories.add(category);
                    } else {
                      _selectedCategories.remove(category);
                    }
                  });
                  _performSearch();
                },
              );
            }).toList(),
          ),

          const SizedBox(height: 24),

          // Rango de fechas
          Text(
            'Rango de Fechas',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: _selectDateRange,
            icon: const Icon(Icons.date_range),
            label: Text(
              _startDate != null && _endDate != null
                  ? '${_startDate!.day}/${_startDate!.month}/${_startDate!.year} - ${_endDate!.day}/${_endDate!.month}/${_endDate!.year}'
                  : 'Seleccionar rango',
            ),
          ),

          const SizedBox(height: 24),

          // Rango de montos
          Text(
            'Rango de Montos',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _minAmountController,
                  decoration: const InputDecoration(
                    labelText: 'Monto mínimo',
                    prefixText: '\$',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) => _performSearch(),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextField(
                  controller: _maxAmountController,
                  decoration: const InputDecoration(
                    labelText: 'Monto máximo',
                    prefixText: '\$',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) => _performSearch(),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Botón cerrar
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Aplicar Filtros'),
          ),
        ],
      ),
    );
  }
}

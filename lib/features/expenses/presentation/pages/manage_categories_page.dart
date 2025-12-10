import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/category.dart';
import '../blocs/category_bloc.dart';
import '../blocs/category_event.dart';
import '../blocs/category_state.dart';
import 'add_category_page.dart';

class ManageCategoriesPage extends StatelessWidget {
  const ManageCategoriesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestionar Categorías'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.black),
            onPressed: () async {
              final result = await Navigator.push<bool>(
                context,
                MaterialPageRoute(
                  builder:
                      (_) => BlocProvider.value(
                        value: context.read<CategoryBloc>(),
                        child: const AddCategoryPage(),
                      ),
                ),
              );

              if (result == true && context.mounted) {
                context.read<CategoryBloc>().add(const LoadCategories());
              }
            },
          ),
        ],
      ),
      body: BlocConsumer<CategoryBloc, CategoryState>(
        listener: (context, state) {
          if (state is CategoryOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
              ),
            );
          } else if (state is CategoryError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is CategoryLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is CategoryError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Error',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      state.message,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      context.read<CategoryBloc>().add(const LoadCategories());
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          List<ExpenseCategory> categories = [];
          if (state is CategoryLoaded) {
            categories = state.categories;
          } else if (state is CategoryOperationSuccess) {
            categories = state.categories;
          }

          if (categories.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.category_outlined,
                    size: 64,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No hay categorías',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  const Text('Agrega tu primera categoría personalizada'),
                ],
              ),
            );
          }

          // Separar categorías predefinidas y personalizadas
          final predefinedCategories = <ExpenseCategory>[];
          final customCategories = <ExpenseCategory>[];

          // Necesitamos verificar si es personalizada comparando con las predefinidas
          final predefinedIds =
              CategoryHelper.defaultCategories.map((c) => c.id).toSet();

          for (final category in categories) {
            if (predefinedIds.contains(category.id)) {
              predefinedCategories.add(category);
            } else {
              customCategories.add(category);
            }
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (predefinedCategories.isNotEmpty) ...[
                Text(
                  'Categorías Predefinidas',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                ...predefinedCategories.map(
                  (category) =>
                      _CategoryTile(category: category, isPredefined: true),
                ),
                const SizedBox(height: 24),
              ],
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Categorías Personalizadas',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${customCategories.length}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (customCategories.isEmpty)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        Icon(
                          Icons.add_circle_outline,
                          size: 48,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Sin categorías personalizadas',
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(color: Colors.grey[600]),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Toca el botón + para crear una',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: Colors.grey[500]),
                        ),
                      ],
                    ),
                  ),
                )
              else
                ...customCategories.map(
                  (category) =>
                      _CategoryTile(category: category, isPredefined: false),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  final ExpenseCategory category;
  final bool isPredefined;

  const _CategoryTile({required this.category, required this.isPredefined});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: category.color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(category.icon, color: category.color),
        ),
        title: Text(
          category.name,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          isPredefined ? 'Predefinida' : 'Personalizada',
          style: TextStyle(
            fontSize: 12,
            color:
                isPredefined
                    ? Colors.grey
                    : Theme.of(context).colorScheme.primary,
          ),
        ),
        trailing:
            isPredefined
                ? null
                : PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert),
                  onSelected: (value) {
                    if (value == 'edit') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (_) => BlocProvider.value(
                                value: context.read<CategoryBloc>(),
                                child: AddCategoryPage(
                                  categoryToEdit: category,
                                ),
                              ),
                        ),
                      ).then((result) {
                        if (result == true && context.mounted) {
                          context.read<CategoryBloc>().add(
                            const LoadCategories(),
                          );
                        }
                      });
                    } else if (value == 'delete') {
                      _showDeleteDialog(context);
                    }
                  },
                  itemBuilder:
                      (context) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit, size: 20),
                              SizedBox(width: 12),
                              Text('Editar'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete, size: 20, color: Colors.red),
                              SizedBox(width: 12),
                              Text(
                                'Eliminar',
                                style: TextStyle(color: Colors.red),
                              ),
                            ],
                          ),
                        ),
                      ],
                ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            title: const Text('Eliminar Categoría'),
            content: Text(
              '¿Estás seguro de eliminar "${category.name}"?\n\n'
              'Los gastos asociados a esta categoría no se eliminarán, '
              'pero quedarán sin categoría válida.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(dialogContext);
                  context.read<CategoryBloc>().add(
                    DeleteCategoryEvent(category.id),
                  );
                },
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Eliminar'),
              ),
            ],
          ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/category.dart';
import '../blocs/category_bloc.dart';
import '../blocs/category_event.dart';

class AddCategoryPage extends StatefulWidget {
  final ExpenseCategory? categoryToEdit;

  const AddCategoryPage({super.key, this.categoryToEdit});

  @override
  State<AddCategoryPage> createState() => _AddCategoryPageState();
}

class _AddCategoryPageState extends State<AddCategoryPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _uuid = const Uuid();

  IconData _selectedIcon = Icons.category;
  Color _selectedColor = Colors.blue;

  bool get isEditing => widget.categoryToEdit != null;

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      _nameController.text = widget.categoryToEdit!.name;
      _selectedIcon = widget.categoryToEdit!.icon;
      _selectedColor = widget.categoryToEdit!.color;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Editar Categoría' : 'Nueva Categoría'),
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Preview Card
            Card(
              elevation: 0,
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Text(
                      'Vista Previa',
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                    const SizedBox(height: 16),
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: _selectedColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Icon(
                        _selectedIcon,
                        size: 40,
                        color: _selectedColor,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _nameController.text.isEmpty ? 'Nombre de categoría' : _nameController.text,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Nombre
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nombre de la categoría',
                hintText: 'Ej: Mascotas, Gimnasio, etc.',
                prefixIcon: Icon(Icons.label),
              ),
              textCapitalization: TextCapitalization.words,
              maxLength: 30,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Por favor ingresa un nombre';
                }
                if (value.trim().length < 2) {
                  return 'El nombre debe tener al menos 2 caracteres';
                }
                return null;
              },
              onChanged: (value) => setState(() {}),
            ),
            const SizedBox(height: 24),

            // Icono
            Text(
              'Icono',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            _IconSelector(
              selectedIcon: _selectedIcon,
              onIconSelected: (icon) {
                setState(() {
                  _selectedIcon = icon;
                });
              },
            ),
            const SizedBox(height: 24),

            // Color
            Text(
              'Color',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            _ColorSelector(
              selectedColor: _selectedColor,
              onColorSelected: (color) {
                setState(() {
                  _selectedColor = color;
                });
              },
            ),
            const SizedBox(height: 32),

            // Botón guardar
            FilledButton.icon(
              onPressed: _saveCategory,
              icon: Icon(isEditing ? Icons.save : Icons.add),
              label: Text(isEditing ? 'Guardar Cambios' : 'Crear Categoría'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.all(16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _saveCategory() {
    if (!_formKey.currentState!.validate()) return;

    final category = ExpenseCategory(
      id: isEditing ? widget.categoryToEdit!.id : _uuid.v4(),
      name: _nameController.text.trim(),
      icon: _selectedIcon,
      color: _selectedColor,
    );

    if (isEditing) {
      context.read<CategoryBloc>().add(UpdateCategoryEvent(category));
    } else {
      context.read<CategoryBloc>().add(CreateCategoryEvent(category));
    }

    Navigator.pop(context, true);
  }
}

class _IconSelector extends StatelessWidget {
  final IconData selectedIcon;
  final Function(IconData) onIconSelected;

  const _IconSelector({
    required this.selectedIcon,
    required this.onIconSelected,
  });

  static final List<IconData> _icons = [


    
    Icons.category,
    Icons.shopping_cart,
    Icons.local_cafe,
    Icons.fastfood,
    Icons.restaurant,
    Icons.local_pizza,
    Icons.sports_esports,
    Icons.sports_soccer,
    Icons.fitness_center,
    Icons.pets,
    Icons.flight,
    Icons.hotel,
    Icons.beach_access,
    Icons.celebration,
    Icons.card_giftcard,
    Icons.phone_android,
    Icons.computer,
    Icons.headphones,
    Icons.camera_alt,
    Icons.brush,
    Icons.palette,
    Icons.music_note,
    Icons.local_movies,
    Icons.menu_book,
    Icons.auto_stories,
    Icons.checkroom,
    Icons.watch,
    Icons.diamond,
    Icons.account_balance,
    Icons.savings,
    Icons.attach_money,
    Icons.medical_services,
    Icons.local_hospital,
    Icons.local_pharmacy,
  ];

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 6,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
          ),
          itemCount: _icons.length,
          itemBuilder: (context, index) {
            final icon = _icons[index];
            final isSelected = icon == selectedIcon;

            return InkWell(
              onTap: () => onIconSelected(icon),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected
                      ? Theme.of(context).colorScheme.primaryContainer
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : Colors.grey.withOpacity(0.3),
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Icon(
                  icon,
                  size: 24,
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Colors.grey[700],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ColorSelector extends StatelessWidget {
  final Color selectedColor;
  final Function(Color) onColorSelected;

  const _ColorSelector({
    required this.selectedColor,
    required this.onColorSelected,
  });

  static final List<Color> _colors = [
    Colors.red,
    Colors.pink,
    Colors.purple,
    Colors.deepPurple,
    Colors.indigo,
    Colors.blue,
    Colors.lightBlue,
    Colors.cyan,
    Colors.teal,
    Colors.green,
    Colors.lightGreen,
    Colors.lime,
    Colors.yellow,
    Colors.amber,
    Colors.orange,
    Colors.deepOrange,
    Colors.brown,
    Colors.grey,
    Colors.blueGrey,
  ];

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Wrap(
          spacing: 12,
          runSpacing: 12,
          children: _colors.map((color) {
            final isSelected = color == selectedColor;

            return InkWell(
              onTap: () => onColorSelected(color),
              borderRadius: BorderRadius.circular(25),
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? Colors.black : Colors.white,
                    width: isSelected ? 3 : 2,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: color.withOpacity(0.5),
                            blurRadius: 8,
                            spreadRadius: 2,
                          ),
                        ]
                      : null,
                ),
                child: isSelected
                    ? const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 30,
                      )
                    : null,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

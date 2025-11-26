import 'package:hive/hive.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/category_model.dart';

abstract class CategoryLocalDataSource {
  /// Obtiene todas las categorías (predefinidas y personalizadas)
  Future<List<CategoryModel>> getAllCategories();

  /// Obtiene una categoría por ID
  Future<CategoryModel?> getCategoryById(String id);

  /// Crea una nueva categoría personalizada
  Future<void> createCategory(CategoryModel category);

  /// Actualiza una categoría existente
  Future<void> updateCategory(CategoryModel category);

  /// Elimina una categoría personalizada
  /// Lanza excepción si intenta eliminar una categoría predefinida
  Future<void> deleteCategory(String id);

  /// Verifica si existen categorías en la base de datos
  Future<bool> hasCategories();
}

class CategoryLocalDataSourceImpl implements CategoryLocalDataSource {
  final Box<CategoryModel> categoryBox;

  CategoryLocalDataSourceImpl({required this.categoryBox});

  @override
  Future<List<CategoryModel>> getAllCategories() async {
    try {
      return categoryBox.values.toList();
    } catch (e) {
      throw CacheException(message: 'Error al obtener categorías: $e');
    }
  }

  @override
  Future<CategoryModel?> getCategoryById(String id) async {
    try {
      return categoryBox.values.firstWhere(
        (cat) => cat.id == id,
        orElse: () => throw Exception('No encontrada'),
      );
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> createCategory(CategoryModel category) async {
    try {
      // Verificar que no exista ya una categoría con ese ID
      final existing = await getCategoryById(category.id);
      if (existing != null) {
        throw CacheException(message: 'Ya existe una categoría con ese ID');
      }

      await categoryBox.add(category);
    } catch (e) {
      if (e is CacheException) rethrow;
      throw CacheException(message: 'Error al crear categoría: $e');
    }
  }

  @override
  Future<void> updateCategory(CategoryModel category) async {
    try {
      // Encontrar el índice de la categoría
      final index = categoryBox.values.toList().indexWhere(
        (cat) => cat.id == category.id,
      );

      if (index == -1) {
        throw CacheException(message: 'Categoría no encontrada');
      }

      await categoryBox.putAt(index, category);
    } catch (e) {
      if (e is CacheException) rethrow;
      throw CacheException(message: 'Error al actualizar categoría: $e');
    }
  }

  @override
  Future<void> deleteCategory(String id) async {
    try {
      // Verificar que sea una categoría personalizada
      final category = await getCategoryById(id);
      if (category == null) {
        throw CacheException(message: 'Categoría no encontrada');
      }

      if (!category.isCustom) {
        throw CacheException(
          message: 'No se pueden eliminar categorías predefinidas',
        );
      }

      // Encontrar el índice y eliminar
      final index = categoryBox.values.toList().indexWhere(
        (cat) => cat.id == id,
      );

      if (index != -1) {
        await categoryBox.deleteAt(index);
      }
    } catch (e) {
      if (e is CacheException) rethrow;
      throw CacheException(message: 'Error al eliminar categoría: $e');
    }
  }

  @override
  Future<bool> hasCategories() async {
    try {
      return categoryBox.isNotEmpty;
    } catch (e) {
      throw CacheException(message: 'Error al verificar categorías: $e');
    }
  }
}

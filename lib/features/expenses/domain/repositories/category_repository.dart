import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/category.dart';

abstract class CategoryRepository {
  /// Obtiene todas las categorías disponibles
  Future<Either<Failure, List<ExpenseCategory>>> getAllCategories();

  /// Obtiene una categoría por ID
  Future<Either<Failure, ExpenseCategory?>> getCategoryById(String id);

  /// Crea una nueva categoría personalizada
  Future<Either<Failure, void>> createCategory(ExpenseCategory category);

  /// Actualiza una categoría existente
  Future<Either<Failure, void>> updateCategory(ExpenseCategory category);

  /// Elimina una categoría personalizada
  Future<Either<Failure, void>> deleteCategory(String id);

  /// Inicializa las categorías predefinidas si no existen
  Future<Either<Failure, void>> initializeDefaultCategories();
}

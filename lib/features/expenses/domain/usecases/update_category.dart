import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/category.dart';
import '../repositories/category_repository.dart';

class UpdateCategory {
  final CategoryRepository repository;

  UpdateCategory(this.repository);

  Future<Either<Failure, void>> call(ExpenseCategory category) async {
    // Validaciones de negocio
    if (category.name.trim().isEmpty) {
      return Left(
        ValidationFailure(message: 'El nombre de la categoría es obligatorio'),
      );
    }

    if (category.name.trim().length < 2) {
      return Left(
        ValidationFailure(message: 'El nombre debe tener al menos 2 caracteres'),
      );
    }

    if (category.name.trim().length > 30) {
      return Left(
        ValidationFailure(message: 'El nombre no puede exceder 30 caracteres'),
      );
    }

    return await repository.updateCategory(category);
  }
}

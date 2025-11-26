import 'package:dartz/dartz.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/errors/failures.dart';
import '../entities/category.dart';
import '../repositories/category_repository.dart';

class CreateCategory {
  final CategoryRepository repository;
  final Uuid uuid;

  CreateCategory(this.repository, this.uuid);

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

    return await repository.createCategory(category);
  }
}

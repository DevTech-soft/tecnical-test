import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/category_repository.dart';

class DeleteCategory {
  final CategoryRepository repository;

  DeleteCategory(this.repository);

  Future<Either<Failure, void>> call(String categoryId) async {
    if (categoryId.trim().isEmpty) {
      return Left(
        ValidationFailure(message: 'El ID de la categoría no puede estar vacío'),
      );
    }

    return await repository.deleteCategory(categoryId);
  }
}

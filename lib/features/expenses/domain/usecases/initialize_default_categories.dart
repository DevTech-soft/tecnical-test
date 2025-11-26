import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/category_repository.dart';

class InitializeDefaultCategories {
  final CategoryRepository repository;

  InitializeDefaultCategories(this.repository);

  Future<Either<Failure, void>> call() async {
    return await repository.initializeDefaultCategories();
  }
}

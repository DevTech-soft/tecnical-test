import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../auth/domain/repositories/auth_repository.dart';
import '../../domain/entities/category.dart';
import '../../domain/repositories/category_repository.dart';
import '../datasources/category_local_datasource.dart';
import '../datasources/category_remote_datasource.dart';
import '../models/category_model.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  final CategoryLocalDataSource localDataSource;
  final CategoryRemoteDataSource remoteDataSource;
  final AuthRepository authRepository;

  CategoryRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
    required this.authRepository,
  });

  @override
  Future<Either<Failure, List<ExpenseCategory>>> getAllCategories() async {
    try {
      final user = authRepository.getCurrentUser();

      if (user != null) {
        try {
          // Obtener desde Firestore y sincronizar con local
          final remoteCategories = await remoteDataSource.getAllCategories(user.id);

          // Actualizar cache local - solo eliminar categorías personalizadas
          final localCategories = await localDataSource.getAllCategories();
          for (final localCat in localCategories) {
            // Solo eliminar categorías personalizadas
            if (localCat.isCustom) {
              await localDataSource.deleteCategory(localCat.id);
            }
          }

          // Agregar categorías remotas que no existan localmente
          for (final remoteCat in remoteCategories) {
            final exists = await localDataSource.getCategoryById(remoteCat.id);
            if (exists == null) {
              await localDataSource.createCategory(remoteCat);
            } else {
              // Actualizar categoría existente
              await localDataSource.updateCategory(remoteCat);
            }
          }

          return Right(remoteCategories.map((m) => m.toEntity()).toList());
        } on ServerException {
          // Si falla Firestore, usar datos locales
          final categories = await localDataSource.getAllCategories();
          return Right(categories.map((model) => model.toEntity()).toList());
        }
      } else {
        // Sin usuario autenticado, usar solo datos locales
        final categories = await localDataSource.getAllCategories();
        return Right(categories.map((model) => model.toEntity()).toList());
      }
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(UnexpectedFailure(message: 'Error inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, ExpenseCategory?>> getCategoryById(String id) async {
    try {
      final category = await localDataSource.getCategoryById(id);
      return Right(category?.toEntity());
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(UnexpectedFailure(message: 'Error inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> createCategory(ExpenseCategory category) async {
    try {
      // Validar nombre no vacío
      if (category.name.trim().isEmpty) {
        return Left(ValidationFailure(message: 'El nombre de la categoría no puede estar vacío'));
      }

      final model = CategoryModel.fromEntity(category, isCustom: true);

      // Guardar localmente (offline-first)
      await localDataSource.createCategory(model);

      // Sincronizar con Firestore si hay usuario autenticado
      final user = authRepository.getCurrentUser();
      if (user != null) {
        try {
          await remoteDataSource.createCategory(user.id, model);
        } catch (e) {
          // Continuar aunque falle la sincronización
        }
      }

      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(UnexpectedFailure(message: 'Error inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> updateCategory(ExpenseCategory category) async {
    try {
      // Validar nombre no vacío
      if (category.name.trim().isEmpty) {
        return Left(ValidationFailure(message: 'El nombre de la categoría no puede estar vacío'));
      }

      final existingModel = await localDataSource.getCategoryById(category.id);
      if (existingModel == null) {
        return Left(CacheFailure(message: 'Categoría no encontrada'));
      }

      final model = CategoryModel.fromEntity(category, isCustom: existingModel.isCustom);

      // Actualizar localmente (offline-first)
      await localDataSource.updateCategory(model);

      // Sincronizar con Firestore si hay usuario autenticado
      final user = authRepository.getCurrentUser();
      if (user != null) {
        try {
          await remoteDataSource.updateCategory(user.id, model);
        } catch (e) {
          // Continuar aunque falle la sincronización
        }
      }

      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(UnexpectedFailure(message: 'Error inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteCategory(String id) async {
    try {
      // Eliminar localmente (offline-first)
      await localDataSource.deleteCategory(id);

      // Sincronizar con Firestore si hay usuario autenticado
      final user = authRepository.getCurrentUser();
      if (user != null) {
        try {
          await remoteDataSource.deleteCategory(user.id, id);
        } catch (e) {
          // Continuar aunque falle la sincronización
        }
      }

      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(UnexpectedFailure(message: 'Error inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> initializeDefaultCategories() async {
    try {
      final user = authRepository.getCurrentUser();

      // Si hay usuario autenticado, primero intentar obtener desde Firestore
      if (user != null) {
        try {
          final remoteCategories = await remoteDataSource.getAllCategories(user.id);

          if (remoteCategories.isNotEmpty) {
            // Si hay categorías en Firestore, sincronizar con local
            final localCategories = await localDataSource.getAllCategories();
            for (final localCat in localCategories) {
              // Solo eliminar categorías personalizadas
              if (localCat.isCustom) {
                await localDataSource.deleteCategory(localCat.id);
              }
            }

            // Agregar o actualizar categorías remotas
            for (final remoteCat in remoteCategories) {
              final exists = await localDataSource.getCategoryById(remoteCat.id);
              if (exists == null) {
                await localDataSource.createCategory(remoteCat);
              } else {
                await localDataSource.updateCategory(remoteCat);
              }
            }
            return const Right(null);
          }
        } catch (e) {
          // Si falla Firestore, continuar con inicialización local
        }
      }

      // Verificar si ya existen categorías localmente
      final hasCategories = await localDataSource.hasCategories();
      if (hasCategories) {
        // Si hay categorías locales pero hay usuario autenticado, sincronizar a Firestore
        if (user != null) {
          try {
            final localCategories = await localDataSource.getAllCategories();
            for (final category in localCategories) {
              await remoteDataSource.createCategory(user.id, category);
            }
          } catch (e) {
            // Continuar aunque falle la sincronización
          }
        }
        return const Right(null);
      }

      // Crear las categorías predefinidas localmente
      final defaultCategories = CategoryHelper.defaultCategories;
      for (final category in defaultCategories) {
        final model = CategoryModel.fromEntity(category, isCustom: false);
        await localDataSource.createCategory(model);

        // Si hay usuario autenticado, también crear en Firestore
        if (user != null) {
          try {
            await remoteDataSource.createCategory(user.id, model);
          } catch (e) {
            // Continuar aunque falle la sincronización
          }
        }
      }

      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(UnexpectedFailure(message: 'Error inesperado: $e'));
    }
  }
}

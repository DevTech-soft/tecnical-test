import 'package:dayli_expenses/core/utils/app_logger.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/category.dart';
import '../../domain/usecases/create_category.dart';
import '../../domain/usecases/delete_category.dart';
import '../../domain/usecases/get_all_categories.dart';
import '../../domain/usecases/initialize_default_categories.dart';
import '../../domain/usecases/update_category.dart';
import 'category_event.dart';
import 'category_state.dart';

class CategoryBloc extends Bloc<CategoryEvent, CategoryState> {
  final GetAllCategories getAllCategories;
  final CreateCategory createCategory;
  final UpdateCategory updateCategory;
  final DeleteCategory deleteCategory;
  final InitializeDefaultCategories initializeDefaultCategories;
   final _logger = AppLogger('CategoryBloc');
  CategoryBloc({
    required this.getAllCategories,
    required this.createCategory,
    required this.updateCategory,
    required this.deleteCategory,
    required this.initializeDefaultCategories,
  }) : super(const CategoryInitial()) {
    on<LoadCategories>(_onLoadCategories);
    on<CreateCategoryEvent>(_onCreateCategory);
    on<UpdateCategoryEvent>(_onUpdateCategory);
    on<DeleteCategoryEvent>(_onDeleteCategory);
    on<InitializeDefaultCategoriesEvent>(_onInitializeDefaultCategories);
  }

  Future<void> _onLoadCategories(
    LoadCategories event,
    Emitter<CategoryState> emit,
  ) async {
    emit(const CategoryLoading());
    _logger.info('CategoryBloc: Cargando categorías');

    final result = await getAllCategories();

    result.fold(
      (failure) {
        _logger.error('CategoryBloc: Error al cargar categorías', failure.message);
        emit(CategoryError(failure.message));
      },
      (categories) {
        _logger.info('CategoryBloc: ${categories.length} categorías cargadas');
        // Actualizar CategoryHelper con todas las categorías cargadas
        CategoryHelper.updateLoadedCategories(categories);
        emit(CategoryLoaded(categories));
      },
    );
  }

  Future<void> _onCreateCategory(
    CreateCategoryEvent event,
    Emitter<CategoryState> emit,
  ) async {
    emit(const CategoryLoading());
    _logger.info('CategoryBloc: Creando categoría "${event.category.name}"');

    final result = await createCategory(event.category);

    await result.fold(
      (failure) async {
        _logger.error('CategoryBloc: Error al crear categoría',failure.message);
        emit(CategoryError(failure.message));
      },
      (_) async {
        _logger.info('CategoryBloc: Categoría creada exitosamente');

        // Recargar categorías
        final categoriesResult = await getAllCategories();
        categoriesResult.fold(
          (failure) => emit(CategoryError(failure.message)),
          (categories) {
            // Actualizar CategoryHelper con todas las categorías cargadas
            CategoryHelper.updateLoadedCategories(categories);
            emit(CategoryOperationSuccess(
              message: 'Categoría creada exitosamente',
              categories: categories,
            ));
          },
        );
      },
    );
  }

  Future<void> _onUpdateCategory(
    UpdateCategoryEvent event,
    Emitter<CategoryState> emit,
  ) async {
    emit(const CategoryLoading());
    _logger.info('CategoryBloc: Actualizando categoría "${event.category.name}"');

    final result = await updateCategory(event.category);

    await result.fold(
      (failure) async {
        _logger.error('CategoryBloc: Error al actualizar categoría', failure.message);
        emit(CategoryError(failure.message));
      },
      (_) async {
        _logger.info('CategoryBloc: Categoría actualizada exitosamente');

        // Recargar categorías
        final categoriesResult = await getAllCategories();
        categoriesResult.fold(
          (failure) => emit(CategoryError(failure.message)),
          (categories) {
            // Actualizar CategoryHelper con todas las categorías cargadas
            CategoryHelper.updateLoadedCategories(categories);
            emit(CategoryOperationSuccess(
              message: 'Categoría actualizada exitosamente',
              categories: categories,
            ));
          },
        );
      },
    );
  }

  Future<void> _onDeleteCategory(
    DeleteCategoryEvent event,
    Emitter<CategoryState> emit,
  ) async {
    emit(const CategoryLoading());
    _logger.info('CategoryBloc: Eliminando categoría');

    final result = await deleteCategory(event.categoryId);

    await result.fold(
      (failure) async {
        _logger.error('CategoryBloc: Error al eliminar categoría',  failure.message);
        emit(CategoryError(failure.message));
      },
      (_) async {
        _logger.info('CategoryBloc: Categoría eliminada exitosamente');

        // Recargar categorías
        final categoriesResult = await getAllCategories();
        categoriesResult.fold(
          (failure) => emit(CategoryError(failure.message)),
          (categories) {
            // Actualizar CategoryHelper con todas las categorías cargadas
            CategoryHelper.updateLoadedCategories(categories);
            emit(CategoryOperationSuccess(
              message: 'Categoría eliminada exitosamente',
              categories: categories,
            ));
          },
        );
      },
    );
  }

  Future<void> _onInitializeDefaultCategories(
    InitializeDefaultCategoriesEvent event,
    Emitter<CategoryState> emit,
  ) async {
    _logger.info('CategoryBloc: Inicializando categorías predefinidas');

    final result = await initializeDefaultCategories();

    await result.fold(
      (failure) async {
        _logger.error('CategoryBloc: Error al inicializar categorías',  failure.message);
        emit(CategoryError(failure.message));
      },
      (_) async {
        _logger.info('CategoryBloc: Categorías inicializadas exitosamente');

        // Cargar categorías
        add(const LoadCategories());
      },
    );
  }
}

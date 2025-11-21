import 'package:equatable/equatable.dart';

/// Clase base abstracta para todos los fallos en la aplicación.
/// Usa Equatable para facilitar comparaciones y testing.
abstract class Failure extends Equatable {
  final String message;
  final String? code;
  final dynamic details;

  const Failure({
    required this.message,
    this.code,
    this.details,
  });

  @override
  List<Object?> get props => [message, code, details];

  @override
  String toString() => 'Failure: $message${code != null ? ' (Code: $code)' : ''}';
}

/// Fallo relacionado con operaciones de caché/almacenamiento local.
class CacheFailure extends Failure {
  const CacheFailure({
    required super.message,
    super.code,
    super.details,
  });

  factory CacheFailure.read() => const CacheFailure(
        message: 'Error al leer datos del almacenamiento local',
        code: 'CACHE_READ_ERROR',
      );

  factory CacheFailure.write() => const CacheFailure(
        message: 'Error al guardar datos en el almacenamiento local',
        code: 'CACHE_WRITE_ERROR',
      );

  factory CacheFailure.delete() => const CacheFailure(
        message: 'Error al eliminar datos del almacenamiento local',
        code: 'CACHE_DELETE_ERROR',
      );

  factory CacheFailure.notFound() => const CacheFailure(
        message: 'Datos no encontrados',
        code: 'CACHE_NOT_FOUND',
      );

  factory CacheFailure.corrupted() => const CacheFailure(
        message: 'Los datos almacenados están corruptos',
        code: 'CACHE_CORRUPTED',
      );
}

/// Fallo relacionado con validación de datos de entrada.
class ValidationFailure extends Failure {
  const ValidationFailure({
    required super.message,
    super.code,
    super.details,
  });

  factory ValidationFailure.invalidAmount() => const ValidationFailure(
        message: 'El monto debe ser mayor a cero',
        code: 'INVALID_AMOUNT',
      );

  factory ValidationFailure.amountTooLarge() => const ValidationFailure(
        message: 'El monto es demasiado grande',
        code: 'AMOUNT_TOO_LARGE',
      );

  factory ValidationFailure.invalidDate() => const ValidationFailure(
        message: 'La fecha no es válida',
        code: 'INVALID_DATE',
      );

  factory ValidationFailure.futureDate() => const ValidationFailure(
        message: 'La fecha no puede ser futura',
        code: 'FUTURE_DATE',
      );

  factory ValidationFailure.emptyField(String fieldName) => ValidationFailure(
        message: 'El campo "$fieldName" no puede estar vacío',
        code: 'EMPTY_FIELD',
        details: fieldName,
      );

  factory ValidationFailure.invalidCategory() => const ValidationFailure(
        message: 'La categoría seleccionada no es válida',
        code: 'INVALID_CATEGORY',
      );

  factory ValidationFailure.budgetPeriodInvalid() => const ValidationFailure(
        message: 'El período del presupuesto no es válido',
        code: 'INVALID_BUDGET_PERIOD',
      );

  factory ValidationFailure.budgetAmountInvalid() => const ValidationFailure(
        message: 'El monto del presupuesto debe ser mayor a cero',
        code: 'INVALID_BUDGET_AMOUNT',
      );
}

/// Fallo relacionado con conexión al servidor (para futuro uso con sincronización).
class ServerFailure extends Failure {
  const ServerFailure({
    required super.message,
    super.code,
    super.details,
  });

  factory ServerFailure.noConnection() => const ServerFailure(
        message: 'No hay conexión a internet',
        code: 'NO_CONNECTION',
      );

  factory ServerFailure.timeout() => const ServerFailure(
        message: 'El servidor no respondió a tiempo',
        code: 'TIMEOUT',
      );

  factory ServerFailure.unauthorized() => const ServerFailure(
        message: 'No autorizado',
        code: 'UNAUTHORIZED',
      );

  factory ServerFailure.notFound() => const ServerFailure(
        message: 'Recurso no encontrado',
        code: 'NOT_FOUND',
      );

  factory ServerFailure.internal() => const ServerFailure(
        message: 'Error interno del servidor',
        code: 'INTERNAL_ERROR',
      );
}

/// Fallo genérico para errores no categorizados.
class UnexpectedFailure extends Failure {
  const UnexpectedFailure({
    required super.message,
    super.code,
    super.details,
  });

  factory UnexpectedFailure.fromException(Exception e) => UnexpectedFailure(
        message: 'Error inesperado: ${e.toString()}',
        code: 'UNEXPECTED_ERROR',
        details: e,
      );

  factory UnexpectedFailure.fromError(Error e) => UnexpectedFailure(
        message: 'Error inesperado: ${e.toString()}',
        code: 'UNEXPECTED_ERROR',
        details: e,
      );

  factory UnexpectedFailure.unknown() => const UnexpectedFailure(
        message: 'Ocurrió un error desconocido',
        code: 'UNKNOWN_ERROR',
      );
}

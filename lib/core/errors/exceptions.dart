/// Excepción base para todas las excepciones de la aplicación.
abstract class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic details;

  const AppException({
    required this.message,
    this.code,
    this.details,
  });

  @override
  String toString() => 'AppException: $message${code != null ? ' (Code: $code)' : ''}';
}

/// Excepción lanzada cuando hay un error en operaciones de caché.
class CacheException extends AppException {
  const CacheException({
    required super.message,
    super.code,
    super.details,
  });

  factory CacheException.read() => const CacheException(
        message: 'Failed to read from cache',
        code: 'CACHE_READ_ERROR',
      );

  factory CacheException.write() => const CacheException(
        message: 'Failed to write to cache',
        code: 'CACHE_WRITE_ERROR',
      );

  factory CacheException.delete() => const CacheException(
        message: 'Failed to delete from cache',
        code: 'CACHE_DELETE_ERROR',
      );

  factory CacheException.notFound() => const CacheException(
        message: 'Data not found in cache',
        code: 'CACHE_NOT_FOUND',
      );

  factory CacheException.corrupted() => const CacheException(
        message: 'Cached data is corrupted',
        code: 'CACHE_CORRUPTED',
      );
}

/// Excepción lanzada cuando los datos de entrada no son válidos.
class ValidationException extends AppException {
  const ValidationException({
    required super.message,
    super.code,
    super.details,
  });

  factory ValidationException.invalidAmount() => const ValidationException(
        message: 'Amount must be greater than zero',
        code: 'INVALID_AMOUNT',
      );

  factory ValidationException.amountTooLarge() => const ValidationException(
        message: 'Amount is too large',
        code: 'AMOUNT_TOO_LARGE',
      );

  factory ValidationException.invalidDate() => const ValidationException(
        message: 'Invalid date',
        code: 'INVALID_DATE',
      );

  factory ValidationException.futureDate() => const ValidationException(
        message: 'Date cannot be in the future',
        code: 'FUTURE_DATE',
      );

  factory ValidationException.emptyField(String fieldName) => ValidationException(
        message: 'Field "$fieldName" cannot be empty',
        code: 'EMPTY_FIELD',
        details: fieldName,
      );

  factory ValidationException.invalidCategory() => const ValidationException(
        message: 'Invalid category',
        code: 'INVALID_CATEGORY',
      );
}

/// Excepción lanzada cuando hay un error en operaciones del servidor.
/// (Para futuro uso con sincronización en la nube)
class ServerException extends AppException {
  final int? statusCode;

  const ServerException({
    required super.message,
    super.code,
    super.details,
    this.statusCode,
  });

  factory ServerException.noConnection() => const ServerException(
        message: 'No internet connection',
        code: 'NO_CONNECTION',
      );

  factory ServerException.timeout() => const ServerException(
        message: 'Server timeout',
        code: 'TIMEOUT',
      );

  factory ServerException.unauthorized() => const ServerException(
        message: 'Unauthorized',
        code: 'UNAUTHORIZED',
        statusCode: 401,
      );

  factory ServerException.notFound() => const ServerException(
        message: 'Resource not found',
        code: 'NOT_FOUND',
        statusCode: 404,
      );

  factory ServerException.internal() => const ServerException(
        message: 'Internal server error',
        code: 'INTERNAL_ERROR',
        statusCode: 500,
      );
}

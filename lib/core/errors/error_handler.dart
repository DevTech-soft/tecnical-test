import 'exceptions.dart';
import 'failures.dart';

/// Clase utilitaria para manejar errores y convertir excepciones en failures.
class ErrorHandler {
  /// Convierte una excepción en un Failure apropiado.
  static Failure handleException(Object error) {
    if (error is CacheException) {
      return CacheFailure(
        message: _getSpanishMessage(error.message),
        code: error.code,
        details: error.details,
      );
    } else if (error is ValidationException) {
      return ValidationFailure(
        message: _getSpanishMessage(error.message),
        code: error.code,
        details: error.details,
      );
    } else if (error is ServerException) {
      return ServerFailure(
        message: _getSpanishMessage(error.message),
        code: error.code,
        details: error.details,
      );
    } else if (error is Exception) {
      return UnexpectedFailure.fromException(error);
    } else if (error is Error) {
      return UnexpectedFailure.fromError(error);
    } else {
      return UnexpectedFailure(
        message: 'Error desconocido: ${error.toString()}',
        code: 'UNKNOWN',
        details: error,
      );
    }
  }

  /// Obtiene un mensaje amigable para el usuario basado en el tipo de failure.
  static String getUserFriendlyMessage(Failure failure) {
    // Si el failure ya tiene un mensaje en español, usarlo
    if (failure is CacheFailure ||
        failure is ValidationFailure ||
        failure is ServerFailure) {
      return failure.message;
    }

    // Para errores inesperados, mostrar un mensaje genérico
    if (failure is UnexpectedFailure) {
      return 'Ocurrió un error inesperado. Por favor, intenta de nuevo.';
    }

    return failure.message;
  }

  /// Convierte mensajes de error en inglés a español.
  static String _getSpanishMessage(String message) {
    final translations = {
      'Failed to read from cache': 'Error al leer datos del almacenamiento local',
      'Failed to write to cache': 'Error al guardar datos',
      'Failed to delete from cache': 'Error al eliminar datos',
      'Data not found in cache': 'Datos no encontrados',
      'Cached data is corrupted': 'Los datos están corruptos',
      'Amount must be greater than zero': 'El monto debe ser mayor a cero',
      'Amount is too large': 'El monto es demasiado grande',
      'Invalid date': 'La fecha no es válida',
      'Date cannot be in the future': 'La fecha no puede ser futura',
      'Invalid category': 'La categoría no es válida',
      'No internet connection': 'No hay conexión a internet',
      'Server timeout': 'El servidor no respondió a tiempo',
      'Unauthorized': 'No autorizado',
      'Resource not found': 'Recurso no encontrado',
      'Internal server error': 'Error interno del servidor',
    };

    return translations[message] ?? message;
  }

  /// Determina si un error es recuperable o crítico.
  static bool isRecoverable(Failure failure) {
    // Errores de validación son recuperables (el usuario puede corregir)
    if (failure is ValidationFailure) return true;

    // Errores de conexión son recuperables (puede volver a intentar)
    if (failure is ServerFailure) {
      return failure.code == 'NO_CONNECTION' || failure.code == 'TIMEOUT';
    }

    // Errores de caché dependen del tipo
    if (failure is CacheFailure) {
      return failure.code != 'CACHE_CORRUPTED';
    }

    // Errores inesperados generalmente no son recuperables
    return false;
  }

  /// Obtiene un título sugerido para el error según su severidad.
  static String getErrorTitle(Failure failure) {
    if (failure is ValidationFailure) {
      return 'Datos inválidos';
    } else if (failure is CacheFailure) {
      return 'Error de almacenamiento';
    } else if (failure is ServerFailure) {
      return 'Error de conexión';
    } else {
      return 'Error';
    }
  }
}

import 'package:flutter/foundation.dart';

/// Niveles de log disponibles.
enum LogLevel {
  debug,
  info,
  warning,
  error,
  fatal,
}

/// Logger centralizado para la aplicación.
///
/// En modo debug, imprime todos los logs en consola con colores.
/// En modo release, solo registra errores y fatales.
class AppLogger {
  final String className;

  AppLogger(this.className);

  /// Log de debug - Solo en modo debug
  void debug(String message, [dynamic data]) {
    _log(LogLevel.debug, message, data);
  }

  /// Log informativo
  void info(String message, [dynamic data]) {
    _log(LogLevel.info, message, data);
  }

  /// Log de advertencia
  void warning(String message, [dynamic data]) {
    _log(LogLevel.warning, message, data);
  }

  /// Log de error
  void error(String message, [dynamic error, StackTrace? stackTrace]) {
    _log(LogLevel.error, message, error, stackTrace: stackTrace);
  }

  /// Log de error fatal
  void fatal(String message, [dynamic error, StackTrace? stackTrace]) {
    _log(LogLevel.fatal, message, error, stackTrace: stackTrace);
  }

  void _log(
    LogLevel level,
    String message,
    dynamic data, {
    StackTrace? stackTrace,
  }) {
    // En modo release, solo mostrar errores y fatales
    if (kReleaseMode && level != LogLevel.error && level != LogLevel.fatal) {
      return;
    }

    final timestamp = DateTime.now().toIso8601String();
    final levelStr = _getLevelString(level);
    final emoji = _getEmoji(level);

    // Construir mensaje
    final buffer = StringBuffer();
    buffer.writeln('$emoji [$timestamp] [$levelStr] [$className]');
    buffer.writeln('  Message: $message');

    if (data != null) {
      buffer.writeln('  Data: ${_formatData(data)}');
    }

    if (stackTrace != null) {
      buffer.writeln('  StackTrace:');
      buffer.writeln(_formatStackTrace(stackTrace));
    }

    // Imprimir con color según nivel
    _printWithColor(level, buffer.toString());
  }

  String _getLevelString(LogLevel level) {
    switch (level) {
      case LogLevel.debug:
        return 'DEBUG';
      case LogLevel.info:
        return 'INFO ';
      case LogLevel.warning:
        return 'WARN ';
      case LogLevel.error:
        return 'ERROR';
      case LogLevel.fatal:
        return 'FATAL';
    }
  }

  String _getEmoji(LogLevel level) {
    switch (level) {
      case LogLevel.debug:
        return '🔍';
      case LogLevel.info:
        return 'ℹ️';
      case LogLevel.warning:
        return '⚠️';
      case LogLevel.error:
        return '❌';
      case LogLevel.fatal:
        return '💀';
    }
  }

  String _formatData(dynamic data) {
    if (data is Map) {
      return data.entries.map((e) => '${e.key}: ${e.value}').join(', ');
    } else if (data is List) {
      return data.toString();
    } else if (data is Exception) {
      return 'Exception: ${data.toString()}';
    } else if (data is Error) {
      return 'Error: ${data.toString()}';
    }
    return data.toString();
  }

  String _formatStackTrace(StackTrace stackTrace) {
    final lines = stackTrace.toString().split('\n');
    // Tomar solo las primeras 5 líneas para no saturar el log
    final relevantLines = lines.take(5).map((line) => '    $line').join('\n');
    return relevantLines;
  }

  void _printWithColor(LogLevel level, String message) {
    // Códigos ANSI para colores en terminal
    const reset = '\x1B[0m';
    const red = '\x1B[31m';
    const yellow = '\x1B[33m';
    const blue = '\x1B[34m';
    const gray = '\x1B[90m';
    const magenta = '\x1B[35m';

    String color;
    switch (level) {
      case LogLevel.debug:
        color = gray;
        break;
      case LogLevel.info:
        color = blue;
        break;
      case LogLevel.warning:
        color = yellow;
        break;
      case LogLevel.error:
        color = red;
        break;
      case LogLevel.fatal:
        color = magenta;
        break;
    }

    // En modo debug, usar colores. En release, sin colores
    if (kDebugMode) {
      debugPrint('$color$message$reset');
    } else {
      debugPrint(message);
    }
  }
}

/// Logger global para uso en toda la app
class Logger {
  static final Map<String, AppLogger> _loggers = {};

  /// Obtiene o crea un logger para la clase especificada
  static AppLogger get(String className) {
    return _loggers.putIfAbsent(className, () => AppLogger(className));
  }

  /// Crea un logger desde el tipo de una clase
  static AppLogger getFromType(Type type) {
    return get(type.toString());
  }
}

/// Extension para facilitar el logging en BLoCs y otros
extension LoggerExtension on Object {
  AppLogger get logger => Logger.getFromType(runtimeType);
}

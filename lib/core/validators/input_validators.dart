import '../errors/exceptions.dart';

/// Clase que contiene validadores para diferentes tipos de entrada.
class InputValidators {
  // Constantes de validación
  static const double maxAmount = 999999999.99; // ~1 billón
  static const double minAmount = 0.01;
  static const int maxNoteLength = 500;
  static const int maxCategoryNameLength = 50;

  /// Valida un monto de dinero.
  ///
  /// Lanza [ValidationException] si:
  /// - El monto es menor o igual a cero
  /// - El monto es mayor al límite establecido
  /// - El monto tiene más de 2 decimales
  static void validateAmount(double amount) {
    if (amount <= 0) {
      throw ValidationException.invalidAmount();
    }

    if (amount > maxAmount) {
      throw ValidationException.amountTooLarge();
    }

    // Verificar que no tenga más de 2 decimales
    final amountString = amount.toStringAsFixed(2);
    final reconstructed = double.parse(amountString);
    if ((amount - reconstructed).abs() > 0.001) {
      throw const ValidationException(
        message: 'El monto no puede tener más de 2 decimales',
        code: 'TOO_MANY_DECIMALS',
      );
    }
  }

  /// Valida que un monto esté dentro de un rango específico.
  static void validateAmountInRange(
    double amount, {
    required double min,
    required double max,
  }) {
    if (amount < min || amount > max) {
      throw ValidationException(
        message: 'El monto debe estar entre \$$min y \$$max',
        code: 'AMOUNT_OUT_OF_RANGE',
        details: {'amount': amount, 'min': min, 'max': max},
      );
    }
  }

  /// Valida una fecha.
  ///
  /// Lanza [ValidationException] si:
  /// - La fecha es futura (para gastos)
  /// - La fecha es null
  static void validateDate(DateTime? date, {bool allowFuture = false}) {
    if (date == null) {
      throw ValidationException.invalidDate();
    }

    if (!allowFuture && date.isAfter(DateTime.now())) {
      throw ValidationException.futureDate();
    }

    // Validar que la fecha no sea demasiado antigua (ej: más de 10 años)
    final tenYearsAgo = DateTime.now().subtract(const Duration(days: 365 * 10));
    if (date.isBefore(tenYearsAgo)) {
      throw const ValidationException(
        message: 'La fecha no puede ser mayor a 10 años en el pasado',
        code: 'DATE_TOO_OLD',
      );
    }
  }

  /// Valida que una fecha esté dentro de un rango.
  static void validateDateInRange(
    DateTime date, {
    DateTime? minDate,
    DateTime? maxDate,
  }) {
    if (minDate != null && date.isBefore(minDate)) {
      throw ValidationException(
        message: 'La fecha debe ser posterior a ${minDate.toLocal()}',
        code: 'DATE_BEFORE_MIN',
        details: {'date': date, 'minDate': minDate},
      );
    }

    if (maxDate != null && date.isAfter(maxDate)) {
      throw ValidationException(
        message: 'La fecha debe ser anterior a ${maxDate.toLocal()}',
        code: 'DATE_AFTER_MAX',
        details: {'date': date, 'maxDate': maxDate},
      );
    }
  }

  /// Valida y sanitiza un texto (notas, nombres, etc.).
  ///
  /// Lanza [ValidationException] si:
  /// - El texto está vacío cuando es requerido
  /// - El texto excede la longitud máxima
  ///
  /// Retorna el texto sanitizado (trimmed).
  static String validateAndSanitizeText(
    String? text, {
    required String fieldName,
    bool required = true,
    int? maxLength,
  }) {
    // Sanitizar: eliminar espacios al inicio y final
    final sanitized = text?.trim() ?? '';

    // Validar si es requerido
    if (required && sanitized.isEmpty) {
      throw ValidationException.emptyField(fieldName);
    }

    // Validar longitud máxima
    final maxLen = maxLength ?? maxNoteLength;
    if (sanitized.length > maxLen) {
      throw ValidationException(
        message: 'El campo "$fieldName" no puede tener más de $maxLen caracteres',
        code: 'TEXT_TOO_LONG',
        details: {
          'fieldName': fieldName,
          'maxLength': maxLen,
          'currentLength': sanitized.length,
        },
      );
    }

    return sanitized;
  }

  /// Valida que un texto no contenga caracteres especiales peligrosos.
  static String sanitizeForSecurity(String text) {
    // Eliminar caracteres de control y caracteres no imprimibles
    return text.replaceAll(RegExp(r'[\x00-\x1F\x7F]'), '');
  }

  /// Valida un ID de categoría.
  static void validateCategoryId(String? categoryId) {
    if (categoryId == null || categoryId.trim().isEmpty) {
      throw ValidationException.invalidCategory();
    }
  }

  /// Valida parámetros de período de presupuesto.
  static void validateBudgetPeriod({
    required int month,
    required int year,
  }) {
    if (month < 1 || month > 12) {
      throw const ValidationException(
        message: 'El mes debe estar entre 1 y 12',
        code: 'INVALID_MONTH',
      );
    }

    final currentYear = DateTime.now().year;
    if (year < currentYear - 5 || year > currentYear + 5) {
      throw ValidationException(
        message: 'El año debe estar entre ${currentYear - 5} y ${currentYear + 5}',
        code: 'INVALID_YEAR',
      );
    }
  }

  /// Valida que un presupuesto tenga valores válidos.
  static void validateBudget({
    required double amount,
    required int month,
    required int year,
    String? categoryId,
  }) {
    validateAmount(amount);
    validateBudgetPeriod(month: month, year: year);

    if (categoryId != null && categoryId.isNotEmpty) {
      validateCategoryId(categoryId);
    }
  }

  /// Valida un email (para futuro uso).
  static bool isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }

  /// Valida que un string sea un UUID válido.
  static bool isValidUUID(String uuid) {
    final uuidRegex = RegExp(
      r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
    );
    return uuidRegex.hasMatch(uuid);
  }
}

/// Validadores específicos para formularios de Flutter.
class FormValidators {
  /// Validador de monto para TextFormField.
  static String? amountValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'El monto es requerido';
    }

    final amount = double.tryParse(value);
    if (amount == null) {
      return 'Ingrese un monto válido';
    }

    try {
      InputValidators.validateAmount(amount);
      return null; // Sin errores
    } on ValidationException catch (e) {
      return e.message;
    }
  }

  /// Validador de texto para TextFormField.
  static String? Function(String?) textValidator({
    required String fieldName,
    bool required = true,
    int? maxLength,
  }) {
    return (String? value) {
      try {
        InputValidators.validateAndSanitizeText(
          value,
          fieldName: fieldName,
          required: required,
          maxLength: maxLength,
        );
        return null; // Sin errores
      } on ValidationException catch (e) {
        return e.message;
      }
    };
  }

  /// Validador de email para TextFormField.
  static String? emailValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'El email es requerido';
    }

    if (!InputValidators.isValidEmail(value)) {
      return 'Ingrese un email válido';
    }

    return null;
  }

  /// Validador de fecha para DatePicker.
  static String? dateValidator(DateTime? date, {bool allowFuture = false}) {
    try {
      InputValidators.validateDate(date, allowFuture: allowFuture);
      return null; // Sin errores
    } on ValidationException catch (e) {
      return e.message;
    }
  }
}

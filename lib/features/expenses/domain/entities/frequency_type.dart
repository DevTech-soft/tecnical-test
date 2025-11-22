import 'package:equatable/equatable.dart';

/// Tipo de frecuencia para gastos recurrentes
enum FrequencyType {
  /// Diario (cada día)
  daily,

  /// Semanal (cada 7 días)
  weekly,

  /// Quincenal (cada 14 días)
  biweekly,

  /// Mensual (cada mes)
  monthly,

  /// Bimestral (cada 2 meses)
  bimonthly,

  /// Trimestral (cada 3 meses)
  quarterly,

  /// Semestral (cada 6 meses)
  semiannual,

  /// Anual (cada 12 meses)
  annual,
}

/// Extensión para obtener información de cada frecuencia
extension FrequencyTypeX on FrequencyType {
  /// Nombre legible en español
  String get displayName {
    switch (this) {
      case FrequencyType.daily:
        return 'Diario';
      case FrequencyType.weekly:
        return 'Semanal';
      case FrequencyType.biweekly:
        return 'Quincenal';
      case FrequencyType.monthly:
        return 'Mensual';
      case FrequencyType.bimonthly:
        return 'Bimestral';
      case FrequencyType.quarterly:
        return 'Trimestral';
      case FrequencyType.semiannual:
        return 'Semestral';
      case FrequencyType.annual:
        return 'Anual';
    }
  }

  /// Descripción de la frecuencia
  String get description {
    switch (this) {
      case FrequencyType.daily:
        return 'Se genera cada día';
      case FrequencyType.weekly:
        return 'Se genera cada semana';
      case FrequencyType.biweekly:
        return 'Se genera cada 2 semanas';
      case FrequencyType.monthly:
        return 'Se genera cada mes';
      case FrequencyType.bimonthly:
        return 'Se genera cada 2 meses';
      case FrequencyType.quarterly:
        return 'Se genera cada 3 meses';
      case FrequencyType.semiannual:
        return 'Se genera cada 6 meses';
      case FrequencyType.annual:
        return 'Se genera cada año';
    }
  }

  /// Días aproximados de la frecuencia (para cálculos)
  int get approximateDays {
    switch (this) {
      case FrequencyType.daily:
        return 1;
      case FrequencyType.weekly:
        return 7;
      case FrequencyType.biweekly:
        return 14;
      case FrequencyType.monthly:
        return 30;
      case FrequencyType.bimonthly:
        return 60;
      case FrequencyType.quarterly:
        return 90;
      case FrequencyType.semiannual:
        return 180;
      case FrequencyType.annual:
        return 365;
    }
  }

  /// Calcula la próxima fecha de generación desde una fecha dada
  DateTime nextDate(DateTime from) {
    switch (this) {
      case FrequencyType.daily:
        return DateTime(from.year, from.month, from.day + 1);
      case FrequencyType.weekly:
        return DateTime(from.year, from.month, from.day + 7);
      case FrequencyType.biweekly:
        return DateTime(from.year, from.month, from.day + 14);
      case FrequencyType.monthly:
        return DateTime(from.year, from.month + 1, from.day);
      case FrequencyType.bimonthly:
        return DateTime(from.year, from.month + 2, from.day);
      case FrequencyType.quarterly:
        return DateTime(from.year, from.month + 3, from.day);
      case FrequencyType.semiannual:
        return DateTime(from.year, from.month + 6, from.day);
      case FrequencyType.annual:
        return DateTime(from.year + 1, from.month, from.day);
    }
  }

  /// Verifica si debe generarse un gasto en base a la última fecha generada
  bool shouldGenerate(DateTime lastGenerated, DateTime now) {
    final next = nextDate(lastGenerated);
    return now.isAfter(next) || now.isAtSameMomentAs(next);
  }
}

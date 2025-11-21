part of 'export_bloc.dart';

abstract class ExportState extends Equatable {
  const ExportState();

  @override
  List<Object?> get props => [];
}

/// Estado inicial
class ExportInitial extends ExportState {
  const ExportInitial();
}

/// Estado de carga/exportando
class ExportLoading extends ExportState {
  final String message;

  const ExportLoading({required this.message});

  @override
  List<Object?> get props => [message];
}

/// Estado cuando la exportación fue exitosa
class ExportSuccess extends ExportState {
  final String filePath;
  final String message;

  const ExportSuccess({
    required this.filePath,
    required this.message,
  });

  @override
  List<Object?> get props => [filePath, message];
}

/// Estado cuando la importación fue exitosa
class ImportSuccess extends ExportState {
  final List<Map<String, dynamic>> importedData;
  final String message;

  const ImportSuccess({
    required this.importedData,
    required this.message,
  });

  @override
  List<Object?> get props => [importedData, message];
}

/// Estado cuando el archivo se compartió exitosamente
class ShareSuccess extends ExportState {
  final String message;

  const ShareSuccess({required this.message});

  @override
  List<Object?> get props => [message];
}

/// Estado de error
class ExportError extends ExportState {
  final Failure failure;

  const ExportError({required this.failure});

  /// Mensaje amigable para el usuario
  String get userMessage => ErrorHandler.getUserFriendlyMessage(failure);

  /// Título del error
  String get title => ErrorHandler.getErrorTitle(failure);

  /// Indica si el error es recuperable
  bool get isRecoverable => ErrorHandler.isRecoverable(failure);

  @override
  List<Object?> get props => [failure];
}

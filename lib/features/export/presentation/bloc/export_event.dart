part of 'export_bloc.dart';

abstract class ExportEvent extends Equatable {
  const ExportEvent();

  @override
  List<Object?> get props => [];
}

/// Evento para exportar gastos a CSV
class ExportToCsvEvent extends ExportEvent {
  final List<Expense> expenses;
  final Map<String, Category> categories;
  final String? fileName;

  const ExportToCsvEvent({
    required this.expenses,
    required this.categories,
    this.fileName,
  });

  @override
  List<Object?> get props => [expenses, categories, fileName];
}

/// Evento para exportar gastos a PDF
class ExportToPdfEvent extends ExportEvent {
  final List<Expense> expenses;
  final Map<String, Category> categories;
  final DateTime startDate;
  final DateTime endDate;
  final String? fileName;

  const ExportToPdfEvent({
    required this.expenses,
    required this.categories,
    required this.startDate,
    required this.endDate,
    this.fileName,
  });

  @override
  List<Object?> get props => [expenses, categories, startDate, endDate, fileName];
}

/// Evento para compartir un archivo exportado
class ShareFileEvent extends ExportEvent {
  final String filePath;
  final String? subject;

  const ShareFileEvent({
    required this.filePath,
    this.subject,
  });

  @override
  List<Object?> get props => [filePath, subject];
}

/// Evento para importar gastos desde CSV
class ImportFromCsvEvent extends ExportEvent {
  final String filePath;

  const ImportFromCsvEvent(this.filePath);

  @override
  List<Object?> get props => [filePath];
}

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/errors/error_handler.dart';
import '../../../../core/errors/failures.dart';
import '../../../expenses/domain/entities/category.dart';
import '../../../expenses/domain/entities/expense.dart';
import '../../domain/usecases/export_expenses_csv.dart';
import '../../domain/usecases/export_expenses_pdf.dart';
import '../../domain/usecases/import_expenses_csv.dart';
import '../../domain/usecases/share_export.dart';

part 'export_event.dart';
part 'export_state.dart';

class ExportBloc extends Bloc<ExportEvent, ExportState> {
  final ExportExpensesCsv exportExpensesCsv;
  final ExportExpensesPdf exportExpensesPdf;
  final ShareExport shareExport;
  final ImportExpensesCsv importExpensesCsv;

  ExportBloc({
    required this.exportExpensesCsv,
    required this.exportExpensesPdf,
    required this.shareExport,
    required this.importExpensesCsv,
  }) : super(const ExportInitial()) {
    on<ExportToCsvEvent>(_onExportToCsv);
    on<ExportToPdfEvent>(_onExportToPdf);
    on<ShareFileEvent>(_onShareFile);
    on<ImportFromCsvEvent>(_onImportFromCsv);
  }

  Future<void> _onExportToCsv(
    ExportToCsvEvent event,
    Emitter<ExportState> emit,
  ) async {
    try {
      emit(const ExportLoading(message: 'Exportando a CSV...'));

      final filePath = await exportExpensesCsv(
        ExportExpensesCsvParams(
          expenses: event.expenses,
          categories: event.categories,
          fileName: event.fileName,
        ),
      );

      emit(ExportSuccess(
        filePath: filePath,
        message: 'Gastos exportados exitosamente a CSV',
      ));
    } catch (error) {
      final failure = ErrorHandler.handleException(error);
      emit(ExportError(failure: failure));
    }
  }

  Future<void> _onExportToPdf(
    ExportToPdfEvent event,
    Emitter<ExportState> emit,
  ) async {
    try {
      emit(const ExportLoading(message: 'Generando PDF...'));

      final filePath = await exportExpensesPdf(
        ExportExpensesPdfParams(
          expenses: event.expenses,
          categories: event.categories,
          startDate: event.startDate,
          endDate: event.endDate,
          fileName: event.fileName,
        ),
      );

      emit(ExportSuccess(
        filePath: filePath,
        message: 'Reporte PDF generado exitosamente',
      ));
    } catch (error) {
      final failure = ErrorHandler.handleException(error);
      emit(ExportError(failure: failure));
    }
  }

  Future<void> _onShareFile(
    ShareFileEvent event,
    Emitter<ExportState> emit,
  ) async {
    try {
      emit(const ExportLoading(message: 'Compartiendo archivo...'));

      await shareExport(
        ShareExportParams(
          filePath: event.filePath,
          subject: event.subject,
        ),
      );

      emit(const ShareSuccess(message: 'Archivo compartido exitosamente'));
    } catch (error) {
      final failure = ErrorHandler.handleException(error);
      emit(ExportError(failure: failure));
    }
  }

  Future<void> _onImportFromCsv(
    ImportFromCsvEvent event,
    Emitter<ExportState> emit,
  ) async {
    try {
      emit(const ExportLoading(message: 'Importando desde CSV...'));

      final importedData = await importExpensesCsv(event.filePath);

      emit(ImportSuccess(
        importedData: importedData,
        message: '${importedData.length} gastos importados exitosamente',
      ));
    } catch (error) {
      final failure = ErrorHandler.handleException(error);
      emit(ExportError(failure: failure));
    }
  }
}

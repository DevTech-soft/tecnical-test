import '../../../../core/services/export_service.dart';
import '../../../../core/usecases/usecase.dart';

class ImportExpensesCsv extends UseCase<List<Map<String, dynamic>>, String> {
  final ExportService exportService;

  ImportExpensesCsv(this.exportService);

  @override
  Future<List<Map<String, dynamic>>> call(String filePath) async {
    return await exportService.importExpensesFromCsv(filePath);
  }
}

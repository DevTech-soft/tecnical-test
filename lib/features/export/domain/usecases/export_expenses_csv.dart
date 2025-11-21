import '../../../../core/services/export_service.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../expenses/domain/entities/category.dart';
import '../../../expenses/domain/entities/expense.dart';

class ExportExpensesCsv extends UseCase<String, ExportExpensesCsvParams> {
  final ExportService exportService;

  ExportExpensesCsv(this.exportService);

  @override
  Future<String> call(ExportExpensesCsvParams params) async {
    return await exportService.exportExpensesToCsv(
      expenses: params.expenses,
      categories: params.categories,
      fileName: params.fileName,
    );
  }
}

class ExportExpensesCsvParams {
  final List<Expense> expenses;
  final Map<String, Category> categories;
  final String? fileName;

  ExportExpensesCsvParams({
    required this.expenses,
    required this.categories,
    this.fileName,
  });
}

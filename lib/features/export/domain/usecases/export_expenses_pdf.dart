import '../../../../core/services/export_service.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../expenses/domain/entities/category.dart';
import '../../../expenses/domain/entities/expense.dart';

class ExportExpensesPdf extends UseCase<String, ExportExpensesPdfParams> {
  final ExportService exportService;

  ExportExpensesPdf(this.exportService);

  @override
  Future<String> call(ExportExpensesPdfParams params) async {
    return await exportService.exportExpensesPdf(
      expenses: params.expenses,
      categories: params.categories,
      startDate: params.startDate,
      endDate: params.endDate,
      fileName: params.fileName,
    );
  }
}

class ExportExpensesPdfParams {
  final List<Expense> expenses;
  final Map<String, Category> categories;
  final DateTime startDate;
  final DateTime endDate;
  final String? fileName;

  ExportExpensesPdfParams({
    required this.expenses,
    required this.categories,
    required this.startDate,
    required this.endDate,
    this.fileName,
  });
}

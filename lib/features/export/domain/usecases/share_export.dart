import '../../../../core/services/export_service.dart';
import '../../../../core/usecases/usecase.dart';

class ShareExport extends UseCase<void, ShareExportParams> {
  final ExportService exportService;

  ShareExport(this.exportService);

  @override
  Future<void> call(ShareExportParams params) async {
    return await exportService.shareFile(
      params.filePath,
      subject: params.subject,
    );
  }
}

class ShareExportParams {
  final String filePath;
  final String? subject;

  ShareExportParams({
    required this.filePath,
    this.subject,
  });
}

import 'dart:io';
import 'package:csv/csv.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
import '../../features/expenses/domain/entities/expense.dart';
import '../../features/expenses/domain/entities/category.dart';
import '../errors/exceptions.dart';

/// Servicio para exportar datos a diferentes formatos.
class ExportService {
  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');
  final DateFormat _fileNameFormat = DateFormat('yyyy-MM-dd_HHmmss');
  final NumberFormat _currencyFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 2);

  /// Exporta gastos a formato CSV.
  ///
  /// Retorna la ruta del archivo generado.
  Future<String> exportExpensesToCsv({
    required List<Expense> expenses,
    required Map<String, Category> categories,
    String? fileName,
  }) async {
    try {
      // Preparar datos para CSV
      final List<List<dynamic>> rows = [
        // Encabezados
        ['Fecha', 'Categoría', 'Monto', 'Nota'],
      ];

      // Agregar datos
      for (final expense in expenses) {
        final category = categories[expense.categoryId];
        rows.add([
          _dateFormat.format(expense.date),
          category?.name ?? 'Sin categoría',
          expense.amount,
          expense.note ?? '',
        ]);
      }

      // Convertir a CSV
      final csvData = const ListToCsvConverter().convert(rows);

      // Guardar archivo
      final directory = await _getExportDirectory();
      final name = fileName ?? 'gastos_${_fileNameFormat.format(DateTime.now())}';
      final file = File('${directory.path}/$name.csv');
      await file.writeAsString(csvData);

      return file.path;
    } catch (e) {
      throw CacheException(
        message: 'Error al exportar a CSV: ${e.toString()}',
        code: 'CSV_EXPORT_ERROR',
      );
    }
  }

  /// Exporta gastos a formato PDF.
  ///
  /// Retorna la ruta del archivo generado.
  Future<String> exportExpensesPdf({
    required List<Expense> expenses,
    required Map<String, Category> categories,
    required DateTime startDate,
    required DateTime endDate,
    String? fileName,
  }) async {
    try {
      final pdf = pw.Document();

      // Calcular totales
      final total = expenses.fold<double>(0, (sum, expense) => sum + expense.amount);

      // Agrupar por categoría
      final Map<String, double> categoryTotals = {};
      for (final expense in expenses) {
        final categoryName = categories[expense.categoryId]?.name ?? 'Sin categoría';
        categoryTotals[categoryName] = (categoryTotals[categoryName] ?? 0) + expense.amount;
      }

      // Crear PDF
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          build: (pw.Context context) {
            return [
              // Título
              pw.Header(
                level: 0,
                child: pw.Text(
                  'Reporte de Gastos',
                  style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
                ),
              ),
              pw.SizedBox(height: 10),

              // Período
              pw.Text(
                'Período: ${_dateFormat.format(startDate)} - ${_dateFormat.format(endDate)}',
                style: const pw.TextStyle(fontSize: 14),
              ),
              pw.SizedBox(height: 20),

              // Resumen
              pw.Container(
                padding: const pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey300),
                  borderRadius: const pw.BorderRadius.all(pw.Radius.circular(5)),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Resumen',
                      style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
                    ),
                    pw.SizedBox(height: 10),
                    pw.Text('Total de gastos: ${expenses.length}'),
                    pw.Text('Monto total: ${_currencyFormat.format(total)}'),
                  ],
                ),
              ),
              pw.SizedBox(height: 20),

              // Gastos por categoría
              pw.Text(
                'Gastos por Categoría',
                style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 10),
              pw.Table.fromTextArray(
                headers: ['Categoría', 'Monto'],
                data: categoryTotals.entries
                    .map((e) => [e.key, _currencyFormat.format(e.value)])
                    .toList(),
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                cellAlignment: pw.Alignment.centerLeft,
              ),
              pw.SizedBox(height: 20),

              // Detalle de gastos
              pw.Text(
                'Detalle de Gastos',
                style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 10),
              pw.Table.fromTextArray(
                headers: ['Fecha', 'Categoría', 'Monto', 'Nota'],
                data: expenses.map((expense) {
                  final category = categories[expense.categoryId];
                  return [
                    _dateFormat.format(expense.date),
                    category?.name ?? 'Sin categoría',
                    _currencyFormat.format(expense.amount),
                    expense.note ?? '',
                  ];
                }).toList(),
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                cellAlignment: pw.Alignment.centerLeft,
              ),
            ];
          },
        ),
      );

      // Guardar archivo
      final directory = await _getExportDirectory();
      final name = fileName ?? 'reporte_gastos_${_fileNameFormat.format(DateTime.now())}';
      final file = File('${directory.path}/$name.pdf');
      await file.writeAsBytes(await pdf.save());

      return file.path;
    } catch (e) {
      throw CacheException(
        message: 'Error al exportar a PDF: ${e.toString()}',
        code: 'PDF_EXPORT_ERROR',
      );
    }
  }

  /// Importa gastos desde un archivo CSV.
  ///
  /// Retorna la lista de gastos importados.
  Future<List<Map<String, dynamic>>> importExpensesFromCsv(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        throw CacheException.notFound();
      }

      final csvString = await file.readAsString();
      final List<List<dynamic>> csvData = const CsvToListConverter().convert(csvString);

      // Validar que tenga datos
      if (csvData.length < 2) {
        throw ValidationException(
          message: 'El archivo CSV está vacío o no tiene datos',
          code: 'EMPTY_CSV',
        );
      }

      // Parsear datos (ignorar encabezados)
      final List<Map<String, dynamic>> importedExpenses = [];
      for (int i = 1; i < csvData.length; i++) {
        final row = csvData[i];
        if (row.length < 3) continue; // Validar que tenga las columnas mínimas

        try {
          // Parsear fecha (formato dd/MM/yyyy)
          final dateParts = row[0].toString().split('/');
          final date = DateTime(
            int.parse(dateParts[2]),
            int.parse(dateParts[1]),
            int.parse(dateParts[0]),
          );

          // Parsear monto
          final amount = double.parse(row[2].toString());

          importedExpenses.add({
            'date': date,
            'categoryName': row[1].toString(),
            'amount': amount,
            'note': row.length > 3 ? row[3].toString() : null,
          });
        } catch (e) {
          // Ignorar filas con errores de parseo
          continue;
        }
      }

      return importedExpenses;
    } catch (e) {
      if (e is CacheException || e is ValidationException) {
        rethrow;
      }
      throw CacheException(
        message: 'Error al importar CSV: ${e.toString()}',
        code: 'CSV_IMPORT_ERROR',
      );
    }
  }

  /// Comparte un archivo.
  Future<void> shareFile(String filePath, {String? subject}) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        throw CacheException.notFound();
      }

      final xFile = XFile(filePath);
      await Share.shareXFiles(
        [xFile],
        subject: subject ?? 'Exportación de Daily Expenses',
      );
    } catch (e) {
      throw CacheException(
        message: 'Error al compartir archivo: ${e.toString()}',
        code: 'SHARE_ERROR',
      );
    }
  }

  /// Obtiene el directorio para exportaciones.
  Future<Directory> _getExportDirectory() async {
    final directory = await getApplicationDocumentsDirectory();
    final exportDir = Directory('${directory.path}/exports');

    if (!await exportDir.exists()) {
      await exportDir.create(recursive: true);
    }

    return exportDir;
  }

  /// Lista todos los archivos exportados.
  Future<List<FileSystemEntity>> listExportedFiles() async {
    try {
      final directory = await _getExportDirectory();
      final files = directory.listSync();

      // Ordenar por fecha de modificación (más reciente primero)
      files.sort((a, b) {
        final aStat = a.statSync();
        final bStat = b.statSync();
        return bStat.modified.compareTo(aStat.modified);
      });

      return files;
    } catch (e) {
      throw CacheException(
        message: 'Error al listar archivos exportados: ${e.toString()}',
        code: 'LIST_EXPORTS_ERROR',
      );
    }
  }

  /// Elimina un archivo exportado.
  Future<void> deleteExportedFile(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      throw CacheException(
        message: 'Error al eliminar archivo: ${e.toString()}',
        code: 'DELETE_EXPORT_ERROR',
      );
    }
  }
}

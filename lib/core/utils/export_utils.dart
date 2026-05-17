import 'dart:io';
import 'package:excel/excel.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class ExportUtils {
  static Future<void> exportAttendanceToExcel(String className, DateTime date, List<Map<String, dynamic>> records) async {
    final excel = Excel.createExcel();
    final sheet = excel['Sheet1'];

    sheet.appendRow([TextCellValue('Roll Number'), TextCellValue('Name'), TextCellValue('Status')]);

    for (var r in records) {
      sheet.appendRow([
        TextCellValue(r['rollNumber'] ?? ''),
        TextCellValue(r['name'] ?? ''),
        TextCellValue(r['status'] ?? ''),
      ]);
    }

    final bytes = excel.save();
    if (bytes != null) {
      final dir = await getApplicationDocumentsDirectory();
      final path = '${dir.path}/attendance_${className.replaceAll(' ', '_')}_${date.toString().split(' ')[0]}.xlsx';
      final file = File(path);
      await file.writeAsBytes(bytes);
      await Share.shareXFiles([XFile(path)], text: 'Attendance for $className on ${date.toString().split(' ')[0]}');
    }
  }

  static Future<void> exportAttendanceToPdf(String className, DateTime date, List<Map<String, dynamic>> records) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Attendance Report', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 10),
              pw.Text('Class: $className'),
              pw.Text('Date: ${date.toString().split(' ')[0]}'),
              pw.SizedBox(height: 20),
              pw.Table.fromTextArray(
                headers: ['Roll Number', 'Name', 'Status'],
                data: records.map((r) => [r['rollNumber'], r['name'], r['status']]).toList(),
              ),
            ],
          );
        },
      ),
    );

    final bytes = await pdf.save();
    final dir = await getApplicationDocumentsDirectory();
    final path = '${dir.path}/attendance_${className.replaceAll(' ', '_')}_${date.toString().split(' ')[0]}.pdf';
    final file = File(path);
    await file.writeAsBytes(bytes);
    await Share.shareXFiles([XFile(path)], text: 'Attendance for $className on ${date.toString().split(' ')[0]}');
  }
}

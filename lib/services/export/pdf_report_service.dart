import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
import '../../models/export/monthly_report_data.dart';

class PdfReportService {
  Future<void> generateAndShareMonthlyReport({
    required MonthlyReportData data,
  }) async {
    final pdfBytes = await _buildPdf(data);
    final dir = await getTemporaryDirectory();
    final filename =
        '${data.month.toLowerCase().replaceAll(' ', '_')}_veltrix_report.pdf';
    final file = File('${dir.path}/$filename');
    await file.writeAsBytes(pdfBytes);
    await Share.shareXFiles([
      XFile(file.path),
    ], text: 'Monthly Report: ${data.month}');
  }

  Future<List<int>> _buildPdf(MonthlyReportData data) async {
    final doc = pw.Document();

    final headerStyle = pw.TextStyle(
      fontSize: 26,
      fontWeight: pw.FontWeight.bold,
      color: PdfColors.indigo900,
    );
    final sectionStyle = pw.TextStyle(
      fontSize: 14,
      fontWeight: pw.FontWeight.bold,
      color: PdfColors.indigo900,
    );
    const bodyStyle = pw.TextStyle(fontSize: 11, color: PdfColors.grey800);

    pw.Widget sectionTitle(String text) => pw.Padding(
      padding: const pw.EdgeInsets.only(top: 14, bottom: 6),
      child: pw.Text(text, style: sectionStyle),
    );

    pw.Widget kvTable(List<List<String>> rows) => pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
      columnWidths: const {0: pw.FlexColumnWidth(1), 1: pw.FlexColumnWidth(1)},
      children: [
        for (final row in rows)
          pw.TableRow(
            children: [
              pw.Padding(
                padding: const pw.EdgeInsets.all(6),
                child: pw.Text(
                  row[0],
                  style: pw.TextStyle(
                    fontSize: 11,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.grey700,
                  ),
                ),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.all(6),
                child: pw.Text(row[1], style: bodyStyle),
              ),
            ],
          ),
      ],
    );

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(36),
        build:
            (context) => [
              pw.Text('VELTRIX', style: headerStyle),
              pw.Text(
                'Monthly Performance Dossier — ${data.month}',
                style: const pw.TextStyle(
                  fontSize: 13,
                  color: PdfColors.grey700,
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Divider(color: PdfColors.indigo900, thickness: 2),
              sectionTitle('Athlete'),
              pw.Text(
                '${data.athlete.name} (${data.athlete.handle})',
                style: bodyStyle,
              ),
              pw.SizedBox(height: 4),
              kvTable([
                ['FTP', '${data.athlete.ftpWatts} W'],
                ['VO2 Max', '${data.athlete.vo2Max}'],
                ['LTHR', '${data.athlete.lthr} bpm'],
                ['Weight', '${data.athlete.weightKg} kg'],
              ]),
              sectionTitle('PMC Status'),
              kvTable([
                ['CTL (Fitness)', '${data.pmc.currentCtl}'],
                ['ATL (Fatigue)', '${data.pmc.currentAtl}'],
                ['TSB (Form)', '${data.pmc.currentTsb}'],
                ['Form State', data.pmc.formState],
              ]),
              pw.SizedBox(height: 4),
              pw.Text(data.pmc.formStateDescription, style: bodyStyle),
              sectionTitle('Monthly Volume'),
              kvTable([
                [
                  'Distance',
                  '${data.volume.totalDistanceKm.toStringAsFixed(1)} km',
                ],
                ['Elevation', '${data.volume.totalElevationMeters} m'],
                [
                  'Active Hours',
                  data.volume.totalActiveHours.toStringAsFixed(1),
                ],
                ['TSS', '${data.volume.totalTSS}'],
                ['Activities', '${data.volume.totalActivities}'],
              ]),
              sectionTitle('Coaching Prescription'),
              pw.Text(data.coachingPrescription, style: bodyStyle),
            ],
      ),
    );

    return doc.save();
  }

  String generateReportText(MonthlyReportData data) {
    final buffer =
        StringBuffer()
          ..writeln('=== VELTRIX MONTHLY PERFORMANCE REPORT ===')
          ..writeln('Month: ${data.month}')
          ..writeln()
          ..writeln('--- ATHLETE PROFILE ---')
          ..writeln('Name: ${data.athlete.name}')
          ..writeln('FTP: ${data.athlete.ftpWatts}W')
          ..writeln('VO2 Max: ${data.athlete.vo2Max}')
          ..writeln('LTHR: ${data.athlete.lthr} bpm')
          ..writeln()
          ..writeln('--- PMC STATUS ---')
          ..writeln('CTL (Fitness): ${data.pmc.currentCtl}')
          ..writeln('ATL (Fatigue): ${data.pmc.currentAtl}')
          ..writeln('TSB (Form): ${data.pmc.currentTsb}')
          ..writeln('State: ${data.pmc.formState}')
          ..writeln('Description: ${data.pmc.formStateDescription}')
          ..writeln()
          ..writeln('--- MONTHLY VOLUME ---')
          ..writeln(
            'Distance: ${data.volume.totalDistanceKm.toStringAsFixed(1)} km',
          );

    if (data.volume.totalElevationMeters > 0) {
      buffer.writeln('Elevation: ${data.volume.totalElevationMeters} m');
    }
    buffer
      ..writeln(
        'Active Hours: ${data.volume.totalActiveHours.toStringAsFixed(1)}',
      )
      ..writeln('TSS: ${data.volume.totalTSS}')
      ..writeln('Activities: ${data.volume.totalActivities}')
      ..writeln()
      ..writeln('--- COACHING PRESCRIPTION ---')
      ..writeln(data.coachingPrescription);

    return buffer.toString();
  }
}

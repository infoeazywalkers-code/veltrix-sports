import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../models/training/structured_workout.dart';

class IcsExportService {
  Future<void> exportWorkouts({
    required String calendarName,
    required List<StructuredWorkout> workouts,
  }) async {
    final icsContent = _generateIcs(calendarName, workouts);
    final dir = await getTemporaryDirectory();
    final filename =
        '${calendarName.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '_')}_veltrix.ics';
    final file = File('${dir.path}/$filename');
    await file.writeAsString(icsContent);
    await Share.shareXFiles([
      XFile(file.path),
    ], text: 'Calendar: $calendarName');
  }

  String _generateIcs(String calendarName, List<StructuredWorkout> workouts) {
    final buffer = StringBuffer()
      ..writeln('BEGIN:VCALENDAR')
      ..writeln('VERSION:2.0')
      ..writeln('PRODID:-//Veltrix Sports//Training Plan//EN')
      ..writeln('CALSCALE:GREGORIAN')
      ..writeln('METHOD:PUBLISH')
      ..writeln('X-WR-CALNAME:$calendarName');

    for (final workout in workouts) {
      final startDt = _parseDate(workout.date);
      if (startDt == null) continue;

      final endDt = startDt.add(
        Duration(minutes: workout.plannedDurationMinutes),
      );
      final uid = '${workout.id}@veltrixsports.com';

      buffer
        ..writeln('BEGIN:VEVENT')
        ..writeln('UID:$uid')
        ..writeln('DTSTART:${_formatIcsDate(startDt)}')
        ..writeln('DTEND:${_formatIcsDate(endDt)}')
        ..writeln('SUMMARY:${_escapeIcs(workout.title)}')
        ..writeln(
          'DESCRIPTION:${_escapeIcs(workout.description)}\\nSport: ${workout.sport}\\nPlanned TSS: ${workout.plannedTSS}',
        )
        ..writeln('CATEGORIES:${workout.sport.toUpperCase()}')
        ..writeln('STATUS:CONFIRMED')
        ..writeln('END:VEVENT');
    }

    buffer.writeln('END:VCALENDAR');
    return buffer.toString();
  }

  DateTime? _parseDate(String dateStr) {
    return DateTime.tryParse(dateStr);
  }

  String _formatIcsDate(DateTime dt) {
    return '${dt.year.toString().padLeft(4, '0')}'
        '${dt.month.toString().padLeft(2, '0')}'
        '${dt.day.toString().padLeft(2, '0')}'
        'T'
        '${dt.hour.toString().padLeft(2, '0')}'
        '${dt.minute.toString().padLeft(2, '0')}'
        '${dt.second.toString().padLeft(2, '0')}';
  }

  String _escapeIcs(String text) {
    return text
        .replaceAll('\\', '\\\\')
        .replaceAll(';', '\\;')
        .replaceAll(',', '\\,')
        .replaceAll('\n', '\\n');
  }
}

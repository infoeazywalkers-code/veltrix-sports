import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class GpxPoint {
  final double latitude;
  final double longitude;
  final double? altitude;
  final double? speed;
  final int? heartRate;
  final int? cadence;
  final int? power;
  final DateTime timestamp;

  const GpxPoint({
    required this.latitude,
    required this.longitude,
    this.altitude,
    this.speed,
    this.heartRate,
    this.cadence,
    this.power,
    required this.timestamp,
  });
}

class GpxExportService {
  Future<void> exportAndShare({
    required String title,
    required String sport,
    required List<GpxPoint> track,
    DateTime? date,
  }) async {
    final gpxContent = _generateGpxXml(title, sport, track, date);
    final dir = await getTemporaryDirectory();
    final filename =
        '${title.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '_')}_veltrix.gpx';
    final file = File('${dir.path}/$filename');
    await file.writeAsString(gpxContent);
    await Share.shareXFiles([XFile(file.path)], text: 'GPX Track: $title');
  }

  String _generateGpxXml(
    String title,
    String sport,
    List<GpxPoint> track,
    DateTime? date,
  ) {
    final startTime = (date ?? DateTime.now()).toUtc().toIso8601String();
    final buffer = StringBuffer()
      ..writeln('<?xml version="1.0" encoding="UTF-8"?>')
      ..writeln('<gpx version="1.1" creator="Veltrix Athletic Performance"')
      ..writeln('  xmlns="http://www.topografix.com/GPX/1/1"')
      ..writeln(
        '  xmlns:gpxtpx="http://www.garmin.com/xmlschemas/TrackPointExtension/v1"',
      )
      ..writeln('  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"')
      ..writeln(
        '  xsi:schemaLocation="http://www.topografix.com/GPX/1/1 http://www.topografix.com/GPX/1/1/gpx.xsd">',
      )
      ..writeln('  <metadata>')
      ..writeln('    <name>${_escapeXml(title)}</name>')
      ..writeln('    <time>$startTime</time>')
      ..writeln('    <type>$sport</type>')
      ..writeln('  </metadata>')
      ..writeln('  <trk>')
      ..writeln('    <name>${_escapeXml(title)}</name>')
      ..writeln('    <type>$sport</type>')
      ..writeln('    <trkseg>');

    for (final pt in track) {
      final timeIso = pt.timestamp.toUtc().toIso8601String();
      final ele = pt.altitude != null
          ? '<ele>${pt.altitude!.toStringAsFixed(1)}</ele>'
          : '';
      final hr = pt.heartRate != null
          ? '<gpxtpx:hr>${pt.heartRate}</gpxtpx:hr>'
          : '';
      final cad = pt.cadence != null
          ? '<gpxtpx:cad>${pt.cadence}</gpxtpx:cad>'
          : '';
      final power = pt.power != null ? '<power>${pt.power}</power>' : '';

      String extensions = '';
      if (hr.isNotEmpty || cad.isNotEmpty) {
        extensions =
            '''
        <extensions>
          <gpxtpx:TrackPointExtension>
            $hr
            $cad
          </gpxtpx:TrackPointExtension>
        </extensions>''';
      }

      buffer.writeln(
        '      <trkpt lat="${pt.latitude}" lon="${pt.longitude}">',
      );
      if (ele.isNotEmpty) buffer.writeln('        $ele');
      buffer.writeln('        <time>$timeIso</time>');
      if (power.isNotEmpty) buffer.writeln('        $power');
      if (extensions.isNotEmpty) buffer.writeln('        $extensions');
      buffer.writeln('      </trkpt>');
    }

    buffer
      ..writeln('    </trkseg>')
      ..writeln('  </trk>')
      ..writeln('</gpx>');

    return buffer.toString();
  }

  String _escapeXml(String unsafe) {
    return unsafe
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll("'", '&apos;')
        .replaceAll('"', '&quot;');
  }
}

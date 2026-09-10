import 'package:flutter/material.dart';
import '../../models/activity/activity.dart';

class GpsRouteMapWidget extends StatelessWidget {
  final List<GPSPoint> gpsPoints;
  final List<LapSplit>? laps;
  final double height;
  final bool showGradient;

  const GpsRouteMapWidget({
    super.key,
    required this.gpsPoints,
    this.laps,
    this.height = 200,
    this.showGradient = true,
  });

  @override
  Widget build(BuildContext context) {
    if (gpsPoints.isEmpty) {
      return Container(
        height: height,
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
        ),
        child: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.map_outlined, size: 40, color: Colors.white24),
              SizedBox(height: 8),
              Text(
                'No GPS data',
                style: TextStyle(color: Colors.white38, fontSize: 13),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            CustomPaint(
              size: Size.infinite,
              painter: _RoutePainter(gpsPoints: gpsPoints),
            ),
            if (showGradient)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        const Color(0xFF1A1A1A).withValues(alpha: 0.0),
                        const Color(0xFF1A1A1A),
                      ],
                    ),
                  ),
                ),
              ),
            if (gpsPoints.any((p) => p.altitude != null && p.altitude! > 0))
              Positioned(
                bottom: 8,
                left: 8,
                right: 8,
                child: _elevationProfile(),
              ),
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '${gpsPoints.length} GPS points',
                  style: const TextStyle(color: Colors.white60, fontSize: 9),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _elevationProfile() {
    final elevations =
        gpsPoints.map((p) => p.altitude ?? 0).where((e) => e > 0).toList();
    if (elevations.isEmpty) return const SizedBox.shrink();

    final maxElev = elevations.reduce((a, b) => a > b ? a : b);
    final minElev = elevations.reduce((a, b) => a < b ? a : b);
    final range = maxElev - minElev;

    return Container(
      height: 48,
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: CustomPaint(
        size: const Size(double.infinity, 36),
        painter: _ElevationPainter(
          elevations: elevations,
          range: range,
          min: minElev,
        ),
      ),
    );
  }
}

class _RoutePainter extends CustomPainter {
  final List<GPSPoint> gpsPoints;

  _RoutePainter({required this.gpsPoints});

  @override
  void paint(Canvas canvas, Size size) {
    if (gpsPoints.length < 2) return;

    final minLat = gpsPoints
        .map((p) => p.latitude)
        .reduce((a, b) => a < b ? a : b);
    final maxLat = gpsPoints
        .map((p) => p.latitude)
        .reduce((a, b) => a > b ? a : b);
    final minLng = gpsPoints
        .map((p) => p.longitude)
        .reduce((a, b) => a < b ? a : b);
    final maxLng = gpsPoints
        .map((p) => p.longitude)
        .reduce((a, b) => a > b ? a : b);

    final latRange = maxLat - minLat;
    final lngRange = maxLng - minLng;

    if (latRange == 0 && lngRange == 0) return;

    final padding = 20.0;
    final drawWidth = size.width - padding * 2;
    final drawHeight = size.height - padding * 2;

    final routePaint =
        Paint()
          ..color = const Color(0xFFF97316)
          ..strokeWidth = 3
          ..strokeCap = StrokeCap.round
          ..style = PaintingStyle.stroke;

    final startPaint = Paint()..color = const Color(0xFF10B981);
    final endPaint = Paint()..color = const Color(0xFFEF4444);

    final points = <Offset>[];
    for (final gp in gpsPoints) {
      final x = padding + ((gp.longitude - minLng) / lngRange) * drawWidth;
      final y = padding + ((maxLat - gp.latitude) / latRange) * drawHeight;
      points.add(Offset(x, y));
    }

    final path = Path();
    path.moveTo(points.first.dx, points.first.dy);
    for (int i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }
    canvas.drawPath(path, routePaint);

    canvas.drawCircle(points.first, 6, startPaint);
    canvas.drawCircle(points.last, 6, endPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _ElevationPainter extends CustomPainter {
  final List<double> elevations;
  final double range;
  final double min;

  _ElevationPainter({
    required this.elevations,
    required this.range,
    required this.min,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (elevations.isEmpty || range == 0) return;

    final fillPaint =
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF10B981).withValues(alpha: 0.4),
              const Color(0xFF10B981).withValues(alpha: 0.0),
            ],
          ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final linePaint =
        Paint()
          ..color = const Color(0xFF10B981)
          ..strokeWidth = 1.5
          ..style = PaintingStyle.stroke;

    final path = Path();
    final fillPath = Path();

    final step = size.width / (elevations.length - 1);
    final firstX = 0.0;
    final firstY =
        size.height - ((elevations.first - min) / range) * size.height;
    path.moveTo(firstX, firstY);
    fillPath.moveTo(firstX, size.height);
    fillPath.lineTo(firstX, firstY);

    for (int i = 1; i < elevations.length; i++) {
      final x = i * step;
      final y = size.height - ((elevations[i] - min) / range) * size.height;
      path.lineTo(x, y);
      fillPath.lineTo(x, y);
    }

    fillPath.lineTo(size.width, size.height);
    fillPath.close();

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, linePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

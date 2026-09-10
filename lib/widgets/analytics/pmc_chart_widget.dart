import 'package:flutter/material.dart';
import '../../models/performance/daily_training_metric.dart';

class PmcChartWidget extends StatelessWidget {
  final List<DailyTrainingMetric> metrics;
  final double height;

  const PmcChartWidget({super.key, required this.metrics, this.height = 200});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(12),
      ),
      child:
          metrics.isEmpty
              ? const Center(
                child: Text(
                  'No PMC data',
                  style: TextStyle(color: Colors.white38, fontSize: 12),
                ),
              )
              : CustomPaint(
                size: Size(double.infinity, height - 24),
                painter: _PmcChartPainter(metrics),
              ),
    );
  }
}

class _PmcChartPainter extends CustomPainter {
  final List<DailyTrainingMetric> data;

  _PmcChartPainter(this.data);

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final maxCtl = data.map((m) => m.ctl).reduce((a, b) => a > b ? a : b);
    final maxAtl = data.map((m) => m.atl).reduce((a, b) => a > b ? a : b);
    final maxLoad = [maxCtl, maxAtl, 50.0].reduce((a, b) => a > b ? a : b);

    final ctlPaint =
        Paint()
          ..color = const Color(0xFF38BDF8)
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke;
    final atlPaint =
        Paint()
          ..color = const Color(0xFFFB7185)
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke;

    final getX =
        (int idx) => (idx / (data.length - 1).clamp(1, 999)) * size.width;
    final getYLoad =
        (double val) =>
            size.height -
            (val / maxLoad * size.height * 0.8) -
            size.height * 0.1;

    if (data.length > 1) {
      _drawLine(canvas, data, getX, getYLoad, (m) => m.ctl, ctlPaint);
      _drawLine(canvas, data, getX, getYLoad, (m) => m.atl, atlPaint);
    }
  }

  void _drawLine(
    Canvas canvas,
    List<DailyTrainingMetric> metrics,
    double Function(int) getX,
    double Function(double) getY,
    double Function(DailyTrainingMetric) getValue,
    Paint paint,
  ) {
    final path = Path();
    path.moveTo(getX(0), getY(getValue(metrics.first)));
    for (int i = 1; i < metrics.length; i++) {
      path.lineTo(getX(i), getY(getValue(metrics[i])));
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

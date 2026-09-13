import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/performance/daily_training_metric.dart';
import '../../services/performance/pmc_service.dart';

class PmcScreen extends ConsumerStatefulWidget {
  final List<DailyTrainingMetric> metrics;

  const PmcScreen({super.key, required this.metrics});

  @override
  ConsumerState<PmcScreen> createState() => _PmcScreenState();
}

class _PmcScreenState extends ConsumerState<PmcScreen> {
  String _timeRange = '45';
  bool _showProjection = true;
  ForecastScenario _forecastScenario = ForecastScenario.linear;

  @override
  Widget build(BuildContext context) {
    final pmcService = ref.read(pmcServiceProvider);
    final filteredMetrics = _getFilteredMetrics();
    final latest = widget.metrics.isNotEmpty ? widget.metrics.last : null;
    final forecastStats = pmcService.computeForecastStats(widget.metrics);
    final projectedMetrics = pmcService.compute7DayForecast(
      metrics: widget.metrics,
      scenario: _forecastScenario,
    );
    final rampRate = pmcService.computeRampRate(widget.metrics);

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0A0A),
        title: const Text(
          'Performance Management',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _showProjection ? Icons.visibility : Icons.visibility_off,
              color: const Color(0xFFF59E0B),
            ),
            onPressed: () => setState(() => _showProjection = !_showProjection),
          ),
        ],
      ),
      body: widget.metrics.isEmpty
          ? const Center(
              child: Text(
                'No PMC data',
                style: TextStyle(color: Colors.white54),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildKpiCards(
                    latest!,
                    projectedMetrics,
                    pmcService,
                    rampRate,
                  ),
                  const SizedBox(height: 16),
                  _buildTimeRangeSelector(),
                  const SizedBox(height: 12),
                  _buildForecastScenarioSelector(),
                  const SizedBox(height: 16),
                  _buildForecastInsights(forecastStats, projectedMetrics),
                  const SizedBox(height: 16),
                  _buildChart(filteredMetrics, projectedMetrics),
                  const SizedBox(height: 12),
                  _buildLegend(),
                ],
              ),
            ),
    );
  }

  List<DailyTrainingMetric> _getFilteredMetrics() {
    switch (_timeRange) {
      case '30':
        return widget.metrics.length > 30
            ? widget.metrics.sublist(widget.metrics.length - 30)
            : widget.metrics;
      case 'all':
        return widget.metrics;
      default:
        return widget.metrics.length > 45
            ? widget.metrics.sublist(widget.metrics.length - 45)
            : widget.metrics;
    }
  }

  Widget _buildKpiCards(
    DailyTrainingMetric latest,
    List<DailyTrainingMetric> projected,
    PmcService pmcService,
    double rampRate,
  ) {
    final formState = pmcService.getFormState(latest.tsb);
    final finalProjected = projected.isNotEmpty ? projected.last : null;
    final projectedTsbDelta = finalProjected != null
        ? finalProjected.tsb - latest.tsb
        : 0.0;

    return Column(
      children: [
        Row(
          children: [
            _KpiCard(
              label: 'Fitness (CTL)',
              value: latest.ctl.round().toString(),
              color: const Color(0xFF38BDF8),
            ),
            const SizedBox(width: 8),
            _KpiCard(
              label: 'Fatigue (ATL)',
              value: latest.atl.round().toString(),
              color: const Color(0xFFFB7185),
            ),
            const SizedBox(width: 8),
            _KpiCard(
              label: 'Form (TSB)',
              value: '${latest.tsb > 0 ? '+' : ''}${latest.tsb.round()}',
              color: latest.tsb >= 0
                  ? const Color(0xFF10B981)
                  : const Color(0xFFF59E0B),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _KpiCard(
              label: 'Projected TSB (+7d)',
              value: finalProjected != null
                  ? '${finalProjected.tsb > 0 ? '+' : ''}${finalProjected.tsb.round()}'
                  : '--',
              color: const Color(0xFFF59E0B),
              subtitle:
                  '${projectedTsbDelta >= 0 ? '+' : ''}${projectedTsbDelta.round()} pts',
            ),
            const SizedBox(width: 8),
            _KpiCard(
              label: 'Ramp Rate',
              value: '${rampRate > 0 ? '+' : ''}$rampRate',
              color: const Color(0xFFA855F7),
              subtitle: 'CTL/week',
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _getFormColor(formState.color).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _getFormColor(formState.color).withValues(alpha: 0.3),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'FORM DIAGNOSIS',
                style: TextStyle(
                  color: _getFormColor(formState.color),
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                formState.label,
                style: TextStyle(
                  color: _getFormColor(formState.color),
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                formState.description,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.5),
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTimeRangeSelector() {
    return Row(
      children: ['30', '45', 'all'].map((range) {
        final isSelected = _timeRange == range;
        return Padding(
          padding: const EdgeInsets.only(right: 8),
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () => setState(() => _timeRange = range),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF262626)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected ? Colors.white24 : Colors.white12,
                  ),
                ),
                child: Text(
                  range == 'all' ? 'All (90d)' : '$range Days',
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.white54,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildForecastScenarioSelector() {
    return Row(
      children: ForecastScenario.values.map((scenario) {
        final isSelected = _forecastScenario == scenario;
        final label = scenario == ForecastScenario.linear
            ? 'Linear'
            : scenario == ForecastScenario.average
            ? 'Average'
            : scenario == ForecastScenario.taper
            ? 'Taper'
            : 'Overload';
        return Padding(
          padding: const EdgeInsets.only(right: 6),
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () => setState(() => _forecastScenario = scenario),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFFF59E0B).withValues(alpha: 0.2)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFFF59E0B).withValues(alpha: 0.4)
                        : Colors.white12,
                  ),
                ),
                child: Text(
                  label,
                  style: TextStyle(
                    color: isSelected
                        ? const Color(0xFFF59E0B)
                        : Colors.white54,
                    fontSize: 11,
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildForecastInsights(
    ForecastStats stats,
    List<DailyTrainingMetric> projected,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _InsightPill(label: '4-Wk Avg', value: '${stats.avgTss} TSS/day'),
          _InsightPill(
            label: 'Slope',
            value: '${stats.slope >= 0 ? '+' : ''}${stats.slope}',
            color: stats.slope >= 0
                ? const Color(0xFF10B981)
                : const Color(0xFFEF4444),
          ),
          _InsightPill(
            label: 'Proj 7d',
            value: '${projected.fold<int>(0, (a, b) => a + b.tss)} TSS',
            color: const Color(0xFFA855F7),
          ),
        ],
      ),
    );
  }

  Widget _buildChart(
    List<DailyTrainingMetric> historical,
    List<DailyTrainingMetric> projected,
  ) {
    return Container(
      height: 220,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(12),
      ),
      child: CustomPaint(
        size: const Size(double.infinity, 200),
        painter: _EnhancedPmcChartPainter(
          historical: historical,
          projected: _showProjection ? projected : [],
        ),
      ),
    );
  }

  Widget _buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _LegendDot(color: const Color(0xFF38BDF8), label: 'CTL'),
        const SizedBox(width: 12),
        _LegendDot(color: const Color(0xFFFB7185), label: 'ATL'),
        const SizedBox(width: 12),
        _LegendDot(color: const Color(0xFFF59E0B), label: 'TSB'),
        if (_showProjection) ...[
          const SizedBox(width: 12),
          _LegendDot(
            color: const Color(0xFFA855F7),
            label: 'Projected',
            isDashed: true,
          ),
        ],
      ],
    );
  }

  Color _getFormColor(String colorName) {
    switch (colorName) {
      case 'emerald':
        return const Color(0xFF10B981);
      case 'sky':
        return const Color(0xFF38BDF8);
      case 'amber':
        return const Color(0xFFF59E0B);
      case 'rose':
        return const Color(0xFFFB7185);
      default:
        return Colors.white54;
    }
  }
}

class _KpiCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final String? subtitle;

  const _KpiCard({
    required this.label,
    required this.value,
    required this.color,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0xFF111111),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 9,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 2),
              Text(
                subtitle!,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.4),
                  fontSize: 10,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _InsightPill extends StatelessWidget {
  final String label;
  final String value;
  final Color? color;

  const _InsightPill({required this.label, required this.value, this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.4),
            fontSize: 10,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            color: color ?? Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  final bool isDashed;

  const _LegendDot({
    required this.color,
    required this.label,
    this.isDashed = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 2,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(1),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.5),
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}

class _EnhancedPmcChartPainter extends CustomPainter {
  final List<DailyTrainingMetric> historical;
  final List<DailyTrainingMetric> projected;

  _EnhancedPmcChartPainter({
    required this.historical,
    this.projected = const [],
  });

  @override
  void paint(Canvas canvas, Size size) {
    final all = [...historical, ...projected];
    if (all.isEmpty) return;

    final maxCtl = all.map((m) => m.ctl).reduce((a, b) => a > b ? a : b);
    final maxAtl = all.map((m) => m.atl).reduce((a, b) => a > b ? a : b);
    final maxLoad = [maxCtl, maxAtl, 100.0].reduce((a, b) => a > b ? a : b);

    final minTsb = all.map((m) => m.tsb).reduce((a, b) => a < b ? a : b);
    final maxTsb = all.map((m) => m.tsb).reduce((a, b) => a > b ? a : b);
    final tsbRange = (maxTsb - minTsb).abs() < 1 ? 1.0 : maxTsb - minTsb;

    final getX = (int idx) =>
        (idx / (all.length - 1).clamp(1, 999)) * size.width;
    final getYLoad = (double val) =>
        size.height - (val / maxLoad * size.height * 0.8) - size.height * 0.1;
    final getYTsb = (double val) =>
        size.height -
        ((val - minTsb) / tsbRange * size.height * 0.6) -
        size.height * 0.2;

    final ctlPaint = Paint()
      ..color = const Color(0xFF38BDF8)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    final atlPaint = Paint()
      ..color = const Color(0xFFFB7185)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    final tsbPaint = Paint()
      ..color = const Color(0xFFF59E0B)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    // Zero TSB line
    final zeroPaint = Paint()
      ..color = Colors.white24
      ..strokeWidth = 0.5;
    final zeroY = getYTsb(0);
    canvas.drawLine(Offset(0, zeroY), Offset(size.width, zeroY), zeroPaint);

    // Draw historical lines
    if (historical.length > 1) {
      _drawLine(canvas, historical, getX, getYLoad, (m) => m.ctl, ctlPaint);
      _drawLine(canvas, historical, getX, getYLoad, (m) => m.atl, atlPaint);
      _drawLine(canvas, historical, getX, getYTsb, (m) => m.tsb, tsbPaint);
    }

    // Draw projected lines (dashed)
    if (projected.isNotEmpty) {
      final dashedPaint = Paint()
        ..color = const Color(0xFFA855F7)
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke;
      final projCtlPaint = Paint()
        ..color = const Color(0xFF38BDF8)
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke;
      final projAtlPaint = Paint()
        ..color = const Color(0xFFFB7185)
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke;

      // Connect from last historical point
      final lastHistIdx = historical.length - 1;
      final startX = getX(lastHistIdx);
      final startYCtl = getYLoad(historical.last.ctl);
      final startYAtl = getYLoad(historical.last.atl);
      final startYTsb = getYTsb(historical.last.tsb);

      // CTL projection
      final projCtlPath = Path()..moveTo(startX, startYCtl);
      for (int i = 0; i < projected.length; i++) {
        projCtlPath.lineTo(
          getX(lastHistIdx + 1 + i),
          getYLoad(projected[i].ctl),
        );
      }
      canvas.drawPath(projCtlPath, projCtlPaint);

      // ATL projection
      final projAtlPath = Path()..moveTo(startX, startYAtl);
      for (int i = 0; i < projected.length; i++) {
        projAtlPath.lineTo(
          getX(lastHistIdx + 1 + i),
          getYLoad(projected[i].atl),
        );
      }
      canvas.drawPath(projAtlPath, projAtlPaint);

      // TSB projection (dashed)
      final projTsbPath = Path()..moveTo(startX, startYTsb);
      for (int i = 0; i < projected.length; i++) {
        projTsbPath.lineTo(
          getX(lastHistIdx + 1 + i),
          getYTsb(projected[i].tsb),
        );
      }
      canvas.drawPath(projTsbPath, dashedPaint);

      // TODAY line
      final todayPaint = Paint()
        ..color = const Color(0xFFF59E0B)
        ..strokeWidth = 1;
      canvas.drawLine(
        Offset(startX, 0),
        Offset(startX, size.height),
        todayPaint,
      );
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

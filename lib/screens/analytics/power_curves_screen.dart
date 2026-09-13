import 'package:flutter/material.dart';
import '../../models/performance/performance_stats.dart';

class PowerCurvesScreen extends StatelessWidget {
  final PerformanceStatsData? stats;

  const PowerCurvesScreen({super.key, this.stats});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0A0A),
        title: const Text(
          'Power & Pace Curves',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
      ),
      body: stats == null
          ? const Center(
              child: Text(
                'No power data available',
                style: TextStyle(color: Colors.white54),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader(
                    'POWER DURATION PRs',
                    const Color(0xFFF97316),
                  ),
                  const SizedBox(height: 10),
                  ...stats!.powerPRs.map((pr) => _buildPowerPrRow(pr)),
                  const SizedBox(height: 24),
                  _buildSectionHeader(
                    'PACE DURATION PRs',
                    const Color(0xFF3B82F6),
                  ),
                  const SizedBox(height: 10),
                  ...stats!.pacePRs.map((pr) => _buildPacePrRow(pr)),
                  const SizedBox(height: 24),
                  _buildStatsSummary(),
                ],
              ),
            ),
    );
  }

  Widget _buildSectionHeader(String text, Color color) {
    return Text(
      text,
      style: TextStyle(
        color: color,
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 1,
      ),
    );
  }

  Widget _buildPowerPrRow(PowerDurationPR pr) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 60,
            child: Text(
              pr.durationLabel,
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '${pr.watts}W',
            style: const TextStyle(
              color: Color(0xFFF97316),
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
          const Spacer(),
          Text(
            '${pr.wattsPerKg.toStringAsFixed(2)} W/kg',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.4),
              fontSize: 11,
            ),
          ),
          if (pr.isAllTimeBest) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFFF97316).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'PR',
                style: TextStyle(
                  color: Color(0xFFF97316),
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPacePrRow(PaceDurationPR pr) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              pr.distanceLabel,
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            pr.formattedPace,
            style: const TextStyle(
              color: Color(0xFF3B82F6),
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
          const Spacer(),
          Text(
            pr.totalTime,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.4),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'PERFORMANCE METRICS',
            style: TextStyle(
              color: Colors.white54,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _MetricItem(label: 'FTP', value: '${stats!.ftpWatts.round()}W'),
              _MetricItem(
                label: 'W/kg',
                value: stats!.wattsPerKg.toStringAsFixed(2),
              ),
              _MetricItem(
                label: 'VO2 Max',
                value: stats!.vo2MaxEstimate.toStringAsFixed(1),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _MetricItem(label: 'LTHR', value: '${stats!.lthrBpm} bpm'),
              _MetricItem(
                label: 'EF',
                value: stats!.efficiencyFactor.toStringAsFixed(2),
              ),
              _MetricItem(label: 'W\'', value: '${stats!.wPrimeJoules}J'),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetricItem extends StatelessWidget {
  final String label;
  final String value;

  const _MetricItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
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
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

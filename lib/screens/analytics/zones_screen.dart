import 'package:flutter/material.dart';
import '../../models/performance/performance_stats.dart';

class ZonesScreen extends StatelessWidget {
  final PerformanceStatsData? stats;

  const ZonesScreen({super.key, this.stats});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0A0A),
        title: const Text(
          'HR & Power Zones',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
      ),
      body: stats == null
          ? const Center(
              child: Text(
                'No zone data available',
                style: TextStyle(color: Colors.white54),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildZoneDistribution(stats!.zoneDistribution),
                  const SizedBox(height: 24),
                  _buildEightyTwentyAnalysis(stats!.zoneDistribution),
                  const SizedBox(height: 24),
                  _buildZoneDetails(stats!.zoneDistribution),
                ],
              ),
            ),
    );
  }

  Widget _buildZoneDistribution(List<ZoneDistribution> zones) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'ZONE DISTRIBUTION',
          style: TextStyle(
            color: Colors.white54,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 10),
        ...zones.map((z) {
          final pct = z.percentage / 100;
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: _getZoneColor(z.color),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        z.zone,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    Text(
                      '${z.hours.toStringAsFixed(1)}h',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 36,
                      child: Text(
                        '${z.percentage.round()}%',
                        textAlign: TextAlign.end,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.5),
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: pct,
                    backgroundColor: Colors.white.withValues(alpha: 0.06),
                    valueColor: AlwaysStoppedAnimation(_getZoneColor(z.color)),
                    minHeight: 6,
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildEightyTwentyAnalysis(List<ZoneDistribution> zones) {
    double aerobicPct = 0;
    double anaerobicPct = 0;
    for (final z in zones) {
      if (z.zone.contains('Z1') || z.zone.contains('Z2')) {
        aerobicPct += z.percentage;
      } else {
        anaerobicPct += z.percentage;
      }
    }

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
            '80/20 ANALYSIS',
            style: TextStyle(
              color: Colors.white54,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Aerobic (Z1-Z2)',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.5),
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${aerobicPct.round()}%',
                      style: TextStyle(
                        color: aerobicPct >= 75
                            ? const Color(0xFF10B981)
                            : const Color(0xFFF59E0B),
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              Container(width: 1, height: 40, color: Colors.white12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Anaerobic (Z3+)',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.5),
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${anaerobicPct.round()}%',
                      style: TextStyle(
                        color: anaerobicPct <= 25
                            ? const Color(0xFF10B981)
                            : const Color(0xFFF59E0B),
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            aerobicPct >= 75
                ? 'Good polarized distribution'
                : 'Consider more easy zone training',
            style: TextStyle(
              color: aerobicPct >= 75
                  ? const Color(0xFF10B981)
                  : const Color(0xFFF59E0B),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildZoneDetails(List<ZoneDistribution> zones) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'ZONE DESCRIPTIONS',
          style: TextStyle(
            color: Colors.white54,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 10),
        ...zones.map(
          (z) => Container(
            margin: const EdgeInsets.only(bottom: 6),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 30,
                  decoration: BoxDecoration(
                    color: _getZoneColor(z.color),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        z.zone,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        '${z.hours.toStringAsFixed(1)} hours \u00B7 ${z.percentage.round()}%',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.4),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Color _getZoneColor(String colorName) {
    switch (colorName) {
      case 'neutral':
        return const Color(0xFF64748B);
      case 'sky':
        return const Color(0xFF38BDF8);
      case 'emerald':
        return const Color(0xFF10B981);
      case 'amber':
        return const Color(0xFFF59E0B);
      case 'orange':
        return const Color(0xFFF97316);
      case 'rose':
        return const Color(0xFFFB7185);
      case 'purple':
        return const Color(0xFFA855F7);
      default:
        return Colors.white54;
    }
  }
}

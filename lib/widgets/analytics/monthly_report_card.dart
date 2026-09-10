import 'package:flutter/material.dart';
import '../../models/export/monthly_report_data.dart';

class MonthlyReportCard extends StatelessWidget {
  final MonthlyReportData report;
  final VoidCallback? onExport;

  const MonthlyReportCard({super.key, required this.report, this.onExport});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                report.month,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (onExport != null)
                TextButton.icon(
                  onPressed: onExport,
                  icon: const Icon(
                    Icons.download,
                    size: 16,
                    color: Color(0xFFF97316),
                  ),
                  label: const Text(
                    'Export PDF',
                    style: TextStyle(color: Color(0xFFF97316), fontSize: 12),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          _buildStatRow(
            'Distance',
            '${report.volume.totalDistanceKm.toStringAsFixed(1)} km',
          ),
          _buildStatRow('Elevation', '${report.volume.totalElevationMeters} m'),
          _buildStatRow(
            'Active Hours',
            '${report.volume.totalActiveHours.toStringAsFixed(1)} h',
          ),
          _buildStatRow('TSS', '${report.volume.totalTSS}'),
          _buildStatRow('Activities', '${report.volume.totalActivities}'),
          const Divider(color: Colors.white12, height: 20),
          _buildStatRow('CTL', report.pmc.currentCtl.toStringAsFixed(1)),
          _buildStatRow('ATL', report.pmc.currentAtl.toStringAsFixed(1)),
          _buildStatRow(
            'TSB',
            '${report.pmc.currentTsb > 0 ? '+' : ''}${report.pmc.currentTsb}',
          ),
          Text(
            report.pmc.formState,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.5),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.5),
              fontSize: 12,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

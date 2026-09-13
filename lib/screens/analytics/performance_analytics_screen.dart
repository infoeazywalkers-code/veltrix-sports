import 'package:flutter/material.dart';
import '../../models/performance/performance_stats.dart';
import '../../models/activity/activity.dart';
import '../../models/performance/performance_snapshot.dart';
import '../../models/performance/daily_training_metric.dart';
import 'pmc_screen.dart';
import 'power_curves_screen.dart';
import 'zones_screen.dart';

class PerformanceAnalyticsScreen extends StatefulWidget {
  final PerformanceSnapshot? latestSnapshot;
  final List<PerformanceSnapshot> history;
  final List<Activity> recentActivities;
  final List<DailyTrainingMetric> dailyMetrics;
  final PerformanceStatsData? performanceStats;

  const PerformanceAnalyticsScreen({
    super.key,
    this.latestSnapshot,
    this.history = const [],
    this.recentActivities = const [],
    this.dailyMetrics = const [],
    this.performanceStats,
  });

  @override
  State<PerformanceAnalyticsScreen> createState() =>
      _PerformanceAnalyticsScreenState();
}

class _PerformanceAnalyticsScreenState extends State<PerformanceAnalyticsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              indicatorColor: const Color(0xFFF97316),
              labelColor: const Color(0xFFF97316),
              unselectedLabelColor: Colors.white54,
              labelStyle: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
              tabs: const [
                Tab(text: 'Dashboard'),
                Tab(text: 'PMC'),
                Tab(text: 'Power Curves'),
                Tab(text: 'Zones'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _DashboardTab(
                  snapshot: widget.latestSnapshot,
                  activities: widget.recentActivities,
                ),
                _PMCTab(metrics: widget.dailyMetrics, history: widget.history),
                _PowerCurvesTab(stats: widget.performanceStats),
                _ZonesTab(stats: widget.performanceStats),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DashboardTab extends StatelessWidget {
  final PerformanceSnapshot? snapshot;
  final List<Activity> activities;

  const _DashboardTab({this.snapshot, this.activities = const []});

  @override
  Widget build(BuildContext context) {
    final fitness = snapshot?.fitness ?? 0;
    final fatigue = snapshot?.fatigue ?? 0;
    final form = snapshot?.form ?? 0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'TRAINING LOAD STATUS',
            style: TextStyle(
              color: Colors.white54,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _MetricCard(
                label: 'CTL (Fitness)',
                value: fitness.round().toString(),
                color: const Color(0xFF3B82F6),
              ),
              const SizedBox(width: 8),
              _MetricCard(
                label: 'ATL (Fatigue)',
                value: fatigue.round().toString(),
                color: const Color(0xFFF59E0B),
              ),
              const SizedBox(width: 8),
              _MetricCard(
                label: 'TSB (Form)',
                value: '${form >= 0 ? '+' : ''}${form.round()}',
                color:
                    form >= 0
                        ? const Color(0xFF10B981)
                        : const Color(0xFFEF4444),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text(
            'RECENT ACTIVITIES',
            style: TextStyle(
              color: Colors.white54,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 10),
          if (activities.isEmpty)
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Text(
                  'No recent activities',
                  style: TextStyle(color: Colors.white38, fontSize: 13),
                ),
              ),
            )
          else
            ...activities.take(5).map((a) => _ActivityRow(activity: a)),
        ],
      ),
    );
  }
}

class _PMCTab extends StatelessWidget {
  final List<DailyTrainingMetric> metrics;
  final List<PerformanceSnapshot> history;

  const _PMCTab({this.metrics = const [], this.history = const []});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.show_chart, size: 48, color: Colors.white24),
          const SizedBox(height: 12),
          const Text(
            'Performance Management Chart',
            style: TextStyle(color: Colors.white54, fontSize: 14),
          ),
          const SizedBox(height: 6),
          const Text(
            'CTL, ATL, TSB with 7-day forecast',
            style: TextStyle(color: Colors.white38, fontSize: 12),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => PmcScreen(metrics: metrics)),
              );
            },
            icon: const Icon(Icons.arrow_forward, size: 16),
            label: const Text('Open PMC View'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF59E0B),
              foregroundColor: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}

class _PowerCurvesTab extends StatelessWidget {
  final PerformanceStatsData? stats;

  const _PowerCurvesTab({this.stats});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.speed, size: 48, color: Colors.white24),
          const SizedBox(height: 12),
          const Text(
            'Power & Pace Duration Curves',
            style: TextStyle(color: Colors.white54, fontSize: 14),
          ),
          const SizedBox(height: 6),
          const Text(
            'Interactive power and pace PRs',
            style: TextStyle(color: Colors.white38, fontSize: 12),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => PowerCurvesScreen(stats: stats),
                ),
              );
            },
            icon: const Icon(Icons.arrow_forward, size: 16),
            label: const Text('Open Power Curves'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF97316),
              foregroundColor: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}

class _ZonesTab extends StatelessWidget {
  final PerformanceStatsData? stats;

  const _ZonesTab({this.stats});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.bar_chart, size: 48, color: Colors.white24),
          const SizedBox(height: 12),
          const Text(
            'Heart Rate & Power Zones',
            style: TextStyle(color: Colors.white54, fontSize: 14),
          ),
          const SizedBox(height: 6),
          const Text(
            '80/20 distribution analysis',
            style: TextStyle(color: Colors.white38, fontSize: 12),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => ZonesScreen(stats: stats)),
              );
            },
            icon: const Icon(Icons.arrow_forward, size: 16),
            label: const Text('Open Zones View'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3B82F6),
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _MetricCard({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.2)),
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
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActivityRow extends StatelessWidget {
  final Activity activity;
  const _ActivityRow({required this.activity});

  String _sportEmoji(SportType sport) {
    switch (sport) {
      case SportType.cycling:
        return '\u{1F6B4}';
      case SportType.running:
        return '\u{1F3C3}';
      case SportType.trailRunning:
        return '\u26F0\uFE0F';
      case SportType.gravel:
        return '\u{1F6E4}\uFE0F';
      case SportType.rowing:
        return '\u{1F6A3}';
      case SportType.swimming:
        return '\u{1F3CA}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Text(
            _sportEmoji(activity.sport),
            style: const TextStyle(fontSize: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '${activity.distanceKm.toStringAsFixed(1)} km \u00B7 ${activity.elevationGainMeters.round()} m \u00B7 ${activity.tss} TSS',
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
    );
  }
}

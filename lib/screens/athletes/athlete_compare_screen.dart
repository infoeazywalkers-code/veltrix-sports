import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants.dart';
import '../../core/errors/error_handler.dart';
import '../../core/utils/unit_conversion.dart';
import '../../models/activity/activity.dart';
import '../../providers.dart';

/// Side-by-side athlete comparison over 14d / 30d presets (Phase 4).
///
/// Compares the signed-in athlete against [otherUid]. Both sides load via
/// [ActivityService.getUserActivitiesByDateRange]; all math is plain manual
/// sums over the returned lists, with '–' shown wherever data is absent.
class AthleteCompareScreen extends ConsumerStatefulWidget {
  final String otherUid;
  final String? otherName;

  const AthleteCompareScreen({
    super.key,
    required this.otherUid,
    this.otherName,
  });

  @override
  ConsumerState<AthleteCompareScreen> createState() =>
      _AthleteCompareScreenState();
}

typedef _SidePair = ({List<Activity> mine, List<Activity> theirs});

class _AthleteCompareScreenState extends ConsumerState<AthleteCompareScreen> {
  int _days = 30;
  late Future<_SidePair> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<_SidePair> _load() async {
    final me = ref.read(currentUserProvider);
    final service = ref.read(activityServiceProvider);
    final end = DateTime.now();
    final start = end.subtract(Duration(days: _days));
    final results = await Future.wait([
      service.getUserActivitiesByDateRange(me!.uid, start, end),
      service.getUserActivitiesByDateRange(widget.otherUid, start, end),
    ]);
    return (mine: results[0], theirs: results[1]);
  }

  void _setDays(int days) {
    if (days == _days) return;
    setState(() {
      _days = days;
      _future = _load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final me = ref.watch(currentUserProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.otherName != null && widget.otherName!.isNotEmpty
              ? 'You vs ${widget.otherName}'
              : 'Compare',
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      body: me == null
          ? const _SignInRequiredState()
          : ListView(
              padding: const EdgeInsets.all(18),
              children: [
                SegmentedButton<int>(
                  segments: const [
                    ButtonSegment(value: 14, label: Text('14 days')),
                    ButtonSegment(value: 30, label: Text('30 days')),
                  ],
                  selected: {_days},
                  showSelectedIcon: false,
                  onSelectionChanged: (v) => _setDays(v.first),
                ),
                const SizedBox(height: 16),
                FutureBuilder<_SidePair>(
                  future: _future,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 64),
                        child: Center(
                          child: CircularProgressIndicator(color: navy),
                        ),
                      );
                    }
                    if (snapshot.hasError) {
                      return _ErrorState(
                        message: ErrorHandler.getUserMessage(snapshot.error!),
                        onRetry: () => setState(() => _future = _load()),
                      );
                    }
                    final pair =
                        snapshot.data ??
                        (mine: const <Activity>[], theirs: const <Activity>[]);
                    final mine = summarizeActivities(pair.mine);
                    final theirs = summarizeActivities(pair.theirs);
                    if (mine.count == 0 && theirs.count == 0) {
                      return _EmptyState(days: _days);
                    }
                    final end = DateTime.now();
                    final start = end.subtract(Duration(days: _days));
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (me.uid == widget.otherUid)
                          _SelfNote(isDark: isDark),
                        _VersusHeader(
                          otherName: widget.otherName,
                          isDark: isDark,
                        ),
                        const SizedBox(height: 12),
                        _DeltaCard(mine: mine, theirs: theirs, isDark: isDark),
                        const SizedBox(height: 16),
                        _WeeklyTssCard(
                          mine: pair.mine,
                          theirs: pair.theirs,
                          start: start,
                          days: _days,
                          isDark: isDark,
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
    );
  }
}

/// Manual sums over a side's activities. Null-bearing fields yield null
/// averages so the UI can render '–' instead of crashing.
@visibleForTesting
_CompareSummary summarizeActivities(List<Activity> activities) {
  var distanceKm = 0.0;
  var elevationM = 0.0;
  var tss = 0;
  var speedSum = 0.0;
  var speedCount = 0;
  var hrSum = 0;
  var hrCount = 0;
  for (final a in activities) {
    distanceKm += a.distanceKm;
    elevationM += a.elevationGainMeters;
    tss += a.tss;
    if (a.avgSpeedKmh > 0) {
      speedSum += a.avgSpeedKmh;
      speedCount++;
    }
    if (a.avgHeartRate != null) {
      hrSum += a.avgHeartRate!;
      hrCount++;
    }
  }
  return _CompareSummary(
    distanceKm: distanceKm,
    elevationM: elevationM,
    tss: tss,
    count: activities.length,
    avgSpeedKmh: speedCount == 0 ? null : speedSum / speedCount,
    avgHr: hrCount == 0 ? null : hrSum / hrCount,
  );
}

class _CompareSummary {
  final double distanceKm;
  final double elevationM;
  final int tss;
  final int count;
  final double? avgSpeedKmh;
  final double? avgHr;

  const _CompareSummary({
    required this.distanceKm,
    required this.elevationM,
    required this.tss,
    required this.count,
    required this.avgSpeedKmh,
    required this.avgHr,
  });
}

/// TSS summed into 7-day buckets starting at [start].
@visibleForTesting
List<double> weeklyTssBuckets(
  List<Activity> activities,
  DateTime start,
  int days,
) {
  final weeks = (days / 7).ceil();
  final buckets = List<double>.filled(weeks, 0);
  for (final a in activities) {
    final idx = a.date.difference(start).inDays ~/ 7;
    if (idx >= 0 && idx < weeks) buckets[idx] += a.tss.toDouble();
  }
  return buckets;
}

class _SignInRequiredState extends StatelessWidget {
  const _SignInRequiredState();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.lock_outline,
              size: 56,
              color: isDark ? Colors.white : navy,
            ),
            const SizedBox(height: 16),
            Text(
              'Sign in to compare',
              style: TextStyle(
                color: isDark ? Colors.white : navy,
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Comparison needs your recent activities. Sign in first.',
              textAlign: TextAlign.center,
              style: TextStyle(color: isDark ? const Color(0xFF78909C) : muted),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          FilledButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final int days;

  const _EmptyState({required this.days});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.compare_arrows_outlined,
            size: 56,
            color: isDark ? Colors.white : navy,
          ),
          const SizedBox(height: 16),
          Text(
            'No activities in the last $days days',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isDark ? Colors.white : navy,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Neither athlete logged anything in this period.',
            textAlign: TextAlign.center,
            style: TextStyle(color: isDark ? const Color(0xFF78909C) : muted),
          ),
        ],
      ),
    );
  }
}

class _SelfNote extends StatelessWidget {
  final bool isDark;

  const _SelfNote({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        'This is your own profile — both sides show your data.',
        style: TextStyle(
          color: isDark ? const Color(0xFF78909C) : muted,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _VersusHeader extends StatelessWidget {
  final String? otherName;
  final bool isDark;

  const _VersusHeader({required this.otherName, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _SideLabel(
            label: 'You',
            color: isDark ? lime : navy,
            alignRight: false,
          ),
        ),
        Text(
          'vs',
          style: TextStyle(
            color: isDark ? const Color(0xFF78909C) : muted,
            fontWeight: FontWeight.w800,
          ),
        ),
        Expanded(
          child: _SideLabel(
            label: otherName != null && otherName!.isNotEmpty
                ? otherName!
                : 'Athlete',
            color: orange,
            alignRight: true,
          ),
        ),
      ],
    );
  }
}

class _SideLabel extends StatelessWidget {
  final String label;
  final Color color;
  final bool alignRight;

  const _SideLabel({
    required this.label,
    required this.color,
    required this.alignRight,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: alignRight
          ? MainAxisAlignment.end
          : MainAxisAlignment.start,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            label,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15),
          ),
        ),
      ],
    );
  }
}

class _DeltaCard extends ConsumerWidget {
  final _CompareSummary mine;
  final _CompareSummary theirs;
  final bool isDark;

  const _DeltaCard({
    required this.mine,
    required this.theirs,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final units = ref.watch(unitSystemProvider);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _DeltaRow(
              label: 'Distance',
              mine: UnitConversion.formatDistance(units, mine.distanceKm),
              theirs: UnitConversion.formatDistance(units, theirs.distanceKm),
              delta: _signed(
                '${(mine.distanceKm - theirs.distanceKm).abs().toStringAsFixed(1)} km',
                mine.distanceKm - theirs.distanceKm,
              ),
              isDark: isDark,
            ),
            const SizedBox(height: 10),
            _DeltaRow(
              label: 'Elevation',
              mine: UnitConversion.formatElevation(units, mine.elevationM),
              theirs: UnitConversion.formatElevation(units, theirs.elevationM),
              delta: _signed(
                '${(mine.elevationM - theirs.elevationM).abs().round()} m',
                mine.elevationM - theirs.elevationM,
              ),
              isDark: isDark,
            ),
            const SizedBox(height: 10),
            _DeltaRow(
              label: 'TSS',
              mine: '${mine.tss}',
              theirs: '${theirs.tss}',
              delta: _signedInt(mine.tss - theirs.tss),
              isDark: isDark,
            ),
            const SizedBox(height: 10),
            _DeltaRow(
              label: 'Activities',
              mine: '${mine.count}',
              theirs: '${theirs.count}',
              delta: _signedInt(mine.count - theirs.count),
              isDark: isDark,
            ),
            const SizedBox(height: 10),
            _DeltaRow(
              label: 'Avg speed',
              mine: mine.avgSpeedKmh == null
                  ? '–'
                  : '${mine.avgSpeedKmh!.toStringAsFixed(1)} km/h',
              theirs: theirs.avgSpeedKmh == null
                  ? '–'
                  : '${theirs.avgSpeedKmh!.toStringAsFixed(1)} km/h',
              delta: mine.avgSpeedKmh == null || theirs.avgSpeedKmh == null
                  ? '–'
                  : _signed(
                      '${(mine.avgSpeedKmh! - theirs.avgSpeedKmh!).abs().toStringAsFixed(1)} km/h',
                      mine.avgSpeedKmh! - theirs.avgSpeedKmh!,
                    ),
              isDark: isDark,
            ),
            const SizedBox(height: 10),
            _DeltaRow(
              label: 'Avg HR',
              mine: mine.avgHr == null ? '–' : '${mine.avgHr!.round()} bpm',
              theirs: theirs.avgHr == null
                  ? '–'
                  : '${theirs.avgHr!.round()} bpm',
              delta: mine.avgHr == null || theirs.avgHr == null
                  ? '–'
                  : _signedInt(
                      (mine.avgHr! - theirs.avgHr!).round(),
                      suffix: ' bpm',
                    ),
              isDark: isDark,
            ),
          ],
        ),
      ),
    );
  }

  String _signed(String magnitude, double diff) {
    if (diff == 0) return '±0';
    return '${diff > 0 ? '+' : '−'}$magnitude';
  }

  String _signedInt(int diff, {String suffix = ''}) {
    if (diff == 0) return '±0$suffix';
    return '${diff > 0 ? '+' : '−'}${diff.abs()}$suffix';
  }
}

class _DeltaRow extends StatelessWidget {
  final String label;
  final String mine;
  final String theirs;
  final String delta;
  final bool isDark;

  const _DeltaRow({
    required this.label,
    required this.mine,
    required this.theirs,
    required this.delta,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final labelStyle = TextStyle(
      color: isDark ? const Color(0xFF78909C) : muted,
      fontSize: 12,
    );
    const valueStyle = TextStyle(fontWeight: FontWeight.w800, fontSize: 13);
    return Row(
      children: [
        Expanded(flex: 3, child: Text(label, style: labelStyle)),
        Expanded(flex: 3, child: Text(mine, style: valueStyle)),
        Expanded(
          flex: 3,
          child: Text(theirs, textAlign: TextAlign.center, style: valueStyle),
        ),
        Expanded(
          flex: 3,
          child: Text(
            delta,
            textAlign: TextAlign.right,
            style: valueStyle.copyWith(color: isDark ? lime : navy),
          ),
        ),
      ],
    );
  }
}

class _WeeklyTssCard extends StatelessWidget {
  final List<Activity> mine;
  final List<Activity> theirs;
  final DateTime start;
  final int days;
  final bool isDark;

  const _WeeklyTssCard({
    required this.mine,
    required this.theirs,
    required this.start,
    required this.days,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final mineBuckets = weeklyTssBuckets(mine, start, days);
    final theirsBuckets = weeklyTssBuckets(theirs, start, days);
    var maxTss = 0.0;
    for (var i = 0; i < mineBuckets.length; i++) {
      maxTss = math.max(maxTss, mineBuckets[i]);
      maxTss = math.max(maxTss, theirsBuckets[i]);
    }
    final meColor = isDark ? lime : navy;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Weekly TSS',
              style: TextStyle(
                color: isDark ? Colors.white : navy,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Training load per 7-day bucket',
              style: TextStyle(
                color: isDark ? const Color(0xFF78909C) : muted,
                fontSize: 11,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 190,
              child: BarChart(
                BarChartData(
                  maxY: maxTss <= 0 ? 10 : maxTss * 1.2,
                  barGroups: [
                    for (var i = 0; i < mineBuckets.length; i++)
                      BarChartGroupData(
                        x: i,
                        barsSpace: 4,
                        barRods: [
                          BarChartRodData(
                            toY: mineBuckets[i],
                            color: meColor,
                            width: 12,
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(3),
                            ),
                          ),
                          BarChartRodData(
                            toY: theirsBuckets[i],
                            color: orange,
                            width: 12,
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(3),
                            ),
                          ),
                        ],
                      ),
                  ],
                  titlesData: FlTitlesData(
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 36,
                        getTitlesWidget: (value, _) => Text(
                          value.toInt().toString(),
                          style: TextStyle(
                            color: isDark ? const Color(0xFF78909C) : muted,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, _) {
                          final i = value.toInt();
                          if (i < 0 || i >= mineBuckets.length) {
                            return const SizedBox.shrink();
                          }
                          return Text(
                            'W${i + 1}',
                            style: TextStyle(
                              color: isDark ? const Color(0xFF78909C) : muted,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  gridData: const FlGridData(
                    show: true,
                    drawVerticalLine: false,
                  ),
                  borderData: FlBorderData(show: false),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

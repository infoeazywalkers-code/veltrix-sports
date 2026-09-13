import 'package:meta/meta.dart';

import '../activity/activity_service.dart';
import '../performance/performance_service.dart';

/// A 0-100 race readiness breakdown for one event.
///
/// All component points are hand-checkable: [score] is always exactly
/// `fitnessPts + freshnessPts + consistencyPts + taperPts` clamped to 0-100.
class RaceReadiness {
  /// Total score, 0-100.
  final int score;

  /// Fitness component, 0-40 (absolute CTL bands).
  final int fitnessPts;

  /// Freshness component, 0-25 (TSB mapped around the +5..+25 peak zone).
  final int freshnessPts;

  /// Consistency component, 0-20 (active days in the last 28, /24 scaled).
  final int consistencyPts;

  /// Taper-timing component, 0-15 (days-out vs TSB deductions).
  final int taperPts;

  /// 80+ 'Race ready', 60+ 'On track', 40+ 'Needs work', else 'At risk'.
  final String verdict;

  /// 1-2 sentences driven by (daysOut, tsb).
  final String taperAdvice;

  /// Whole days from now until the event date (>= 0).
  final int daysOut;

  const RaceReadiness({
    required this.score,
    required this.fitnessPts,
    required this.freshnessPts,
    required this.consistencyPts,
    required this.taperPts,
    required this.verdict,
    required this.taperAdvice,
    required this.daysOut,
  });
}

/// Transparent readiness heuristics — deliberately simple and honest.
///
/// Scoring (every branch clamped):
/// - fitness (0-40): absolute CTL bands. CTL >= 70 earns full points;
///   below that it scales linearly as (ctl / 70) * 40.
/// - freshness (0-25): TSB in +5..+25 earns full points (mirrors
///   [PmcService.getFormState]'s 'Race Ready / Peak Freshness' zone).
///   It tapers linearly toward both extremes: from +5 down to -30 it
///   falls to 0, and from +25 up to +40 it falls to 0.
/// - consistency (0-20): activeDaysLast28 / 24 scaled (a ~6-days-a-week
///   benchmark), so 24+ active days earns full points.
/// - taper timing (0-15): starts at 15. Far-out yet already very fresh
///   (daysOut > 21 and tsb >= 5) deducts 8 — there is still time to bank
///   fitness instead of resting. Close-in yet deeply fatigued
///   (daysOut <= 7 and tsb <= -10) deducts 8 — fatigue must be shed.
/// - score: the plain sum of the four components, clamped to 0-100.
///
/// No physiology beyond these documented heuristics is claimed.
@visibleForTesting
RaceReadiness computeReadiness({
  required double ctl,
  required double atl,
  required double tsb,
  required int activeDaysLast28,
  required int daysOut,
}) {
  final int fitnessPts = _fitnessPoints(ctl);
  final int freshnessPts = _freshnessPoints(tsb);
  final int consistencyPts = _consistencyPoints(activeDaysLast28);
  final int safeDaysOut = daysOut < 0 ? 0 : daysOut;
  final int taperPts = _taperPoints(safeDaysOut, tsb);
  final int score = (fitnessPts + freshnessPts + consistencyPts + taperPts)
      .clamp(0, 100);

  final String verdict;
  if (score >= 80) {
    verdict = 'Race ready';
  } else if (score >= 60) {
    verdict = 'On track';
  } else if (score >= 40) {
    verdict = 'Needs work';
  } else {
    verdict = 'At risk';
  }

  final bool hasTrainingData = ctl > 0 || activeDaysLast28 > 0;
  final String taperAdvice;
  if (!hasTrainingData) {
    taperAdvice =
        'Log activities to build readiness — your score will update as training syncs.';
  } else if (safeDaysOut > 21) {
    taperAdvice =
        tsb >= 5
            ? 'Build phase — keep stacking volume. You are fresh with time to spare, so bank fitness now.'
            : 'Build phase — keep stacking volume.';
  } else if (safeDaysOut >= 7) {
    taperAdvice =
        tsb <= -10
            ? 'Pre-taper — hold intensity, trim volume ~10%/wk to shed fatigue.'
            : 'Pre-taper — hold intensity, trim volume ~10%/wk.';
  } else {
    taperAdvice =
        tsb <= -10
            ? 'Race week — stay fresh, no hero workouts. Prioritize sleep and easy movement to shed fatigue.'
            : 'Race week — stay fresh, no hero workouts.';
  }

  return RaceReadiness(
    score: score,
    fitnessPts: fitnessPts,
    freshnessPts: freshnessPts,
    consistencyPts: consistencyPts,
    taperPts: taperPts,
    verdict: verdict,
    taperAdvice: taperAdvice,
    daysOut: safeDaysOut,
  );
}

int _fitnessPoints(double ctl) {
  if (ctl >= 70) return 40;
  return (40 * ctl / 70).clamp(0, 40).round();
}

int _freshnessPoints(double tsb) {
  // Peak zone mirrors PmcService.getFormState's 'Race Ready' band.
  if (tsb >= 5 && tsb <= 25) return 25;
  if (tsb < 5) {
    // Linear falloff from (tsb=+5 → 25) down to (tsb=-30 → 0).
    return (25 * (tsb + 30) / 35).clamp(0, 25).round();
  }
  // tsb > 25: linear falloff from (tsb=+25 → 25) down to (tsb=+40 → 0),
  // i.e. over-rested / detraining territory.
  return (25 * (40 - tsb) / 15).clamp(0, 25).round();
}

int _consistencyPoints(int activeDaysLast28) {
  final int safe = activeDaysLast28 < 0 ? 0 : activeDaysLast28;
  return (20 * safe / 24).clamp(0, 20).round();
}

int _taperPoints(int daysOut, double tsb) {
  var pts = 15;
  if (daysOut > 21 && tsb >= 5) pts -= 8;
  if (daysOut <= 7 && tsb <= -10) pts -= 8;
  return pts.clamp(0, 15);
}

/// Wires real training inputs into [computeReadiness].
///
/// - CTL/ATL/TSB come from the latest [PerformanceSnapshot]
///   (`fitness`/`fatigue`/`form` — the same snapshot
///   `progress_screen` consumes via `latestPerformanceProvider`).
/// - Active days come from the signed-in user's activities in the last
///   28 days via [ActivityService.getUserActivitiesByDateRange]
///   (distinct calendar days).
/// - daysOut comes from the event date.
///
/// Missing data (signed-out upstream, no snapshot, no activities) is never
/// fabricated: inputs default to 0, which yields an honest low score with
/// a 'Log activities' hint. Dependencies are injectable for testability.
class RaceReadinessService {
  final Future<({double atl, double ctl, double tsb})?> Function(String userId)
  _fetchForm;
  final Future<int> Function(String userId, DateTime start, DateTime end)
  _countActiveDays;

  RaceReadinessService({
    Future<({double atl, double ctl, double tsb})?> Function(String userId)?
    fetchForm,
    Future<int> Function(String userId, DateTime start, DateTime end)?
    countActiveDays,
  }) : _fetchForm = fetchForm ?? _defaultFetchForm,
       _countActiveDays = countActiveDays ?? _defaultCountActiveDays;

  /// Computes readiness for [eventDate] as seen by [userId].
  ///
  /// [now] is injectable so countdown math stays deterministic in tests.
  Future<RaceReadiness> readinessForEvent({
    required String userId,
    required DateTime eventDate,
    DateTime? now,
  }) async {
    final DateTime today = now ?? DateTime.now();
    final int daysOut = eventDate.difference(today).inDays;

    double ctl = 0;
    double atl = 0;
    double tsb = 0;
    try {
      final form = await _fetchForm(userId);
      if (form != null) {
        ctl = form.ctl;
        atl = form.atl;
        tsb = form.tsb;
      }
    } catch (_) {
      // No snapshot available — fall through to the honest zero-data score.
    }

    int activeDays = 0;
    try {
      activeDays = await _countActiveDays(
        userId,
        today.subtract(const Duration(days: 28)),
        today,
      );
    } catch (_) {
      // No activities readable — fall through to the honest zero-data score.
    }

    return computeReadiness(
      ctl: ctl,
      atl: atl,
      tsb: tsb,
      activeDaysLast28: activeDays,
      daysOut: daysOut,
    );
  }

  static Future<({double atl, double ctl, double tsb})?> _defaultFetchForm(
    String userId,
  ) async {
    final snapshot = await PerformanceService().getLatest(userId);
    if (snapshot == null) return null;
    return (ctl: snapshot.fitness, atl: snapshot.fatigue, tsb: snapshot.form);
  }

  static Future<int> _defaultCountActiveDays(
    String userId,
    DateTime start,
    DateTime end,
  ) async {
    final activities = await ActivityService().getUserActivitiesByDateRange(
      userId,
      start,
      end,
    );
    final Set<String> days = <String>{};
    for (final activity in activities) {
      final d = activity.date;
      days.add('${d.year}-${d.month}-${d.day}');
    }
    return days.length;
  }
}

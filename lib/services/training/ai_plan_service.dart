import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../models/activity/activity.dart';

class AIPlanService {
  final String? _baseUrl;

  AIPlanService({String? baseUrl}) : _baseUrl = baseUrl;

  /// Request AI recovery insights based on training load metrics
  Future<Map<String, dynamic>> requestRecoveryInsights({
    required double ctl,
    required double atl,
    required double tsb,
    required double rampRate,
  }) async {
    if (_baseUrl != null) {
      try {
        final res = await http
            .post(
              Uri.parse('$_baseUrl/api/ai/recovery-insights'),
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode({
                'ctl': ctl,
                'atl': atl,
                'tsb': tsb,
                'rampRate': rampRate,
              }),
            )
            .timeout(const Duration(seconds: 8));

        if (res.statusCode == 200) {
          return jsonDecode(res.body);
        }
      } catch (_) {}
    }

    // Client-side fallback
    return _generateFallbackInsights(ctl, atl, tsb, rampRate);
  }

  Map<String, dynamic> _generateFallbackInsights(
    double ctl,
    double atl,
    double tsb,
    double rampRate,
  ) {
    final ctlR = ctl.round();
    final atlR = atl.round();
    final tsbR = tsb.round();

    String status;
    String badge;
    String s1;
    String s2;
    String s3;
    int targetTss;
    String nextSession;

    if (tsb < -30) {
      status = 'overreaching_alert';
      badge = 'High Fatigue Risk';
      targetTss = 25;
      nextSession = 'Zone 1 Recovery Spin or Rest';
      s1 =
          'TSB of $tsbR (CTL $ctlR vs ATL $atlR) places you in acute overreaching risk.';
      s2 =
          'Ramp rate of ${rampRate > 0 ? '+' : ''}${rampRate.toStringAsFixed(1)} TSS/wk is taxing your autonomic system.';
      s3 =
          'Take a complete rest day or light 30-minute Zone 1 spin to restore recovery.';
    } else if (tsb > 5) {
      status = 'optimal_freshness';
      badge = 'Peak Freshness';
      targetTss = 45;
      nextSession = 'Race Openers + Z2';
      s1 =
          'Positive TSB of +$tsbR with CTL $ctlR means peak neuromuscular snap.';
      s2 = 'Acute fatigue (ATL $atlR) has shed while fitness is preserved.';
      s3 =
          'Keep workouts short with brief high-cadence openers over the next 48 hours.';
    } else {
      status = 'productive_overload';
      badge = 'Productive Overload';
      targetTss = 70;
      nextSession = 'Sweet Spot or Zone 2 Endurance';
      s1 = 'TSB of $tsbR confirms productive progressive overload phase.';
      s2 =
          'Healthy ramp rate of ${rampRate > 0 ? '+' : ''}${rampRate.toStringAsFixed(1)} TSS/wk stimulating adaptation.';
      s3 =
          'Continue planned progression with high-carb fueling and schedule recovery within 48 hours.';
    }

    return {
      'threeSentenceSummary': '$s1 $s2 $s3',
      'recoveryStatus': status,
      'statusBadge': badge,
      'actionableRecommendation': s3,
      'nextSessionGuidance': nextSession,
      'targetTssToday': targetTss,
      'metricsAnalyzed': {
        'ctl': ctlR,
        'atl': atlR,
        'tsb': tsbR,
        'rampRate': rampRate,
      },
      'source': 'physiological_model',
    };
  }

  /// Generate a deterministic base training plan
  Map<String, dynamic> generateBasePlan({
    required SportType sport,
    required String philosophy,
    required String level,
    required int totalWeeks,
    required double targetWeeklyHours,
    required double ftpWatts,
    required double lthrBpm,
    required double weightKg,
  }) {
    final wPerKg = (ftpWatts / weightKg).toStringAsFixed(2);
    final baseTssPerHour =
        philosophy == 'sweet_spot'
            ? 62
            : philosophy == 'polarized'
            ? 52
            : 56;
    final initialWeeklyTSS = (targetWeeklyHours * baseTssPerHour).round();

    final weeklyTSSProgression = <int>[];
    final weeks = <Map<String, dynamic>>[];

    for (int w = 1; w <= totalWeeks; w++) {
      final isRecoveryWeek = w % 4 == 0 || w == totalWeeks;
      final factor = isRecoveryWeek ? 0.65 : 1 + (w - 1) * 0.06;
      final weekTSS = (initialWeeklyTSS * factor).round();
      final weekHours = double.parse(
        (targetWeeklyHours * (isRecoveryWeek ? 0.7 : 1 + (w - 1) * 0.04))
            .toStringAsFixed(1),
      );
      weeklyTSSProgression.add(weekTSS);

      weeks.add({
        'weekNumber': w,
        'theme':
            isRecoveryWeek
                ? 'Week $w: Recovery & Adaptation'
                : 'Week $w: Progressive Build',
        'focus':
            isRecoveryWeek
                ? 'Active recovery and tissue remodeling.'
                : 'Targeted threshold intervals and aerobic volume.',
        'targetWeeklyHours': weekHours,
        'targetWeeklyTSS': weekTSS,
        'isRecoveryWeek': isRecoveryWeek,
      });
    }

    return {
      'id': 'base-plan-${DateTime.now().millisecondsSinceEpoch}',
      'title':
          '${weightKg}kg / ${ftpWatts.round()}W ($wPerKg W/kg) Base Training Plan',
      'sport': sport.name,
      'philosophy': philosophy,
      'level': level,
      'totalWeeks': totalWeeks,
      'targetWeeklyHours': targetWeeklyHours,
      'weeklyTSSProgression': weeklyTSSProgression,
      'weeks': weeks,
      'createdAt': DateTime.now().toIso8601String(),
    };
  }
}

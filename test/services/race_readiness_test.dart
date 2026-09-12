import 'package:flutter_test/flutter_test.dart';
import 'package:veltrix_sports/services/performance/race_readiness_service.dart';

void main() {
  group('computeReadiness', () {
    test('peak form scores high and is race ready', () {
      // CTL 75 (full fitness), TSB +12 (peak zone), 22 active days.
      final result = computeReadiness(
        ctl: 75,
        atl: 60,
        tsb: 12,
        activeDaysLast28: 22,
        daysOut: 10,
      );

      expect(result.fitnessPts, 40);
      expect(result.freshnessPts, 25);
      expect(result.consistencyPts, 18);
      expect(result.taperPts, 15);
      // Hand-check: 40 + 25 + 18 + 15 = 98.
      expect(result.score, 98);
      expect(result.verdict, 'Race ready');
      expect(result.daysOut, 10);
      expect(result.taperAdvice, contains('Pre-taper'));
    });

    test('deep fatigue scores low and is at risk', () {
      // CTL 30, TSB -30 (floor), 5 active days, 3 days out and exhausted.
      final result = computeReadiness(
        ctl: 30,
        atl: 60,
        tsb: -30,
        activeDaysLast28: 5,
        daysOut: 3,
      );

      // Hand-check: 17 + 0 + 4 + 7 = 28.
      expect(result.fitnessPts, 17);
      expect(result.freshnessPts, 0);
      expect(result.consistencyPts, 4);
      expect(result.taperPts, 7);
      expect(result.score, 28);
      expect(result.verdict, 'At risk');
      expect(result.taperAdvice, contains('Race week'));
    });

    test('no training yields an honest low score with a logging hint', () {
      final result = computeReadiness(
        ctl: 0,
        atl: 0,
        tsb: 0,
        activeDaysLast28: 0,
        daysOut: 30,
      );

      // Hand-check: 0 + 21 + 0 + 15 = 36 — low, never a fake mid score.
      expect(result.score, lessThan(40));
      expect(result.verdict, 'At risk');
      expect(result.taperAdvice, contains('Log activities'));
    });

    test('far-out freshness deducts taper points (bank fitness now)', () {
      const base = (ctl: 80.0, atl: 70.0, tsb: 10.0, activeDaysLast28: 20);
      final farOut = computeReadiness(
        ctl: base.ctl,
        atl: base.atl,
        tsb: base.tsb,
        activeDaysLast28: base.activeDaysLast28,
        daysOut: 30,
      );
      final nearRace = computeReadiness(
        ctl: base.ctl,
        atl: base.atl,
        tsb: base.tsb,
        activeDaysLast28: base.activeDaysLast28,
        daysOut: 10,
      );

      expect(farOut.taperPts, 7);
      expect(nearRace.taperPts, 15);
      expect(nearRace.score - farOut.score, 8);
      expect(farOut.taperAdvice, contains('bank fitness now'));
      expect(farOut.taperAdvice, contains('Build phase'));
    });

    test('close-in fatigue deducts taper points (shed fatigue)', () {
      final raceWeek = computeReadiness(
        ctl: 60,
        atl: 75,
        tsb: -15,
        activeDaysLast28: 18,
        daysOut: 5,
      );
      final preTaper = computeReadiness(
        ctl: 60,
        atl: 75,
        tsb: -15,
        activeDaysLast28: 18,
        daysOut: 14,
      );

      expect(raceWeek.taperPts, 7);
      expect(preTaper.taperPts, 15);
      expect(raceWeek.taperAdvice, contains('Race week'));
      expect(preTaper.taperAdvice, contains('Pre-taper'));
    });

    test('verdict boundaries', () {
      RaceReadiness build({
        required double ctl,
        required double tsb,
        required int active,
        required int daysOut,
      }) => computeReadiness(
        ctl: ctl,
        atl: 0,
        tsb: tsb,
        activeDaysLast28: active,
        daysOut: daysOut,
      );

      // 40 + 25 + 0 + 15 = 80.
      expect(build(ctl: 70, tsb: 10, active: 0, daysOut: 10).score, 80);
      expect(
        build(ctl: 70, tsb: 10, active: 0, daysOut: 10).verdict,
        'Race ready',
      );
      // 40 + 24 + 0 + 15 = 79.
      expect(build(ctl: 70, tsb: 3.6, active: 0, daysOut: 10).score, 79);
      expect(
        build(ctl: 70, tsb: 3.6, active: 0, daysOut: 10).verdict,
        'On track',
      );
      // 40 + 1 + 4 + 15 = 60.
      expect(build(ctl: 70, tsb: -28, active: 5, daysOut: 10).score, 60);
      expect(
        build(ctl: 70, tsb: -28, active: 5, daysOut: 10).verdict,
        'On track',
      );
      // 40 + 1 + 3 + 15 = 59.
      expect(build(ctl: 70, tsb: -28.5, active: 4, daysOut: 10).score, 59);
      expect(
        build(ctl: 70, tsb: -28.5, active: 4, daysOut: 10).verdict,
        'Needs work',
      );
      // 20 + 0 + 5 + 15 = 40.
      expect(build(ctl: 35, tsb: -30, active: 6, daysOut: 10).score, 40);
      expect(
        build(ctl: 35, tsb: -30, active: 6, daysOut: 10).verdict,
        'Needs work',
      );
      // 20 + 0 + 4 + 15 = 39.
      expect(build(ctl: 35, tsb: -30, active: 5, daysOut: 10).score, 39);
      expect(
        build(ctl: 35, tsb: -30, active: 5, daysOut: 10).verdict,
        'At risk',
      );
    });

    test('score is clamped and equals the component sum', () {
      final extreme = computeReadiness(
        ctl: 500,
        atl: 0,
        tsb: 200,
        activeDaysLast28: 500,
        daysOut: 500,
      );
      expect(extreme.fitnessPts, 40);
      expect(extreme.freshnessPts, 0);
      expect(extreme.consistencyPts, 20);
      expect(extreme.score, lessThanOrEqualTo(100));
      expect(extreme.score, greaterThanOrEqualTo(0));
      expect(
        extreme.score,
        extreme.fitnessPts +
            extreme.freshnessPts +
            extreme.consistencyPts +
            extreme.taperPts,
      );

      final negative = computeReadiness(
        ctl: -5,
        atl: 0,
        tsb: -100,
        activeDaysLast28: -3,
        daysOut: -10,
      );
      expect(negative.fitnessPts, 0);
      expect(negative.freshnessPts, 0);
      expect(negative.consistencyPts, 0);
      expect(negative.daysOut, 0);
      expect(negative.score, greaterThanOrEqualTo(0));
      expect(
        negative.score,
        negative.fitnessPts +
            negative.freshnessPts +
            negative.consistencyPts +
            negative.taperPts,
      );
    });
  });

  group('RaceReadinessService', () {
    test(
      'wires injected inputs and computes daysOut deterministically',
      () async {
        final service = RaceReadinessService(
          fetchForm: (_) async => (ctl: 75.0, atl: 60.0, tsb: 12.0),
          countActiveDays: (_, _, _) async => 22,
        );

        final result = await service.readinessForEvent(
          userId: 'athlete-1',
          eventDate: DateTime(2026, 10, 25),
          now: DateTime(2026, 9, 12),
        );

        expect(result.daysOut, 43);
        // 40 + 25 + 18 + 7 (far-out fresh taper deduction) = 90.
        expect(result.score, 90);
        expect(result.verdict, 'Race ready');
      },
    );

    test('failing inputs fall back to an honest low score', () async {
      final service = RaceReadinessService(
        fetchForm: (_) async => throw Exception('no snapshot'),
        countActiveDays: (_, _, _) async => throw Exception('no activities'),
      );

      final result = await service.readinessForEvent(
        userId: 'athlete-1',
        eventDate: DateTime(2026, 10, 25),
        now: DateTime(2026, 9, 12),
      );

      expect(result.score, lessThan(40));
      expect(result.verdict, 'At risk');
      expect(result.taperAdvice, contains('Log activities'));
    });
  });
}

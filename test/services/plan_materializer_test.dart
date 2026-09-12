import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:veltrix_sports/models/activity/workout.dart';
import 'package:veltrix_sports/services/training/plan_materializer.dart';
import 'package:veltrix_sports/services/training/plan_templates.dart';
import 'package:veltrix_sports/services/training/training_plan_service.dart';

void main() {
  group('buildTemplateWorkouts', () {
    test('template expands to N workouts across duration weeks', () {
      final template = kPlanTemplates['4']!; // 8 weeks x 3/wk
      final startMonday = DateTime(2026, 9, 14);
      final workouts = buildTemplateWorkouts(
        userId: 'u1',
        planId: 'p1',
        startMonday: startMonday,
        durationWeeks: template.durationWeeks,
        template: template.workouts,
      );

      expect(
        workouts.length,
        template.durationWeeks * template.workouts.length,
      );
    });

    test('every workout carries the plan id', () {
      final template = kPlanTemplates['1']!;
      final workouts = buildTemplateWorkouts(
        userId: 'u1',
        planId: 'plan_abc',
        startMonday: DateTime(2026, 9, 14),
        durationWeeks: 2,
        template: template.workouts,
      );

      expect(workouts, isNotEmpty);
      for (final w in workouts) {
        expect(w.planId, 'plan_abc');
        expect(w.userId, 'u1');
      }
    });

    test('scheduled dates are monotonic across weeks', () {
      final template = kPlanTemplates['2']!;
      final workouts = buildTemplateWorkouts(
        userId: 'u1',
        planId: 'p1',
        startMonday: DateTime(2026, 9, 14),
        durationWeeks: template.durationWeeks,
        template: template.workouts,
      );

      for (var i = 1; i < workouts.length; i++) {
        expect(
          workouts[i].scheduledFor.isAfter(workouts[i - 1].scheduledFor) ||
              workouts[i].scheduledFor.isAtSameMomentAs(
                workouts[i - 1].scheduledFor,
              ),
          isTrue,
          reason: 'workout $i is scheduled before workout ${i - 1}',
        );
      }
      // First workout lands in week 1.
      expect(
        workouts.first.scheduledFor.difference(DateTime(2026, 9, 14)).inDays,
        lessThan(7),
      );
    });

    test('no template schedules more than 4 workouts per week', () {
      for (final entry in kPlanTemplates.entries) {
        expect(
          entry.value.workouts.length,
          lessThanOrEqualTo(4),
          reason: 'template ${entry.key} exceeds 4 workouts/week',
        );
      }
    });

    test('all five catalog ids have templates', () {
      for (final id in ['1', '2', '3', '4', '5']) {
        expect(kPlanTemplates[id], isNotNull);
        expect(kPlanTemplates[id]!.workouts.length, greaterThanOrEqualTo(2));
      }
    });
  });

  group('buildAiBasePlanWorkouts', () {
    Map<String, dynamic> basePlan(int weeks) => {
      'weeks': [
        for (var w = 1; w <= weeks; w++)
          {
            'weekNumber': w,
            'theme': 'Week $w: Progressive Build',
            'focus': 'Threshold intervals and aerobic volume.',
            'targetWeeklyHours': 10.0,
            // Mirrors generateBasePlan: recovery weeks target ~65% TSS.
            'targetWeeklyTSS': w % 4 == 0 ? 364 : 560,
            'isRecoveryWeek': w % 4 == 0,
          },
      ],
    };

    test('build weeks get 4 sessions, recovery weeks get 3', () {
      final workouts = buildAiBasePlanWorkouts(
        userId: 'u1',
        planId: 'ai_1',
        basePlanMap: basePlan(4),
        startMonday: DateTime(2026, 9, 14),
        sport: 'Cycling',
      );

      final week1 = workouts.where((w) => w.title.contains('Week 1 '));
      final week4 = workouts.where((w) => w.title.contains('Week 4 '));
      expect(week1.length, 4);
      expect(week4.length, 3);
      expect(workouts.length, 4 + 4 + 4 + 3);
    });

    test('recovery week carries less total TSS than a build week', () {
      final workouts = buildAiBasePlanWorkouts(
        userId: 'u1',
        planId: 'ai_1',
        basePlanMap: basePlan(4),
        startMonday: DateTime(2026, 9, 14),
        sport: 'Running',
      );

      int weekTss(int week) => workouts
          .where((w) => w.title.contains('Week $week '))
          .fold(0, (sum, w) => sum + (w.tss ?? 0));
      expect(weekTss(4), lessThan(weekTss(1)));
    });

    test('sport label maps to the workout sport', () {
      final workouts = buildAiBasePlanWorkouts(
        userId: 'u1',
        planId: 'ai_1',
        basePlanMap: basePlan(1),
        startMonday: DateTime(2026, 9, 14),
        sport: 'Swimming',
      );

      expect(workouts, isNotEmpty);
      for (final w in workouts) {
        expect(w.sport, Sport.swim);
      }
    });

    test('scheduled dates are monotonic', () {
      final workouts = buildAiBasePlanWorkouts(
        userId: 'u1',
        planId: 'ai_1',
        basePlanMap: basePlan(8),
        startMonday: DateTime(2026, 9, 14),
        sport: 'Cycling',
      );

      for (var i = 1; i < workouts.length; i++) {
        expect(
          !workouts[i].scheduledFor.isBefore(workouts[i - 1].scheduledFor),
          isTrue,
        );
      }
    });
  });

  group('TrainingPlanService.computeProgress', () {
    late FakeFirebaseFirestore firestore;
    late TrainingPlanService service;

    setUp(() {
      firestore = FakeFirebaseFirestore();
      service = TrainingPlanService(db: firestore);
    });

    Future<void> seedWorkouts(String planId, List<bool> completedFlags) async {
      for (var i = 0; i < completedFlags.length; i++) {
        await firestore.collection('workouts').doc('${planId}_w$i').set({
          'userId': 'u1',
          'planId': planId,
          'sport': 'run',
          'title': 'Workout $i',
          'duration': '45 min',
          'scheduledFor': Timestamp.fromDate(DateTime(2026, 9, 14 + i)),
          'progress': completedFlags[i] ? 1.0 : 0.0,
          'completed': completedFlags[i],
        });
      }
    }

    test('returns 0 when the plan has no workouts', () async {
      expect(await service.computeProgress(userId: 'u1', planId: 'p1'), 0);
    });

    test('returns 0.5 for one of two completed', () async {
      await seedWorkouts('p1', [true, false]);
      expect(await service.computeProgress(userId: 'u1', planId: 'p1'), 0.5);
    });

    test('returns 1.0 when all workouts are complete', () async {
      await seedWorkouts('p1', [true, true, true]);
      expect(await service.computeProgress(userId: 'u1', planId: 'p1'), 1.0);
    });

    test('ignores other plans', () async {
      await seedWorkouts('p1', [true]);
      await seedWorkouts('p2', [false, false]);
      expect(await service.computeProgress(userId: 'u1', planId: 'p1'), 1.0);
      expect(await service.computeProgress(userId: 'u1', planId: 'p2'), 0);
    });
  });
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:veltrix_sports/models/user/user_preferences.dart';
import 'package:veltrix_sports/core/utils/unit_conversion.dart';

void main() {
  // -------------------------------------------------------------------------
  // PhysicalProfile
  // -------------------------------------------------------------------------
  group('PhysicalProfile', () {
    test('age returns null when dateOfBirth is null', () {
      const profile = PhysicalProfile();
      expect(profile.age, isNull);
    });

    test('age calculates correct years from dateOfBirth', () {
      final now = DateTime.now();
      final dob = DateTime(now.year - 30, now.month, now.day);
      final profile = PhysicalProfile(dateOfBirth: dob);
      expect(profile.age, 30);
    });

    test('calculatedMaxHr uses 220 - age by default', () {
      // Use a fixed DOB so the test isn't date-dependent
      final profile = PhysicalProfile(
        dateOfBirth: DateTime(1996, 9, 7),
        hrCalculationMethod: HrCalculationMethod.formula220Age,
      );
      final expectedAge = profile.age!;
      expect(profile.calculatedMaxHr, 220 - expectedAge);
    });

    test('calculatedMaxHr uses 220 - 0.7 * age', () {
      final profile = PhysicalProfile(
        dateOfBirth: DateTime(1996, 9, 7),
        hrCalculationMethod: HrCalculationMethod.formula220_07Age,
      );
      final expectedAge = profile.age!;
      expect(profile.calculatedMaxHr, (220 - 0.7 * expectedAge).round());
    });

    test('calculatedMaxHr uses Karvonen (208 - 0.7 * age)', () {
      final profile = PhysicalProfile(
        dateOfBirth: DateTime(1996, 9, 7),
        hrCalculationMethod: HrCalculationMethod.karvonen,
      );
      final expectedAge = profile.age!;
      expect(profile.calculatedMaxHr, (208 - 0.7 * expectedAge).round());
    });

    test('calculatedMaxHr returns manual value when method is manual', () {
      final profile = PhysicalProfile(
        maxHeartRate: 195,
        hrCalculationMethod: HrCalculationMethod.manual,
      );
      expect(profile.calculatedMaxHr, 195);
    });

    test('calculatedMaxHr falls back to 190 when manual has no value', () {
      const profile = PhysicalProfile(
        hrCalculationMethod: HrCalculationMethod.manual,
      );
      expect(profile.calculatedMaxHr, 190);
    });

    test('calculatedMaxHr falls back to manual when age is null', () {
      const profile = PhysicalProfile(
        maxHeartRate: 200,
        hrCalculationMethod: HrCalculationMethod.formula220Age,
      );
      expect(profile.calculatedMaxHr, 200);
    });

    test('fromMap and toMap roundtrip', () {
      final dob = DateTime(1996, 5, 15);
      final map = {
        'dateOfBirth': Timestamp.fromDate(dob),
        'weightKg': 72.5,
        'heightCm': 178.0,
        'maxHeartRate': 195,
        'restingHeartRate': 52,
        'hrCalculationMethod': 'manual',
      };

      final profile = PhysicalProfile.fromMap(map);
      final roundtripped = profile.toMap();

      expect(profile.weightKg, 72.5);
      expect(profile.heightCm, 178.0);
      expect(profile.maxHeartRate, 195);
      expect(profile.restingHeartRate, 52);
      expect(profile.hrCalculationMethod, HrCalculationMethod.manual);
      expect(roundtripped['weightKg'], 72.5);
      expect(roundtripped['hrCalculationMethod'], 'manual');
    });

    test('copyWith preserves unset fields', () {
      final original = PhysicalProfile(
        dateOfBirth: DateTime(1996, 1, 1),
        weightKg: 80,
        maxHeartRate: 190,
      );
      final updated = original.copyWith(weightKg: 75);
      expect(updated.weightKg, 75);
      expect(updated.maxHeartRate, 190);
      expect(updated.dateOfBirth, original.dateOfBirth);
    });

    test('copyWith can clear nullable fields', () {
      final original = PhysicalProfile(
        dateOfBirth: DateTime(1996, 1, 1),
        weightKg: 80,
      );
      final cleared = original.copyWith(clearWeightKg: true);
      expect(cleared.weightKg, isNull);
      expect(cleared.dateOfBirth, isNotNull);
    });
  });

  // -------------------------------------------------------------------------
  // SportProfile
  // -------------------------------------------------------------------------
  group('SportProfile', () {
    test('fromMap and toMap roundtrip', () {
      final map = {
        'primarySport': 'Running',
        'secondarySports': ['Cycling', 'Swimming'],
        'experienceLevel': 'intermediate',
        'yearsExperience': 3,
      };

      final profile = SportProfile.fromMap(map);
      final roundtripped = profile.toMap();

      expect(profile.primarySport, 'Running');
      expect(profile.secondarySports, ['Cycling', 'Swimming']);
      expect(profile.experienceLevel, ExperienceLevel.intermediate);
      expect(profile.yearsExperience, 3);
      expect(roundtripped['primarySport'], 'Running');
      expect(roundtripped['experienceLevel'], 'intermediate');
    });

    test('defaults are sensible', () {
      const profile = SportProfile();
      expect(profile.primarySport, '');
      expect(profile.secondarySports, isEmpty);
      expect(profile.experienceLevel, ExperienceLevel.beginner);
      expect(profile.yearsExperience, isNull);
    });
  });

  // -------------------------------------------------------------------------
  // TargetEvent
  // -------------------------------------------------------------------------
  group('TargetEvent', () {
    test('daysUntil returns positive for future event', () {
      final event = TargetEvent(
        name: 'Marathon',
        date: DateTime.now().add(const Duration(days: 30)),
      );
      expect(event.daysUntil, greaterThanOrEqualTo(29));
      expect(event.daysUntil, lessThanOrEqualTo(30));
    });

    test('daysUntil returns negative for past event', () {
      final event = TargetEvent(
        name: 'Old Race',
        date: DateTime.now().subtract(const Duration(days: 5)),
      );
      expect(event.daysUntil, -5);
    });

    test('fromMap and toMap roundtrip', () {
      final date = DateTime(2026, 12, 31);
      final map = {
        'name': 'Half Marathon',
        'date': Timestamp.fromDate(date),
        'distance': '21.1 km',
      };

      final event = TargetEvent.fromMap(map);
      final roundtripped = event.toMap();

      expect(event.name, 'Half Marathon');
      expect(event.date, date);
      expect(event.distance, '21.1 km');
      expect(roundtripped['name'], 'Half Marathon');
    });
  });

  // -------------------------------------------------------------------------
  // TrainingGoals
  // -------------------------------------------------------------------------
  group('TrainingGoals', () {
    test('fromMap and toMap roundtrip', () {
      final map = {
        'targetEvents': [
          {
            'name': 'Marathon',
            'date': Timestamp.fromDate(DateTime(2027, 1, 1)),
            'distance': '42.2 km',
          },
        ],
        'performanceGoals': ['Sub 4hr Marathon', 'Run 50km/week'],
        'weeklyHoursTarget': 12,
      };

      final goals = TrainingGoals.fromMap(map);
      final roundtripped = goals.toMap();

      expect(goals.targetEvents.length, 1);
      expect(goals.targetEvents[0].name, 'Marathon');
      expect(goals.performanceGoals.length, 2);
      expect(goals.weeklyHoursTarget, 12);
      expect((roundtripped['targetEvents'] as List).length, 1);
    });

    test('defaults are empty', () {
      const goals = TrainingGoals();
      expect(goals.targetEvents, isEmpty);
      expect(goals.performanceGoals, isEmpty);
      expect(goals.weeklyHoursTarget, isNull);
    });
  });

  // -------------------------------------------------------------------------
  // HeartRateZones
  // -------------------------------------------------------------------------
  group('HeartRateZones', () {
    test('autoFromMaxHr produces 5 zones', () {
      final zones = HeartRateZones.autoFromMaxHr(190);
      expect(zones.method, 'auto');
      expect(zones.zones.length, 5);
    });

    test('autoFromMaxHr zone boundaries are correct for maxHr=200', () {
      final zones = HeartRateZones.autoFromMaxHr(200);

      expect(zones.zones[0].label, 'Recovery');
      expect(zones.zones[0].min, 100);
      expect(zones.zones[0].max, 120);

      expect(zones.zones[1].label, 'Aerobic');
      expect(zones.zones[1].min, 120);
      expect(zones.zones[1].max, 140);

      expect(zones.zones[2].label, 'Tempo');
      expect(zones.zones[2].min, 140);
      expect(zones.zones[2].max, 160);

      expect(zones.zones[3].label, 'Threshold');
      expect(zones.zones[3].min, 160);
      expect(zones.zones[3].max, 180);

      expect(zones.zones[4].label, 'VO2max');
      expect(zones.zones[4].min, 180);
      expect(zones.zones[4].max, 200);
    });

    test('autoFromMaxHr zone boundaries are correct for maxHr=160', () {
      final zones = HeartRateZones.autoFromMaxHr(160);

      expect(zones.zones[0].min, 80);
      expect(zones.zones[0].max, 96);
      expect(zones.zones[4].min, 144);
      expect(zones.zones[4].max, 160);
    });

    test('fromMap and toMap roundtrip', () {
      final original = HeartRateZones.autoFromMaxHr(180);
      final map = original.toMap();
      final restored = HeartRateZones.fromMap(map);

      expect(restored.method, original.method);
      expect(restored.zones.length, original.zones.length);
      for (int i = 0; i < original.zones.length; i++) {
        expect(restored.zones[i].label, original.zones[i].label);
        expect(restored.zones[i].min, original.zones[i].min);
        expect(restored.zones[i].max, original.zones[i].max);
      }
    });
  });

  // -------------------------------------------------------------------------
  // HeartRateZone
  // -------------------------------------------------------------------------
  group('HeartRateZone', () {
    test('fromMap creates correct zone', () {
      final zone = HeartRateZone.fromMap({
        'label': 'Tempo',
        'min': 140,
        'max': 160,
      });
      expect(zone.label, 'Tempo');
      expect(zone.min, 140);
      expect(zone.max, 160);
    });

    test('fromMap handles missing fields', () {
      final zone = HeartRateZone.fromMap({});
      expect(zone.label, '');
      expect(zone.min, 0);
      expect(zone.max, 0);
    });
  });

  // -------------------------------------------------------------------------
  // SchedulePreferences
  // -------------------------------------------------------------------------
  group('SchedulePreferences', () {
    test('defaults', () {
      const schedule = SchedulePreferences();
      expect(schedule.availableDays, [1, 2, 3, 4, 5, 6, 7]);
      expect(schedule.restDays, [7]);
      expect(schedule.longWorkoutDay, 6);
    });

    test('fromMap and toMap roundtrip', () {
      final map = {
        'availableDays': [1, 2, 3, 5, 6],
        'restDays': [4, 7],
        'longWorkoutDay': 6,
      };
      final schedule = SchedulePreferences.fromMap(map);
      final roundtripped = schedule.toMap();

      expect(schedule.availableDays, [1, 2, 3, 5, 6]);
      expect(schedule.restDays, [4, 7]);
      expect(schedule.longWorkoutDay, 6);
      expect(roundtripped['longWorkoutDay'], 6);
    });
  });

  // -------------------------------------------------------------------------
  // DisplayPreferences
  // -------------------------------------------------------------------------
  group('DisplayPreferences', () {
    test('defaults', () {
      const display = DisplayPreferences();
      expect(display.unitSystem, UnitSystem.metric);
      expect(display.paceFormat, PaceFormat.minPerKm);
      expect(display.weekStartsOn, 1);
    });

    test('fromMap and toMap roundtrip', () {
      final map = {
        'unitSystem': 'imperial',
        'paceFormat': 'minPerMile',
        'weekStartsOn': 7,
      };
      final display = DisplayPreferences.fromMap(map);
      expect(display.unitSystem, UnitSystem.imperial);
      expect(display.paceFormat, PaceFormat.minPerMile);
      expect(display.weekStartsOn, 7);
    });
  });

  // -------------------------------------------------------------------------
  // ThemePreferences
  // -------------------------------------------------------------------------
  group('ThemePreferences', () {
    test('defaults', () {
      const theme = ThemePreferences();
      expect(theme.mode, ThemeModePreference.system);
      expect(theme.accentColor, isNull);
    });

    test('fromMap and toMap roundtrip', () {
      final map = {'mode': 'dark', 'accentColor': '#FF5722'};
      final theme = ThemePreferences.fromMap(map);
      expect(theme.mode, ThemeModePreference.dark);
      expect(theme.accentColor, '#FF5722');
    });
  });

  // -------------------------------------------------------------------------
  // NotificationPreferences
  // -------------------------------------------------------------------------
  group('NotificationPreferences', () {
    test('defaults', () {
      const notif = NotificationPreferences();
      expect(notif.workoutReminders, true);
      expect(notif.reminderMinutesBefore, 30);
      expect(notif.coachMessages, true);
      expect(notif.weeklySummary, true);
      expect(notif.achievements, true);
      expect(notif.quietHoursEnabled, false);
      expect(notif.quietHoursStart, '22:00');
      expect(notif.quietHoursEnd, '07:00');
    });

    test('fromMap and toMap roundtrip', () {
      final map = {
        'workoutReminders': false,
        'reminderMinutesBefore': 15,
        'coachMessages': false,
        'weeklySummary': false,
        'achievements': false,
        'quietHoursEnabled': true,
        'quietHoursStart': '21:00',
        'quietHoursEnd': '06:00',
      };
      final notif = NotificationPreferences.fromMap(map);
      final roundtripped = notif.toMap();

      expect(notif.workoutReminders, false);
      expect(notif.reminderMinutesBefore, 15);
      expect(notif.quietHoursEnabled, true);
      expect(roundtripped['quietHoursStart'], '21:00');
    });
  });

  // -------------------------------------------------------------------------
  // DashboardPreferences
  // -------------------------------------------------------------------------
  group('DashboardPreferences', () {
    test('defaults', () {
      const dash = DashboardPreferences();
      expect(dash.visibleWidgets, isEmpty);
      expect(dash.widgetOrder, isEmpty);
      expect(dash.layout, 'standard');
    });

    test('fromMap and toMap roundtrip', () {
      final map = {
        'visibleWidgets': ['heartRate', 'pace', 'distance'],
        'widgetOrder': ['distance', 'pace', 'heartRate'],
        'layout': 'detailed',
      };
      final dash = DashboardPreferences.fromMap(map);
      expect(dash.visibleWidgets.length, 3);
      expect(dash.widgetOrder[0], 'distance');
      expect(dash.layout, 'detailed');
    });
  });

  // -------------------------------------------------------------------------
  // UserPreferences (root)
  // -------------------------------------------------------------------------
  group('UserPreferences', () {
    test('defaultFor creates preferences with auto zones', () {
      final prefs = UserPreferences.defaultFor(180);
      expect(prefs.heartRateZones.zones.length, 5);
      expect(prefs.heartRateZones.zones[4].max, 180);
      expect(prefs.schemaVersion, 1);
    });

    test('fromMap and toMap roundtrip preserves all sub-models', () {
      final dob = DateTime(1996, 5, 15);
      final map = {
        'schemaVersion': 1,
        'physical': {
          'dateOfBirth': Timestamp.fromDate(dob),
          'weightKg': 72.5,
          'heightCm': 178.0,
          'maxHeartRate': 195,
          'restingHeartRate': 52,
          'hrCalculationMethod': 'manual',
        },
        'sport': {
          'primarySport': 'Running',
          'secondarySports': ['Cycling'],
          'experienceLevel': 'advanced',
          'yearsExperience': 5,
        },
        'goals': {
          'targetEvents': [],
          'performanceGoals': ['Sub 3hr Marathon'],
          'weeklyHoursTarget': 15,
        },
        'schedule': {
          'availableDays': [1, 2, 3, 4, 5],
          'restDays': [6, 7],
          'longWorkoutDay': 5,
        },
        'heartRateZones': {
          'method': 'manual',
          'zones': [
            {'label': 'Easy', 'min': 100, 'max': 130},
          ],
        },
        'display': {
          'unitSystem': 'imperial',
          'paceFormat': 'minPerMile',
          'weekStartsOn': 7,
        },
        'theme': {'mode': 'dark', 'accentColor': '#00FF00'},
        'notifications': {
          'workoutReminders': false,
          'reminderMinutesBefore': 45,
          'coachMessages': true,
          'weeklySummary': false,
          'achievements': true,
          'quietHoursEnabled': true,
          'quietHoursStart': '23:00',
          'quietHoursEnd': '08:00',
        },
        'dashboard': {
          'visibleWidgets': ['pace'],
          'widgetOrder': ['pace'],
          'layout': 'minimal',
        },
      };

      final prefs = UserPreferences.fromMap(map);
      final roundtripped = prefs.toMap();

      expect(prefs.physical.weightKg, 72.5);
      expect(prefs.physical.hrCalculationMethod, HrCalculationMethod.manual);
      expect(prefs.sport.primarySport, 'Running');
      expect(prefs.sport.experienceLevel, ExperienceLevel.advanced);
      expect(prefs.goals.performanceGoals, ['Sub 3hr Marathon']);
      expect(prefs.schedule.longWorkoutDay, 5);
      expect(prefs.heartRateZones.method, 'manual');
      expect(prefs.heartRateZones.zones.length, 1);
      expect(prefs.display.unitSystem, UnitSystem.imperial);
      expect(prefs.theme.mode, ThemeModePreference.dark);
      expect(prefs.notifications.quietHoursEnabled, true);
      expect(prefs.dashboard.layout, 'minimal');

      // Roundtrip check
      expect((roundtripped['physical'] as Map)['weightKg'], 72.5);
      expect((roundtripped['sport'] as Map)['primarySport'], 'Running');
      expect((roundtripped['display'] as Map)['unitSystem'], 'imperial');
    });

    test('fromMap handles empty/missing sub-maps gracefully', () {
      final prefs = UserPreferences.fromMap({});
      expect(prefs.schemaVersion, 1);
      expect(prefs.physical, isA<PhysicalProfile>());
      expect(prefs.sport, isA<SportProfile>());
      expect(prefs.goals, isA<TrainingGoals>());
      expect(prefs.schedule, isA<SchedulePreferences>());
      expect(prefs.heartRateZones, isA<HeartRateZones>());
      expect(prefs.display, isA<DisplayPreferences>());
      expect(prefs.theme, isA<ThemePreferences>());
      expect(prefs.notifications, isA<NotificationPreferences>());
      expect(prefs.dashboard, isA<DashboardPreferences>());
    });

    test('copyWith replaces specified sub-models', () {
      final original = UserPreferences.defaultFor(180);
      final newDisplay = const DisplayPreferences(
        unitSystem: UnitSystem.imperial,
        paceFormat: PaceFormat.minPerMile,
      );
      final updated = original.copyWith(display: newDisplay);

      expect(updated.display.unitSystem, UnitSystem.imperial);
      expect(updated.display.paceFormat, PaceFormat.minPerMile);
      // Everything else unchanged
      expect(updated.heartRateZones, original.heartRateZones);
      expect(updated.schemaVersion, original.schemaVersion);
    });
  });

  // -------------------------------------------------------------------------
  // UnitConversion
  // -------------------------------------------------------------------------
  group('UnitConversion', () {
    test('kmToMiles and milesToKm are inverses', () {
      expect(UnitConversion.kmToMiles(10), closeTo(6.21371, 0.0001));
      expect(UnitConversion.milesToKm(6.21371), closeTo(10, 0.001));
    });

    test('kgToLb and lbToKg are inverses', () {
      expect(UnitConversion.kgToLb(70), closeTo(154.323, 0.001));
      expect(UnitConversion.lbToKg(154.323), closeTo(70, 0.001));
    });

    test('mToFt and ftToM are inverses', () {
      expect(UnitConversion.mToFt(100), closeTo(328.084, 0.001));
      expect(UnitConversion.ftToM(328.084), closeTo(100, 0.001));
    });

    test('formatDistance metric', () {
      expect(UnitConversion.formatDistance(UnitSystem.metric, 10.0), '10.0 km');
    });

    test('formatDistance imperial', () {
      final result = UnitConversion.formatDistance(UnitSystem.imperial, 10.0);
      expect(result, contains('mi'));
      expect(result, startsWith('6'));
    });

    test('formatPace metric', () {
      expect(UnitConversion.formatPace(UnitSystem.metric, 5.5), '5:30/km');
    });

    test('formatPace imperial', () {
      final result = UnitConversion.formatPace(UnitSystem.imperial, 5.0);
      expect(result, contains('/mi'));
    });

    test('formatElevation metric', () {
      expect(UnitConversion.formatElevation(UnitSystem.metric, 150.7), '151 m');
    });

    test('formatElevation imperial', () {
      final result = UnitConversion.formatElevation(UnitSystem.imperial, 100);
      expect(result, contains('ft'));
    });

    test('formatWeight metric', () {
      expect(UnitConversion.formatWeight(UnitSystem.metric, 72.5), '72.5 kg');
    });

    test('formatWeight imperial', () {
      final result = UnitConversion.formatWeight(UnitSystem.imperial, 70);
      expect(result, contains('lb'));
    });
  });
}

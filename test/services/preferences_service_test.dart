import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:veltrix_sports/models/user/user_preferences.dart';
import 'package:veltrix_sports/services/core/preferences_service.dart';

void main() {
  late FakeFirebaseFirestore fakeDb;
  late PreferencesService service;

  setUp(() {
    fakeDb = FakeFirebaseFirestore();
    service = PreferencesService(db: fakeDb);
  });

  group('PreferencesService', () {
    const uid = 'test-user-123';

    test('get returns null when document does not exist', () async {
      final result = await service.get(uid);
      expect(result, isNull);
    });

    test('update creates document and get reads it back', () async {
      final prefs = UserPreferences.defaultFor(180);
      await service.update(uid, prefs.toMap());

      final result = await service.get(uid);
      expect(result, isNotNull);
      expect(result!.heartRateZones.zones.length, 5);
      expect(result.heartRateZones.zones[4].max, 180);
    });

    test('update merges partial fields into existing document', () async {
      // Create with defaults
      final prefs = UserPreferences.defaultFor(180);
      await service.update(uid, prefs.toMap());

      // Update just the display unit system
      await service.update(uid, {
        'display': {
          'unitSystem': 'imperial',
          'paceFormat': 'minPerMile',
          'weekStartsOn': 7,
        },
      });

      final result = await service.get(uid);
      expect(result, isNotNull);
      expect(result!.display.unitSystem, UnitSystem.imperial);
      expect(result.display.paceFormat, PaceFormat.minPerMile);
      // Other fields should be preserved
      expect(result.heartRateZones.zones.length, 5);
    });

    test('updateField updates a single dot-path field', () async {
      final prefs = UserPreferences.defaultFor(180);
      await service.update(uid, prefs.toMap());

      await service.updateField(uid, 'display.unitSystem', 'imperial');

      final result = await service.get(uid);
      expect(result, isNotNull);
      expect(result!.display.unitSystem, UnitSystem.imperial);
    });

    test('watch emits stream of preference changes', () async {
      final prefs = UserPreferences.defaultFor(180);
      await service.update(uid, prefs.toMap());

      final stream = service.watch(uid);

      // Collect first emission
      final first = await stream.first;
      expect(first, isNotNull);
      expect(first!.heartRateZones.zones.length, 5);
    });

    test('recalculateZones returns zones based on physical profile', () {
      final physical = PhysicalProfile(
        dateOfBirth: DateTime(DateTime.now().year - 30, 1, 1),
        hrCalculationMethod: HrCalculationMethod.formula220Age,
      );

      final zones = service.recalculateZones(physical);
      expect(zones.method, 'auto');
      expect(zones.zones.length, 5);

      // max HR for 30-year-old with 220-age: 190
      expect(zones.zones[4].max, 190);
      expect(zones.zones[0].min, (190 * 0.50).round());
    });

    test('recalculateZones works with manual max HR', () {
      const physical = PhysicalProfile(
        maxHeartRate: 185,
        hrCalculationMethod: HrCalculationMethod.manual,
      );

      final zones = service.recalculateZones(physical);
      expect(zones.zones[4].max, 185);
    });

    test('get returns preferences for empty subcollection document', () async {
      // Write an empty document - FakeFirebaseFirestore considers it existing
      await fakeDb
          .collection('users')
          .doc(uid)
          .collection('preferences')
          .doc('main')
          .set({});

      final result = await service.get(uid);
      // Empty doc is still a valid document, fromMap creates defaults
      expect(result, isNotNull);
      expect(result!.schemaVersion, 1);
    });

    test('multiple updates accumulate correctly', () async {
      // Start with defaults
      await service.update(uid, UserPreferences.defaultFor(180).toMap());

      // Update theme
      await service.update(uid, {
        'theme': {'mode': 'dark', 'accentColor': '#FF0000'},
      });

      // Update notifications
      await service.update(uid, {
        'notifications': {
          'workoutReminders': false,
          'reminderMinutesBefore': 60,
          'coachMessages': true,
          'weeklySummary': true,
          'achievements': true,
          'quietHoursEnabled': false,
          'quietHoursStart': '22:00',
          'quietHoursEnd': '07:00',
        },
      });

      final result = await service.get(uid);
      expect(result, isNotNull);
      expect(result!.theme.mode, ThemeModePreference.dark);
      expect(result.notifications.workoutReminders, false);
      expect(result.notifications.reminderMinutesBefore, 60);
      // Zones should still be there
      expect(result.heartRateZones.zones.length, 5);
    });
  });
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:veltrix_sports/models/user/user_profile.dart';

void main() {
  group('UserProfile', () {
    test('fromMap creates correct profile with all fields', () {
      final timestamp = Timestamp.fromDate(DateTime(2026, 1, 15));
      final renewTimestamp = Timestamp.fromDate(DateTime(2026, 7, 15));
      final map = {
        'email': 'test@example.com',
        'displayName': 'Test User',
        'photoUrl': 'https://example.com/photo.jpg',
        'role': 'coach',
        'sports': ['Running', 'Cycling'],
        'experienceLevel': 'Advanced',
        'mainGoal': 'Win marathon',
        'isPremium': true,
        'subscriptionTier': 'Gold',
        'subscriptionRenewsAt': renewTimestamp,
        'deviceIds': ['dev1', 'dev2'],
        'createdAt': timestamp,
      };

      final profile = UserProfile.fromMap('uid1', map);

      expect(profile.id, 'uid1');
      expect(profile.email, 'test@example.com');
      expect(profile.displayName, 'Test User');
      expect(profile.photoUrl, 'https://example.com/photo.jpg');
      expect(profile.role, UserRole.coach);
      expect(profile.sports, ['Running', 'Cycling']);
      expect(profile.experienceLevel, 'Advanced');
      expect(profile.mainGoal, 'Win marathon');
      expect(profile.isPremium, true);
      expect(profile.subscriptionTier, 'Gold');
      expect(profile.subscriptionRenewsAt, renewTimestamp.toDate());
      expect(profile.deviceIds, ['dev1', 'dev2']);
      expect(profile.createdAt, timestamp.toDate());
    });

    test('fromMap handles missing optional fields with defaults', () {
      final map = <String, dynamic>{
        'email': 'user@test.com',
        'displayName': 'User',
      };

      final profile = UserProfile.fromMap('uid2', map);

      expect(profile.photoUrl, isNull);
      expect(profile.role, UserRole.athlete); // default
      expect(profile.sports, isEmpty);
      expect(profile.experienceLevel, isNull);
      expect(profile.mainGoal, isNull);
      expect(profile.isPremium, false);
      expect(profile.subscriptionTier, isNull);
      expect(profile.subscriptionRenewsAt, isNull);
      expect(profile.deviceIds, isEmpty);
      expect(profile.createdAt, isA<DateTime>());
    });

    test('fromMap handles completely empty map', () {
      final profile = UserProfile.fromMap('uid3', {});

      expect(profile.id, 'uid3');
      expect(profile.email, '');
      expect(profile.displayName, '');
      expect(profile.photoUrl, isNull);
      expect(profile.role, UserRole.athlete);
      expect(profile.sports, isEmpty);
      expect(profile.isPremium, false);
      expect(profile.deviceIds, isEmpty);
      expect(profile.createdAt, isA<DateTime>());
    });

    test('fromMap handles null values', () {
      final map = <String, dynamic>{
        'email': null,
        'displayName': null,
        'photoUrl': null,
        'role': null,
        'sports': null,
        'experienceLevel': null,
        'mainGoal': null,
        'isPremium': null,
        'subscriptionTier': null,
        'subscriptionRenewsAt': null,
        'deviceIds': null,
        'createdAt': null,
      };

      final profile = UserProfile.fromMap('uid4', map);

      expect(profile.email, '');
      expect(profile.displayName, '');
      expect(profile.photoUrl, isNull);
      expect(profile.role, UserRole.athlete);
      expect(profile.sports, isEmpty);
      expect(profile.isPremium, false);
      expect(profile.subscriptionTier, isNull);
      expect(profile.subscriptionRenewsAt, isNull);
      expect(profile.deviceIds, isEmpty);
    });

    test('fromMap maps athlete role correctly', () {
      final map = <String, dynamic>{'role': 'athlete'};
      final profile = UserProfile.fromMap('u', map);
      expect(profile.role, UserRole.athlete);
    });

    test('fromMap maps coach role correctly', () {
      final map = <String, dynamic>{'role': 'coach'};
      final profile = UserProfile.fromMap('u', map);
      expect(profile.role, UserRole.coach);
    });

    test('fromMap defaults to athlete for unknown role string', () {
      final map = <String, dynamic>{'role': 'admin'};
      final profile = UserProfile.fromMap('u', map);
      expect(profile.role, UserRole.athlete);
    });

    test('fromMap defaults to athlete for empty role string', () {
      final map = <String, dynamic>{'role': ''};
      final profile = UserProfile.fromMap('u', map);
      expect(profile.role, UserRole.athlete);
    });

    test('UserRole enum has exactly 2 values', () {
      expect(UserRole.values.length, 2);
      expect(UserRole.values, contains(UserRole.athlete));
      expect(UserRole.values, contains(UserRole.coach));
    });

    test('toMap returns correct map', () {
      final profile = UserProfile(
        id: 'uid5',
        email: 'coach@test.com',
        displayName: 'Coach User',
        photoUrl: 'https://example.com/coach.jpg',
        role: UserRole.coach,
        sports: ['Cycling', 'Triathlon'],
        experienceLevel: 'Expert',
        mainGoal: 'Win nationals',
        isPremium: true,
        subscriptionTier: 'Elite',
        subscriptionRenewsAt: DateTime(2026, 12, 31),
        deviceIds: ['garmin_1', 'apple_watch_1'],
        createdAt: DateTime(2026, 1, 1),
      );

      final map = profile.toMap();

      expect(map['email'], 'coach@test.com');
      expect(map['displayName'], 'Coach User');
      expect(map['photoUrl'], 'https://example.com/coach.jpg');
      expect(map['role'], 'coach');
      expect(map['sports'], ['Cycling', 'Triathlon']);
      expect(map['experienceLevel'], 'Expert');
      expect(map['mainGoal'], 'Win nationals');
      expect(map['isPremium'], true);
      expect(map['subscriptionTier'], 'Elite');
      expect(map['deviceIds'], ['garmin_1', 'apple_watch_1']);
    });

    test('toMap includes null values', () {
      final profile = UserProfile(
        id: 'uid6',
        email: 'a@b.com',
        displayName: 'Minimal',
        role: UserRole.athlete,
        createdAt: DateTime(2026),
      );

      final map = profile.toMap();
      expect(map['photoUrl'], isNull);
      expect(map['experienceLevel'], isNull);
      expect(map['mainGoal'], isNull);
      expect(map['subscriptionTier'], isNull);
      expect(map['subscriptionRenewsAt'], isNull);
    });

    test('toMap serializes isPremium as false by default', () {
      final profile = UserProfile(
        id: 'uid7',
        email: 'a@b.com',
        displayName: 'User',
        role: UserRole.athlete,
        createdAt: DateTime(2026),
      );

      final map = profile.toMap();
      expect(map['isPremium'], false);
    });

    test('constructor defaults for optional fields', () {
      final profile = UserProfile(
        id: 'uid8',
        email: 'a@b.com',
        displayName: 'User',
        role: UserRole.athlete,
        createdAt: DateTime(2026),
      );

      expect(profile.sports, isEmpty);
      expect(profile.experienceLevel, isNull);
      expect(profile.mainGoal, isNull);
      expect(profile.isPremium, false);
      expect(profile.subscriptionTier, isNull);
      expect(profile.subscriptionRenewsAt, isNull);
      expect(profile.deviceIds, isEmpty);
    });

    test('fromMap and toMap roundtrip preserves data', () {
      final renewAt = DateTime(2026, 8, 20);
      final created = DateTime(2026, 1, 1);
      final originalMap = <String, dynamic>{
        'email': 'round@trip.com',
        'displayName': 'Round Trip',
        'photoUrl': 'https://photo.url',
        'role': 'coach',
        'sports': ['Running', 'Swimming'],
        'experienceLevel': 'Pro',
        'mainGoal': 'Olympics',
        'isPremium': true,
        'subscriptionTier': 'Platinum',
        'subscriptionRenewsAt': Timestamp.fromDate(renewAt),
        'deviceIds': ['d1'],
        'createdAt': Timestamp.fromDate(created),
      };

      final profile = UserProfile.fromMap('rt1', originalMap);
      final roundtripped = profile.toMap();

      expect(roundtripped['email'], 'round@trip.com');
      expect(roundtripped['displayName'], 'Round Trip');
      expect(roundtripped['role'], 'coach');
      expect(roundtripped['sports'], ['Running', 'Swimming']);
      expect(roundtripped['isPremium'], true);
      expect(roundtripped['subscriptionTier'], 'Platinum');
    });

    test('handles empty sports and deviceIds lists', () {
      final map = <String, dynamic>{
        'email': 'e@e.com',
        'displayName': 'E',
        'sports': [],
        'deviceIds': [],
      };

      final profile = UserProfile.fromMap('u', map);
      expect(profile.sports, isEmpty);
      expect(profile.deviceIds, isEmpty);
    });

    test('handles large sports and deviceIds lists', () {
      final sports = List.generate(20, (i) => 'Sport_$i');
      final devices = List.generate(10, (i) => 'dev_$i');
      final map = <String, dynamic>{
        'email': 'e@e.com',
        'displayName': 'E',
        'sports': sports,
        'deviceIds': devices,
      };

      final profile = UserProfile.fromMap('u', map);
      expect(profile.sports.length, 20);
      expect(profile.deviceIds.length, 10);
    });
  });
}

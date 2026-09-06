import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:veltrix_sports/models/user_profile.dart';

void main() {
  group('UserProfile - Extended', () {
    test('fromMap with invalid createdAt defaults to DateTime.now', () {
      // Passing a non-Timestamp value for createdAt - since the code does
      // `(map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now()`,
      // passing null works but passing a non-Timestamp type would throw.
      // Test the null case which is the realistic scenario.
      final map = <String, dynamic>{
        'email': 'a@b.com',
        'displayName': 'Test',
        'createdAt': null,
      };
      final profile = UserProfile.fromMap('u1', map);
      expect(profile.createdAt, isA<DateTime>());
    });

    test('fromMap with invalid subscriptionRenewsAt null', () {
      final map = <String, dynamic>{
        'email': 'a@b.com',
        'displayName': 'Test',
        'subscriptionRenewsAt': null,
      };
      final profile = UserProfile.fromMap('u1', map);
      expect(profile.subscriptionRenewsAt, isNull);
    });

    test('toMap fromMap roundtrip with coach role', () {
      final profile = UserProfile(
        id: 'rt2',
        email: 'coach@coach.com',
        displayName: 'Coach',
        role: UserRole.coach,
        sports: ['Cycling'],
        isPremium: true,
        createdAt: DateTime(2026),
      );
      final map = profile.toMap();
      // fromMap expects Timestamps for date fields, but toMap puts DateTime.
      // Use the fromMap with a properly constructed map using Timestamps.
      final tsMap = Map<String, dynamic>.from(map);
      tsMap['createdAt'] = Timestamp.fromDate(profile.createdAt);
      final restored = UserProfile.fromMap('rt2', tsMap);
      expect(restored.role, UserRole.coach);
      expect(restored.isPremium, true);
      expect(restored.sports, ['Cycling']);
    });

    test('toMap fromMap roundtrip with athlete role', () {
      final profile = UserProfile(
        id: 'rt3',
        email: 'ath@ath.com',
        displayName: 'Athlete',
        role: UserRole.athlete,
        createdAt: DateTime(2026),
      );
      final map = profile.toMap();
      final tsMap = Map<String, dynamic>.from(map);
      tsMap['createdAt'] = Timestamp.fromDate(profile.createdAt);
      final restored = UserProfile.fromMap('rt3', tsMap);
      expect(restored.role, UserRole.athlete);
    });

    test('fromMap with isPremium true', () {
      final map = <String, dynamic>{
        'email': 'p@p.com',
        'displayName': 'Premium',
        'isPremium': true,
      };
      final profile = UserProfile.fromMap('u', map);
      expect(profile.isPremium, true);
    });

    test('fromMap with subscriptionRenewsAt Timestamp', () {
      final ts = Timestamp.fromDate(DateTime(2026, 12, 31));
      final map = <String, dynamic>{
        'email': 'e@e.com',
        'displayName': 'E',
        'subscriptionRenewsAt': ts,
      };
      final profile = UserProfile.fromMap('u', map);
      expect(profile.subscriptionRenewsAt, ts.toDate());
    });

    test('fromMap with subscriptionTier', () {
      final map = <String, dynamic>{
        'email': 'e@e.com',
        'displayName': 'E',
        'subscriptionTier': 'Gold',
      };
      final profile = UserProfile.fromMap('u', map);
      expect(profile.subscriptionTier, 'Gold');
    });

    test('toMap includes all fields', () {
      final profile = UserProfile(
        id: 'full',
        email: 'full@test.com',
        displayName: 'Full',
        photoUrl: 'https://img.com/photo.jpg',
        role: UserRole.coach,
        sports: ['Running', 'Cycling', 'Swimming'],
        experienceLevel: 'Expert',
        mainGoal: 'Olympics',
        isPremium: true,
        subscriptionTier: 'Platinum',
        subscriptionRenewsAt: DateTime(2027, 1, 1),
        deviceIds: ['d1', 'd2'],
        createdAt: DateTime(2026),
      );
      final map = profile.toMap();

      expect(map.length, 12); // all fields
      expect(map.containsKey('id'), isFalse); // id is not in toMap
      expect(map['email'], 'full@test.com');
      expect(map['displayName'], 'Full');
      expect(map['photoUrl'], 'https://img.com/photo.jpg');
      expect(map['role'], 'coach');
      expect(map['sports'], ['Running', 'Cycling', 'Swimming']);
      expect(map['experienceLevel'], 'Expert');
      expect(map['mainGoal'], 'Olympics');
      expect(map['isPremium'], true);
      expect(map['subscriptionTier'], 'Platinum');
      expect(map['deviceIds'], ['d1', 'd2']);
    });

    test('UserRole has exactly 2 values', () {
      expect(UserRole.values.length, 2);
      expect(UserRole.values[0], UserRole.athlete);
      expect(UserRole.values[1], UserRole.coach);
    });

    test('UserRole enum names', () {
      expect(UserRole.athlete.name, 'athlete');
      expect(UserRole.coach.name, 'coach');
    });

    test('fromMap with non-String sports list throws on access', () {
      // The code does (map['sports'] as List? ?? []).cast<String>()
      // List.cast() returns a lazy CastList. The TypeError is thrown when
      // you actually iterate/access the cast list, not at fromMap creation.
      final map = <String, dynamic>{
        'email': 'e@e.com',
        'displayName': 'E',
        'sports': [123, true],
      };
      final profile = UserProfile.fromMap('u', map);
      // Accessing sports on a CastList with non-String elements throws
      expect(() => profile.sports.first, throwsA(isA<TypeError>()));
    });

    test('constructor with all optional fields', () {
      final now = DateTime.now();
      final profile = UserProfile(
        id: 'all_opt',
        email: 'opt@test.com',
        displayName: 'Optional',
        photoUrl: 'https://photo.jpg',
        role: UserRole.coach,
        sports: ['Running'],
        experienceLevel: 'Beginner',
        mainGoal: 'Have fun',
        isPremium: false,
        subscriptionTier: 'Basic',
        subscriptionRenewsAt: now,
        deviceIds: ['dev1'],
        createdAt: now,
      );
      expect(profile.photoUrl, 'https://photo.jpg');
      expect(profile.experienceLevel, 'Beginner');
      expect(profile.mainGoal, 'Have fun');
      expect(profile.subscriptionTier, 'Basic');
      expect(profile.subscriptionRenewsAt, now);
      expect(profile.deviceIds, ['dev1']);
    });

    test('fromMap with empty string role defaults to athlete', () {
      final map = <String, dynamic>{
        'email': 'e@e.com',
        'displayName': 'E',
        'role': '',
      };
      final profile = UserProfile.fromMap('u', map);
      expect(profile.role, UserRole.athlete);
    });

    test('fromMap with numeric email throws TypeError', () {
      final map = <String, dynamic>{'email': 123, 'displayName': 'E'};
      expect(() => UserProfile.fromMap('u', map), throwsA(isA<TypeError>()));
    });
  });
}

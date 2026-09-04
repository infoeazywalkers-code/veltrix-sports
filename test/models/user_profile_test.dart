import 'package:flutter_test/flutter_test.dart';
import 'package:veltrix_sports/models/user_profile.dart';

void main() {
  group('UserProfile', () {
    test('fromMap creates correct profile', () {
      final map = {
        'email': 'test@example.com',
        'displayName': 'Test User',
        'photoUrl': 'https://example.com/photo.jpg',
        'role': 'athlete',
        'sports': ['Running', 'Cycling'],
        'experienceLevel': 'Intermediate',
        'mainGoal': 'Improve performance',
        'isPremium': true,
        'subscriptionTier': 'Gold',
        'deviceIds': ['dev1'],
      };

      final profile = UserProfile.fromMap('uid1', map);

      expect(profile.id, 'uid1');
      expect(profile.email, 'test@example.com');
      expect(profile.displayName, 'Test User');
      expect(profile.role, UserRole.athlete);
      expect(profile.sports, ['Running', 'Cycling']);
      expect(profile.isPremium, true);
    });

    test('toMap returns correct map', () {
      final profile = UserProfile(
        id: 'uid1',
        email: 'test@example.com',
        displayName: 'Test User',
        role: UserRole.coach,
        createdAt: DateTime(2026, 1, 1),
      );

      final map = profile.toMap();

      expect(map['email'], 'test@example.com');
      expect(map['role'], 'coach');
      expect(map['isPremium'], false);
    });
  });
}

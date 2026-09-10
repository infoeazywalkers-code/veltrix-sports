import 'package:flutter_test/flutter_test.dart';
import 'package:veltrix_sports/services/social/coach_service.dart';

void main() {
  group('CoachProfile', () {
    test('CoachProfile has all required fields', () {
      const profile = CoachProfile(
        id: 'coach_1',
        name: 'Test Coach',
        title: 'Head Coach',
        rating: '4.9 (10 reviews)',
        bio: 'Bio text',
        image: 'assets/images/test.png',
        monthlyFee: '\$99/mo',
        specialities: ['Running', 'Cycling'],
      );

      expect(profile.id, 'coach_1');
      expect(profile.name, 'Test Coach');
      expect(profile.title, 'Head Coach');
      expect(profile.rating, '4.9 (10 reviews)');
      expect(profile.bio, 'Bio text');
      expect(profile.image, 'assets/images/test.png');
      expect(profile.monthlyFee, '\$99/mo');
      expect(profile.specialities, ['Running', 'Cycling']);
    });

    test('CoachProfile supports empty specialities', () {
      const profile = CoachProfile(
        id: 'c',
        name: 'C',
        title: 'T',
        rating: '5.0',
        bio: 'B',
        image: 'i',
        monthlyFee: '\$50/mo',
        specialities: [],
      );

      expect(profile.specialities, isEmpty);
    });
  });

  group('CoachService.fetchFeaturedCoaches', () {
    test('returns empty list when Firestore is empty', () async {
      final coaches = await CoachService.fetchFeaturedCoaches();
      expect(coaches, isEmpty);
    });

    test('returns empty list when Firebase is not initialized', () async {
      final coaches = await CoachService.fetchFeaturedCoaches();
      expect(coaches, isA<List>());
      expect(coaches, isEmpty);
    });
  });
}

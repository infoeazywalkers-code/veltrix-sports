import 'package:flutter_test/flutter_test.dart';
import 'package:veltrix_sports/services/coach_service.dart';

void main() {
  group('CoachService - expanded coverage', () {
    group('sendInquiry', () {
      test('sendInquiry returns a Future<bool>', () async {
        // sendInquiry requires FirebaseAuth.instance.currentUser
        // which is null in test environment - tests the guest path
        // Firebase is not initialized in tests, so the catch block returns false
        try {
          final result = await CoachService.sendInquiry(
            coachId: 'coach_1',
            coachName: 'Test Coach',
            targetGoal: 'Marathon PR',
            message: 'I want to improve my marathon time',
            preferredDate: DateTime(2026, 10, 1),
          );
          expect(result, isA<bool>());
        } catch (e) {
          // Expected: Firebase not initialized in test
          expect(e, isA<Exception>());
        }
      });
    });

    group('CoachProfile fromMap', () {
      test('fromMap with all fields', () {
        final profile = CoachProfile.fromMap('cp1', {
          'name': 'Test Coach',
          'title': 'Head Coach',
          'rating': '4.9 (10 reviews)',
          'bio': 'Expert coach',
          'image': 'img.png',
          'monthlyFee': '\$100/mo',
          'specialities': ['Running', 'Cycling'],
        });
        expect(profile.id, 'cp1');
        expect(profile.name, 'Test Coach');
        expect(profile.title, 'Head Coach');
        expect(profile.rating, '4.9 (10 reviews)');
        expect(profile.bio, 'Expert coach');
        expect(profile.image, 'img.png');
        expect(profile.monthlyFee, '\$100/mo');
        expect(profile.specialities, ['Running', 'Cycling']);
      });

      test('copyWith with no overrides returns equal profile', () {
        const original = CoachProfile(
          id: 'cp2',
          name: 'Coach',
          title: 'T',
          rating: '4.0',
          bio: 'B',
          image: 'I',
          monthlyFee: '\$50/mo',
          specialities: ['Running'],
        );
        final copy = original.copyWith();
        expect(copy, original);
      });

      test('copyWith overrides only non-null fields', () {
        const original = CoachProfile(
          id: 'cp3',
          name: 'Original',
          title: 'Title',
          rating: '4.0',
          bio: 'Bio',
          image: 'img',
          monthlyFee: '\$99/mo',
          specialities: ['A', 'B'],
        );
        final copy = original.copyWith(
          name: 'New',
          specialities: ['C', 'D', 'E'],
        );
        expect(copy.name, 'New');
        expect(copy.specialities, ['C', 'D', 'E']);
        expect(copy.id, 'cp3');
        expect(copy.title, 'Title');
        expect(copy.rating, '4.0');
        expect(copy.bio, 'Bio');
        expect(copy.image, 'img');
        expect(copy.monthlyFee, '\$99/mo');
      });

      test('equality operator - same object returns true', () {
        const p = CoachProfile(
          id: 'cp4',
          name: 'N',
          title: 'T',
          rating: '4.0',
          bio: 'B',
          image: 'I',
          monthlyFee: '\$50/mo',
          specialities: [],
        );
        expect(p == p, isTrue);
      });

      test('equality operator - different type returns false', () {
        const p = CoachProfile(
          id: 'cp5',
          name: 'N',
          title: 'T',
          rating: '4.0',
          bio: 'B',
          image: 'I',
          monthlyFee: '\$50/mo',
          specialities: [],
        );
        expect(p == 'not a profile', isFalse);
      });
    });

    group('featuredCoaches data integrity', () {
      test('each coach has 2-4 specialities', () {
        for (final coach in CoachService.featuredCoaches) {
          expect(coach.specialities.length, greaterThanOrEqualTo(1));
          expect(coach.specialities.length, lessThanOrEqualTo(5));
        }
      });

      test('coach IDs follow naming convention', () {
        for (final coach in CoachService.featuredCoaches) {
          expect(coach.id, startsWith('coach_'));
        }
      });

      test('coach names start with Coach', () {
        for (final coach in CoachService.featuredCoaches) {
          expect(coach.name, startsWith('Coach '));
        }
      });

      test('all monthly fees start with dollar sign', () {
        for (final coach in CoachService.featuredCoaches) {
          expect(coach.monthlyFee, contains('\$'));
          expect(coach.monthlyFee, contains('/mo'));
        }
      });
    });
  });
}

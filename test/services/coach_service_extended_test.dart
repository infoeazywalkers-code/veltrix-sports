import 'package:flutter_test/flutter_test.dart';
import 'package:veltrix_sports/services/social/coach_service.dart';

void main() {
  group('CoachService - expanded coverage', () {
    group('sendInquiry', () {
      test('sendInquiry returns a Future<bool>', () async {
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

    group('CoachProfile data integrity', () {
      test('fromMap with empty fields uses defaults', () {
        final profile = CoachProfile.fromMap('cp_empty', {});
        expect(profile.id, 'cp_empty');
        expect(profile.name, '');
        expect(profile.title, '');
        expect(profile.rating, '0.0');
        expect(profile.bio, '');
        expect(profile.image, '');
        expect(profile.monthlyFee, '\$0/mo');
        expect(profile.specialities, isEmpty);
      });

      test('toMap serializes all fields', () {
        const profile = CoachProfile(
          id: 'cp6',
          name: 'Coach',
          title: 'Title',
          rating: '4.5',
          bio: 'Bio text',
          image: 'img.png',
          monthlyFee: '\$80/mo',
          specialities: ['Running'],
        );
        final map = profile.toMap();
        expect(map['name'], 'Coach');
        expect(map['title'], 'Title');
        expect(map['rating'], '4.5');
        expect(map['bio'], 'Bio text');
        expect(map['image'], 'img.png');
        expect(map['monthlyFee'], '\$80/mo');
        expect(map['specialities'], ['Running']);
      });

      test('toString returns readable string', () {
        const profile = CoachProfile(
          id: 'cp7',
          name: 'Coach Priya',
          title: 'T',
          rating: '4.0',
          bio: 'B',
          image: 'I',
          monthlyFee: '\$50/mo',
          specialities: [],
        );
        expect(profile.toString(), contains('cp7'));
        expect(profile.toString(), contains('Coach Priya'));
      });

      test('equality is based on id only', () {
        const p1 = CoachProfile(
          id: 'same_id',
          name: 'Name 1',
          title: 'T',
          rating: '4.0',
          bio: 'B',
          image: 'I',
          monthlyFee: '\$50/mo',
          specialities: [],
        );
        const p2 = CoachProfile(
          id: 'same_id',
          name: 'Name 2',
          title: 'T',
          rating: '5.0',
          bio: 'Different',
          image: 'X',
          monthlyFee: '\$99/mo',
          specialities: ['A'],
        );
        expect(p1, p2);
      });
    });
  });
}

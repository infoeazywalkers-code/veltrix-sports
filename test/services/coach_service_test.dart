import 'package:flutter_test/flutter_test.dart';
import 'package:veltrix_sports/services/coach_service.dart';

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

  group('CoachService.featuredCoaches', () {
    test('contains exactly 3 coaches', () {
      expect(CoachService.featuredCoaches.length, 3);
    });

    test('first coach is Coach Priya Sharma', () {
      final coach = CoachService.featuredCoaches[0];
      expect(coach.id, 'coach_priya');
      expect(coach.name, 'Coach Priya Sharma');
      expect(coach.title, contains('Endurance Coach'));
      expect(coach.title, contains('IRONMAN'));
      expect(coach.monthlyFee, '\$149/mo');
      expect(coach.specialities, contains('Marathon'));
      expect(coach.specialities, contains('Triathlon'));
      expect(coach.specialities, contains('Power Metrics'));
    });

    test('second coach is Coach Amit Patel', () {
      final coach = CoachService.featuredCoaches[1];
      expect(coach.id, 'coach_amit');
      expect(coach.name, 'Coach Amit Patel');
      expect(coach.title, contains('Cycling'));
      expect(coach.monthlyFee, '\$179/mo');
      expect(coach.specialities, contains('Cycling'));
      expect(coach.specialities, contains('FTP Training'));
      expect(coach.specialities, contains('Nutrition'));
    });

    test('third coach is Coach Vikram Rao', () {
      final coach = CoachService.featuredCoaches[2];
      expect(coach.id, 'coach_vikram');
      expect(coach.name, 'Coach Vikram Rao');
      expect(coach.title, contains('Ultra-Marathon'));
      expect(coach.monthlyFee, '\$139/mo');
      expect(coach.specialities, contains('Ultra Running'));
      expect(coach.specialities, contains('Strength Prehab'));
      expect(coach.specialities, contains('Mobility'));
    });

    test('all coaches have valid ratings with review counts', () {
      for (final coach in CoachService.featuredCoaches) {
        expect(coach.rating, contains('('));
        expect(coach.rating, contains('reviews)'));
      }
    });

    test('all coaches have non-empty image paths', () {
      for (final coach in CoachService.featuredCoaches) {
        expect(coach.image, isNotEmpty);
        expect(coach.image, startsWith('assets/'));
      }
    });

    test('all coaches have non-empty bios', () {
      for (final coach in CoachService.featuredCoaches) {
        expect(coach.bio, isNotEmpty);
        expect(coach.bio.length, greaterThan(20));
      }
    });

    test('all coaches have unique IDs', () {
      final ids = CoachService.featuredCoaches.map((c) => c.id).toSet();
      expect(ids.length, CoachService.featuredCoaches.length);
    });
  });
}

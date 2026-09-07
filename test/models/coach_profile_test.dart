import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:veltrix_sports/models/coach_profile.dart';

void main() {
  group('CoachProfile', () {
    const profile = CoachProfile(
      id: 'coach-1',
      name: 'Coach Priya',
      title: 'Endurance Specialist',
      rating: '4.9',
      bio: '10+ years coaching elite runners',
      image: 'assets/coach-priya.jpg',
      monthlyFee: '\$99/mo',
      specialities: ['Running', 'Endurance', 'Marathon'],
    );

    test('constructor creates valid instance', () {
      expect(profile.id, 'coach-1');
      expect(profile.name, 'Coach Priya');
      expect(profile.title, 'Endurance Specialist');
      expect(profile.rating, '4.9');
      expect(profile.bio, '10+ years coaching elite runners');
      expect(profile.image, 'assets/coach-priya.jpg');
      expect(profile.monthlyFee, '\$99/mo');
      expect(profile.specialities, ['Running', 'Endurance', 'Marathon']);
    });

    test('fromMap creates valid instance', () {
      final result = CoachProfile.fromMap('c1', {
        'name': 'Coach Ravi',
        'title': 'Strength Coach',
        'rating': '4.7',
        'bio': 'Former athlete',
        'image': 'img.jpg',
        'monthlyFee': '\$79/mo',
        'specialities': ['Strength', 'HIIT'],
      });
      expect(result.id, 'c1');
      expect(result.name, 'Coach Ravi');
      expect(result.title, 'Strength Coach');
      expect(result.rating, '4.7');
      expect(result.specialities, ['Strength', 'HIIT']);
    });

    test('fromMap handles missing fields with defaults', () {
      final result = CoachProfile.fromMap('c2', {});
      expect(result.id, 'c2');
      expect(result.name, '');
      expect(result.title, '');
      expect(result.rating, '0.0');
      expect(result.bio, '');
      expect(result.image, '');
      expect(result.monthlyFee, '\$0/mo');
      expect(result.specialities, []);
    });

    test('fromMap handles null list for specialities', () {
      final result = CoachProfile.fromMap('c3', {'specialities': null});
      expect(result.specialities, []);
    });

    test('toMap serializes correctly', () {
      final map = profile.toMap();
      expect(map['name'], 'Coach Priya');
      expect(map['title'], 'Endurance Specialist');
      expect(map['rating'], '4.9');
      expect(map['bio'], '10+ years coaching elite runners');
      expect(map['image'], 'assets/coach-priya.jpg');
      expect(map['monthlyFee'], '\$99/mo');
      expect(map['specialities'], ['Running', 'Endurance', 'Marathon']);
    });

    test('fromMap → toMap roundtrip preserves data', () {
      final original = {
        'name': 'Coach A',
        'title': 'T1',
        'rating': '5.0',
        'bio': 'Bio',
        'image': 'img.png',
        'monthlyFee': '\$50/mo',
        'specialities': ['Swim'],
      };
      final parsed = CoachProfile.fromMap('x', original);
      final serialized = parsed.toMap();
      expect(serialized, original);
    });

    test('copyWith overrides specified fields', () {
      final updated = profile.copyWith(name: 'Coach New', rating: '4.0');
      expect(updated.id, 'coach-1');
      expect(updated.name, 'Coach New');
      expect(updated.rating, '4.0');
      expect(updated.title, 'Endurance Specialist');
    });

    test('copyWith returns same values when no args', () {
      final same = profile.copyWith();
      expect(same.name, profile.name);
      expect(same.id, profile.id);
      expect(same.specialities, profile.specialities);
    });

    test('copyWith overrides specialities list', () {
      final updated = profile.copyWith(specialities: ['Swim', 'Triathlon']);
      expect(updated.specialities, ['Swim', 'Triathlon']);
    });

    test('equality is based on id', () {
      const p1 = CoachProfile(
        id: 'same-id',
        name: 'Name A',
        title: '',
        rating: '0',
        bio: '',
        image: '',
        monthlyFee: '',
        specialities: [],
      );
      const p2 = CoachProfile(
        id: 'same-id',
        name: 'Name B',
        title: '',
        rating: '0',
        bio: '',
        image: '',
        monthlyFee: '',
        specialities: [],
      );
      expect(p1, equals(p2));
      expect(p1.hashCode, p2.hashCode);
    });

    test('inequality for different ids', () {
      const p1 = CoachProfile(
        id: 'id-1',
        name: 'Same Name',
        title: '',
        rating: '0',
        bio: '',
        image: '',
        monthlyFee: '',
        specialities: [],
      );
      const p2 = CoachProfile(
        id: 'id-2',
        name: 'Same Name',
        title: '',
        rating: '0',
        bio: '',
        image: '',
        monthlyFee: '',
        specialities: [],
      );
      expect(p1, isNot(equals(p2)));
    });

    test('toString returns meaningful string', () {
      expect(profile.toString(), contains('coach-1'));
      expect(profile.toString(), contains('Coach Priya'));
    });

    test('fromMap with all null cast values defaults gracefully', () {
      final result = CoachProfile.fromMap('z', {
        'name': null,
        'title': null,
        'rating': null,
        'bio': null,
        'image': null,
        'monthlyFee': null,
        'specialities': null,
      });
      expect(result.name, '');
      expect(result.rating, '0.0');
      expect(result.monthlyFee, '\$0/mo');
      expect(result.specialities, []);
    });

    test('fromMap with empty specialities list', () {
      final result = CoachProfile.fromMap('z2', {'specialities': <dynamic>[]});
      expect(result.specialities, []);
    });

    test('copyWith overrides id', () {
      final updated = profile.copyWith(id: 'new-id');
      expect(updated.id, 'new-id');
      expect(updated.name, profile.name);
    });

    test('copyWith overrides bio and image', () {
      final updated = profile.copyWith(bio: 'New bio', image: 'new.png');
      expect(updated.bio, 'New bio');
      expect(updated.image, 'new.png');
      expect(updated.name, profile.name);
    });

    test('copyWith overrides monthlyFee', () {
      final updated = profile.copyWith(monthlyFee: '\$199/mo');
      expect(updated.monthlyFee, '\$199/mo');
    });

    test('fromFirestore creates profile from DocumentSnapshot', () async {
      final firestore = FakeFirebaseFirestore();
      await firestore.collection('coaches').doc('fc1').set({
        'name': 'Coach Firestore',
        'title': 'Yoga Expert',
        'rating': '4.8',
        'bio': 'Certified yoga instructor',
        'image': 'yoga.jpg',
        'monthlyFee': '\$120/mo',
        'specialities': ['Yoga', 'Meditation'],
      });
      final doc = await firestore.collection('coaches').doc('fc1').get();
      final result = CoachProfile.fromFirestore(doc);
      expect(result.id, 'fc1');
      expect(result.name, 'Coach Firestore');
      expect(result.title, 'Yoga Expert');
      expect(result.specialities, ['Yoga', 'Meditation']);
    });

    test('fromFirestore handles empty document data', () async {
      final firestore = FakeFirebaseFirestore();
      // Create a doc with minimal data
      await firestore.collection('coaches').doc('fc2').set({});
      final doc = await firestore.collection('coaches').doc('fc2').get();
      final result = CoachProfile.fromFirestore(doc);
      expect(result.id, 'fc2');
      expect(result.name, '');
      expect(result.specialities, []);
    });
  });
}

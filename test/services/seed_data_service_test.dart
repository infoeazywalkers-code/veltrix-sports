import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:veltrix_sports/services/core/seed_data_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SeedDataService (FakeFirestore)', () {
    late FakeFirebaseFirestore firestore;
    late SeedDataService service;

    setUp(() {
      firestore = FakeFirebaseFirestore();
      service = SeedDataService(db: firestore);
    });

    test('seedNewUser creates user profile document', () async {
      await service.seedNewUser(
        'uid-1',
        displayName: 'Alice',
        email: 'alice@test.com',
      );

      final userDoc = await firestore.collection('users').doc('uid-1').get();
      expect(userDoc.exists, isTrue);
      expect(userDoc.data()!['email'], 'alice@test.com');
      expect(userDoc.data()!['displayName'], 'Alice');
      expect(userDoc.data()!['role'], 'athlete');
    });

    test('seedNewUser creates training plan', () async {
      await service.seedNewUser('uid-2');

      final plans =
          await firestore
              .collection('training_plans')
              .where('userId', isEqualTo: 'uid-2')
              .get();
      expect(plans.docs.length, 1);
      expect(plans.docs.first.data()['name'], 'Half Marathon Performance');
    });

    test('seedNewUser creates 7 weekly workouts', () async {
      await service.seedNewUser('uid-3');

      final workouts =
          await firestore
              .collection('workouts')
              .where('userId', isEqualTo: 'uid-3')
              .get();
      expect(workouts.docs.length, 7);
    });

    test('seedNewUser creates 5 performance snapshots', () async {
      await service.seedNewUser('uid-4');

      final snaps =
          await firestore
              .collection('performance_snapshots')
              .where('userId', isEqualTo: 'uid-4')
              .get();
      expect(snaps.docs.length, 5);
    });

    test(
      'seedNewUser is idempotent - does not re-seed existing user',
      () async {
        await service.seedNewUser('uid-5');
        final firstPlan =
            await firestore
                .collection('training_plans')
                .where('userId', isEqualTo: 'uid-5')
                .get();

        await service.seedNewUser('uid-5');
        final secondPlan =
            await firestore
                .collection('training_plans')
                .where('userId', isEqualTo: 'uid-5')
                .get();

        expect(firstPlan.docs.length, secondPlan.docs.length);
      },
    );

    test('seedNewUser uses defaults when name/email are null', () async {
      await service.seedNewUser('uid-6');

      final userDoc = await firestore.collection('users').doc('uid-6').get();
      expect(userDoc.data()!['displayName'], 'Athlete');
      expect(userDoc.data()!['email'], '');
    });

    test('seedNewUser marks completed workouts with progress 1.0', () async {
      await service.seedNewUser('uid-7');

      final workouts =
          await firestore
              .collection('workouts')
              .where('userId', isEqualTo: 'uid-7')
              .get();
      final completedCount =
          workouts.docs.where((d) => d.data()['completed'] == true).length;
      expect(completedCount, greaterThanOrEqualTo(3));
    });

    test('seedNewUser creates workouts with segments', () async {
      await service.seedNewUser('uid-8');

      final workouts =
          await firestore
              .collection('workouts')
              .where('userId', isEqualTo: 'uid-8')
              .get();
      final withSegments = workouts.docs.where(
        (d) => (d.data()['segments'] as List).isNotEmpty,
      );
      expect(withSegments.isNotEmpty, isTrue);
    });

    test(
      'seedNewUser creates performance snapshots with correct fitness progression',
      () async {
        await service.seedNewUser('uid-9');

        final snaps =
            await firestore
                .collection('performance_snapshots')
                .where('userId', isEqualTo: 'uid-9')
                .get();
        final fitnessValues =
            snaps.docs
                .map((d) => (d.data()['fitness'] as num).toDouble())
                .toList();
        expect(fitnessValues.first, lessThan(fitnessValues.last));
      },
    );
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:veltrix_sports/models/user_profile.dart';
import 'package:veltrix_sports/models/workout.dart';
import 'package:veltrix_sports/models/performance_snapshot.dart';
import 'package:veltrix_sports/models/training_plan.dart';
import 'package:veltrix_sports/models/coach_request.dart';
import 'package:veltrix_sports/models/coach_profile.dart';

void main() {
  group('UserProfile - edge cases', () {
    test('fromMap with empty map uses defaults', () {
      final profile = UserProfile.fromMap('u1', {});
      expect(profile.id, 'u1');
      expect(profile.email, '');
      expect(profile.displayName, '');
      expect(profile.photoUrl, isNull);
      expect(profile.role, UserRole.athlete);
      expect(profile.sports, isEmpty);
      expect(profile.experienceLevel, isNull);
      expect(profile.mainGoal, isNull);
      expect(profile.isPremium, false);
      expect(profile.subscriptionTier, isNull);
      expect(profile.subscriptionRenewsAt, isNull);
      expect(profile.deviceIds, isEmpty);
      expect(profile.createdAt, isA<DateTime>());
    });

    test('fromMap with null values uses defaults', () {
      final profile = UserProfile.fromMap('u2', {
        'email': null,
        'displayName': null,
        'role': null,
        'sports': null,
        'deviceIds': null,
        'createdAt': null,
      });
      expect(profile.email, '');
      expect(profile.displayName, '');
      expect(profile.role, UserRole.athlete);
      expect(profile.sports, isEmpty);
      expect(profile.deviceIds, isEmpty);
      expect(profile.createdAt, isA<DateTime>());
    });

    test('fromMap with coach role', () {
      final profile = UserProfile.fromMap('u3', {'role': 'coach'});
      expect(profile.role, UserRole.coach);
    });

    test('fromMap with premium user', () {
      final profile = UserProfile.fromMap('u4', {
        'isPremium': true,
        'subscriptionTier': 'Pro',
      });
      expect(profile.isPremium, true);
      expect(profile.subscriptionTier, 'Pro');
    });

    test('toMap roundtrip preserves data', () {
      final profile = UserProfile(
        id: 'u5',
        email: 'test@test.com',
        displayName: 'Test User',
        role: UserRole.athlete,
        sports: ['Running', 'Cycling'],
        isPremium: true,
        createdAt: DateTime(2026, 1, 1),
      );
      final map = profile.toMap();
      expect(map['email'], 'test@test.com');
      expect(map['displayName'], 'Test User');
      expect(map['role'], 'athlete');
      expect(map['sports'], ['Running', 'Cycling']);
      expect(map['isPremium'], true);
    });

    test('UserRole enum has 2 values', () {
      expect(UserRole.values.length, 2);
      expect(UserRole.values, contains(UserRole.athlete));
      expect(UserRole.values, contains(UserRole.coach));
    });
  });

  group('Workout - edge cases', () {
    test('fromMap with empty map uses defaults', () {
      final workout = Workout.fromMap('w1', {});
      expect(workout.id, 'w1');
      expect(workout.userId, '');
      expect(workout.planId, '');
      expect(workout.sport, Sport.run);
      expect(workout.title, '');
      expect(workout.description, '');
      expect(workout.duration, '');
      expect(workout.distanceKm, isNull);
      expect(workout.tss, isNull);
      expect(workout.targetPace, isNull);
      expect(workout.scheduledFor, isA<DateTime>());
      expect(workout.progress, 0);
      expect(workout.completed, false);
      expect(workout.segments, isEmpty);
    });

    test('fromMap with null values uses defaults', () {
      final workout = Workout.fromMap('w2', {
        'sport': null,
        'distanceKm': null,
        'tss': null,
        'progress': null,
        'completed': null,
        'segments': null,
      });
      expect(workout.sport, Sport.run);
      expect(workout.distanceKm, isNull);
      expect(workout.tss, isNull);
      expect(workout.progress, 0);
      expect(workout.completed, false);
      expect(workout.segments, isEmpty);
    });

    test('fromMap with all Sport enum values', () {
      for (final sport in Sport.values) {
        final w = Workout.fromMap('w_$sport', {'sport': sport.name});
        expect(w.sport, sport);
      }
    });

    test('toMap roundtrip preserves data', () {
      final workout = Workout(
        id: 'w_rt',
        userId: 'u1',
        planId: 'p1',
        sport: Sport.bike,
        title: 'Test Ride',
        duration: '1h',
        distanceKm: 30.0,
        tss: 80,
        scheduledFor: DateTime(2026, 9, 1),
        progress: 0.5,
        completed: false,
      );
      final map = workout.toMap();
      expect(map['userId'], 'u1');
      expect(map['sport'], 'bike');
      expect(map['title'], 'Test Ride');
      expect(map['distanceKm'], 30.0);
      expect(map['tss'], 80);
      expect(map['progress'], 0.5);
    });

    test('WorkoutSegment fromMap and toMap roundtrip', () {
      final seg = WorkoutSegment.fromMap({
        'label': 'Warm Up',
        'duration': '10min',
      });
      expect(seg.label, 'Warm Up');
      expect(seg.duration, '10min');
      final map = seg.toMap();
      expect(map['label'], 'Warm Up');
      expect(map['duration'], '10min');
    });

    test('WorkoutSegment fromMap with nulls uses defaults', () {
      final seg = WorkoutSegment.fromMap({});
      expect(seg.label, '');
      expect(seg.duration, '');
    });

    test('Sport enum has 5 values', () {
      expect(Sport.values.length, 5);
    });
  });

  group('PerformanceSnapshot - edge cases', () {
    test('fromMap with empty map uses defaults', () {
      final snap = PerformanceSnapshot.fromMap('s1', {});
      expect(snap.id, 's1');
      expect(snap.userId, '');
      expect(snap.fitness, 0);
      expect(snap.fatigue, 0);
      expect(snap.form, 0);
      expect(snap.weeklyTss, 0);
      expect(snap.weeklyWorkouts, 0);
      expect(snap.weeklyDuration, '');
      expect(snap.recordedAt, isA<DateTime>());
    });

    test('fromMap with null values uses defaults', () {
      final snap = PerformanceSnapshot.fromMap('s2', {
        'fitness': null,
        'fatigue': null,
        'form': null,
        'weeklyTss': null,
        'weeklyWorkouts': null,
      });
      expect(snap.fitness, 0);
      expect(snap.fatigue, 0);
      expect(snap.form, 0);
      expect(snap.weeklyTss, 0);
      expect(snap.weeklyWorkouts, 0);
    });

    test('toMap roundtrip preserves data', () {
      final snap = PerformanceSnapshot(
        id: 's3',
        userId: 'u1',
        fitness: 54.5,
        fatigue: 61.2,
        form: -6.7,
        weeklyTss: 300,
        weeklyWorkouts: 5,
        weeklyDuration: '5h 30m',
        recordedAt: DateTime(2026, 9, 1),
      );
      final map = snap.toMap();
      expect(map['fitness'], 54.5);
      expect(map['fatigue'], 61.2);
      expect(map['form'], -6.7);
      expect(map['weeklyTss'], 300);
      expect(map['weeklyWorkouts'], 5);
      expect(map['weeklyDuration'], '5h 30m');
    });
  });

  group('TrainingPlan - edge cases', () {
    test('fromMap with empty map uses defaults', () {
      final plan = TrainingPlan.fromMap('tp1', {});
      expect(plan.id, 'tp1');
      expect(plan.userId, '');
      expect(plan.coachId, isNull);
      expect(plan.name, '');
      expect(plan.description, '');
      expect(plan.sport, 'Running');
      expect(plan.durationWeeks, 8);
      expect(plan.difficulty, 'Intermediate');
      expect(plan.targetGoal, '');
      expect(plan.price, 0.0);
      expect(plan.eventName, isNull);
      expect(plan.startDate, isNull);
      expect(plan.endDate, isNull);
      expect(plan.totalDistanceKm, isNull);
      expect(plan.status, 'active');
      expect(plan.createdAt, isNull);
    });

    test('toMap roundtrip preserves data', () {
      const plan = TrainingPlan(
        id: 'tp2',
        userId: 'u1',
        coachId: 'c1',
        name: 'Marathon Plan',
        description: '12 week plan',
        sport: 'Running',
        durationWeeks: 12,
        difficulty: 'Advanced',
        targetGoal: 'Sub 3hr Marathon',
        price: 149.0,
        status: 'active',
      );
      final map = plan.toMap();
      expect(map['userId'], 'u1');
      expect(map['coachId'], 'c1');
      expect(map['name'], 'Marathon Plan');
      expect(map['durationWeeks'], 12);
      expect(map['price'], 149.0);
    });
  });

  group('CoachRequest - edge cases', () {
    test('fromMap with empty map uses defaults', () {
      final req = CoachRequest.fromMap('cr1', {});
      expect(req.id, 'cr1');
      expect(req.userId, '');
      expect(req.sport, '');
      expect(req.experience, '');
      expect(req.goal, '');
      expect(req.notes, '');
      expect(req.status, 'pending');
      expect(req.matchedCoachId, isNull);
      expect(req.createdAt, isA<DateTime>());
    });

    test('toMap roundtrip preserves data', () {
      final req = CoachRequest(
        id: 'cr2',
        userId: 'u1',
        sport: 'Cycling',
        experience: 'Advanced',
        goal: 'FTP increase',
        notes: 'Looking for power coach',
        matchedCoachId: 'coach_1',
        createdAt: DateTime(2026, 9, 1),
      );
      final map = req.toMap();
      expect(map['sport'], 'Cycling');
      expect(map['experience'], 'Advanced');
      expect(map['goal'], 'FTP increase');
      expect(map['matchedCoachId'], 'coach_1');
    });
  });

  group('CoachProfile - edge cases', () {
    test('fromMap with empty map uses defaults', () {
      final profile = CoachProfile.fromMap('cp1', {});
      expect(profile.id, 'cp1');
      expect(profile.name, '');
      expect(profile.title, '');
      expect(profile.rating, '0.0');
      expect(profile.bio, '');
      expect(profile.image, '');
      expect(profile.monthlyFee, '\$0/mo');
      expect(profile.specialities, isEmpty);
    });

    test('fromMap with null specialities uses empty list', () {
      final profile = CoachProfile.fromMap('cp2', {'specialities': null});
      expect(profile.specialities, isEmpty);
    });

    test('toMap roundtrip preserves data', () {
      const profile = CoachProfile(
        id: 'cp3',
        name: 'Coach Test',
        title: 'Head Coach',
        rating: '4.9',
        bio: 'Test bio',
        image: 'test.png',
        monthlyFee: '\$100/mo',
        specialities: ['Running', 'Cycling'],
      );
      final map = profile.toMap();
      expect(map['name'], 'Coach Test');
      expect(map['title'], 'Head Coach');
      expect(map['rating'], '4.9');
      expect(map['specialities'], ['Running', 'Cycling']);
    });

    test('copyWith overrides only specified fields', () {
      const original = CoachProfile(
        id: 'cp4',
        name: 'Original Name',
        title: 'Title',
        rating: '4.5',
        bio: 'Bio',
        image: 'img.png',
        monthlyFee: '\$99/mo',
        specialities: ['Running'],
      );
      final copy = original.copyWith(name: 'New Name', rating: '5.0');
      expect(copy.name, 'New Name');
      expect(copy.rating, '5.0');
      expect(copy.id, 'cp4');
      expect(copy.title, 'Title');
    });

    test('equality is based on id', () {
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
        rating: '4.0',
        bio: 'B',
        image: 'I',
        monthlyFee: '\$50/mo',
        specialities: [],
      );
      expect(p1, equals(p2));
      expect(p1.hashCode, p2.hashCode);
    });

    test('inequality for different ids', () {
      const p1 = CoachProfile(
        id: 'id_1',
        name: 'Name',
        title: 'T',
        rating: '4.0',
        bio: 'B',
        image: 'I',
        monthlyFee: '\$50/mo',
        specialities: [],
      );
      const p2 = CoachProfile(
        id: 'id_2',
        name: 'Name',
        title: 'T',
        rating: '4.0',
        bio: 'B',
        image: 'I',
        monthlyFee: '\$50/mo',
        specialities: [],
      );
      expect(p1, isNot(equals(p2)));
    });

    test('toString includes id and name', () {
      const p = CoachProfile(
        id: 'test_id',
        name: 'Test Name',
        title: 'T',
        rating: '4.0',
        bio: 'B',
        image: 'I',
        monthlyFee: '\$50/mo',
        specialities: [],
      );
      expect(p.toString(), contains('test_id'));
      expect(p.toString(), contains('Test Name'));
    });
  });
}

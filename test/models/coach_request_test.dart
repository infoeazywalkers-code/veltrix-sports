import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:veltrix_sports/models/user/coach_request.dart';

void main() {
  group('CoachRequest', () {
    test('fromMap creates correct request with all fields', () {
      final timestamp = Timestamp.fromDate(DateTime(2026, 6, 15, 10, 30));
      final map = {
        'userId': 'user1',
        'sport': 'Running',
        'experience': 'Intermediate',
        'goal': 'Improve performance',
        'notes': 'Busy schedule',
        'status': 'matched',
        'matchedCoachId': 'coach1',
        'createdAt': timestamp,
      };

      final request = CoachRequest.fromMap('req1', map);

      expect(request.id, 'req1');
      expect(request.userId, 'user1');
      expect(request.sport, 'Running');
      expect(request.experience, 'Intermediate');
      expect(request.goal, 'Improve performance');
      expect(request.notes, 'Busy schedule');
      expect(request.status, 'matched');
      expect(request.matchedCoachId, 'coach1');
      expect(request.createdAt, timestamp.toDate());
    });

    test('fromMap handles missing optional fields with defaults', () {
      final map = <String, dynamic>{
        'userId': 'user2',
        'sport': 'Cycling',
        'experience': 'Beginner',
        'goal': 'Lose weight',
      };

      final request = CoachRequest.fromMap('req2', map);

      expect(request.id, 'req2');
      expect(request.userId, 'user2');
      expect(request.sport, 'Cycling');
      expect(request.notes, '');
      expect(request.status, 'pending');
      expect(request.matchedCoachId, isNull);
      expect(request.createdAt, isA<DateTime>());
    });

    test('fromMap handles completely empty map', () {
      final request = CoachRequest.fromMap('req3', {});

      expect(request.id, 'req3');
      expect(request.userId, '');
      expect(request.sport, '');
      expect(request.experience, '');
      expect(request.goal, '');
      expect(request.notes, '');
      expect(request.status, 'pending');
      expect(request.matchedCoachId, isNull);
      expect(request.createdAt, isA<DateTime>());
    });

    test('fromMap handles null values in map', () {
      final map = <String, dynamic>{
        'userId': null,
        'sport': null,
        'experience': null,
        'goal': null,
        'notes': null,
        'status': null,
        'matchedCoachId': null,
        'createdAt': null,
      };

      final request = CoachRequest.fromMap('req4', map);

      expect(request.userId, '');
      expect(request.sport, '');
      expect(request.experience, '');
      expect(request.goal, '');
      expect(request.notes, '');
      expect(request.status, 'pending');
      expect(request.matchedCoachId, isNull);
      expect(request.createdAt, isA<DateTime>());
    });

    test('fromMap handles matchedCoachId as a string', () {
      final map = <String, dynamic>{
        'userId': 'u1',
        'sport': 'Running',
        'experience': 'Advanced',
        'goal': 'Race',
        'matchedCoachId': 'coach_42',
        'status': 'matched',
      };

      final request = CoachRequest.fromMap('r1', map);
      expect(request.matchedCoachId, 'coach_42');
    });

    test('toMap returns correct map', () {
      final now = DateTime(2026, 8, 10);
      final request = CoachRequest(
        id: 'req5',
        userId: 'user5',
        sport: 'Swimming',
        experience: 'Expert',
        goal: 'Triathlon',
        notes: 'Weekends only',
        status: 'pending',
        matchedCoachId: null,
        createdAt: now,
      );

      final map = request.toMap();

      expect(map['userId'], 'user5');
      expect(map['sport'], 'Swimming');
      expect(map['experience'], 'Expert');
      expect(map['goal'], 'Triathlon');
      expect(map['notes'], 'Weekends only');
      expect(map['status'], 'pending');
      expect(map['matchedCoachId'], isNull);
      expect(map['createdAt'], now);
    });

    test('toMap with matchedCoachId', () {
      final request = CoachRequest(
        id: 'req6',
        userId: 'user6',
        sport: 'Cycling',
        experience: 'Beginner',
        goal: 'Fitness',
        createdAt: DateTime(2026),
        status: 'matched',
        matchedCoachId: 'coach_99',
      );

      final map = request.toMap();
      expect(map['matchedCoachId'], 'coach_99');
      expect(map['status'], 'matched');
    });

    test('constructor defaults for notes and status', () {
      final request = CoachRequest(
        id: 'req7',
        userId: 'u7',
        sport: 'Running',
        experience: 'Intermediate',
        goal: 'Marathon',
        createdAt: DateTime(2026),
      );

      expect(request.notes, '');
      expect(request.status, 'pending');
      expect(request.matchedCoachId, isNull);
    });

    test('fromMap and toMap roundtrip preserves data', () {
      final originalMap = <String, dynamic>{
        'userId': 'roundtrip_user',
        'sport': 'Running',
        'experience': 'Advanced',
        'goal': 'Sub 3hr marathon',
        'notes': 'Train Tues/Thurs',
        'status': 'matched',
        'matchedCoachId': 'coach_rt',
        'createdAt': Timestamp.fromDate(DateTime(2026, 3, 15)),
      };

      final request = CoachRequest.fromMap('rt1', originalMap);
      final roundtrippedMap = request.toMap();

      expect(roundtrippedMap['userId'], originalMap['userId']);
      expect(roundtrippedMap['sport'], originalMap['sport']);
      expect(roundtrippedMap['experience'], originalMap['experience']);
      expect(roundtrippedMap['goal'], originalMap['goal']);
      expect(roundtrippedMap['notes'], originalMap['notes']);
      expect(roundtrippedMap['status'], originalMap['status']);
      expect(roundtrippedMap['matchedCoachId'], originalMap['matchedCoachId']);
    });

    test('supports empty string values', () {
      final request = CoachRequest(
        id: '',
        userId: '',
        sport: '',
        experience: '',
        goal: '',
        notes: '',
        createdAt: DateTime(2026),
      );

      expect(request.id, '');
      expect(request.userId, '');
      expect(request.sport, '');
    });

    test('fromMap throws on numeric userId (non-String cast)', () {
      final map = <String, dynamic>{
        'userId': 123,
        'sport': 'Running',
        'experience': 'Beginner',
        'goal': 'Fitness',
      };

      // Non-String values cast as String? will throw a TypeError
      expect(() => CoachRequest.fromMap('id', map), throwsA(isA<TypeError>()));
    });
  });
}

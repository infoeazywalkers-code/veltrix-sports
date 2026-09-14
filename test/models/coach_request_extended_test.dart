import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:veltrix_sports/models/user/coach_request.dart';

void main() {
  group('CoachRequest - Extended', () {
    test('fromMap with null createdAt defaults to now', () {
      final map = <String, dynamic>{
        'userId': 'u',
        'sport': 'Running',
        'experience': 'Beginner',
        'goal': 'Fitness',
        'createdAt': null,
      };
      final req = CoachRequest.fromMap('id', map);
      expect(req.createdAt, isA<DateTime>());
    });

    test('fromMap with invalid matchedCoachId type throws', () {
      final map = <String, dynamic>{
        'userId': 'u',
        'sport': 'Running',
        'experience': 'Beginner',
        'goal': 'Fitness',
        'matchedCoachId': 123,
      };
      expect(() => CoachRequest.fromMap('id', map), throwsA(isA<TypeError>()));
    });

    test('toMap fromMap roundtrip with matchedCoachId', () {
      final req = CoachRequest(
        id: 'rt',
        userId: 'u',
        sport: 'Cycling',
        experience: 'Advanced',
        goal: 'Race',
        notes: 'Train hard',
        status: 'matched',
        matchedCoachId: 'coach_42',
        createdAt: DateTime(2026),
      );

      final map = req.toMap();
      // toMap puts DateTime, but fromMap casts createdAt as Timestamp?
      // We need to convert the createdAt to Timestamp for fromMap
      final tsMap = Map<String, dynamic>.from(map);
      tsMap['createdAt'] = Timestamp.fromDate(req.createdAt);
      final restored = CoachRequest.fromMap('rt', tsMap);

      expect(restored.userId, 'u');
      expect(restored.sport, 'Cycling');
      expect(restored.experience, 'Advanced');
      expect(restored.goal, 'Race');
      expect(restored.notes, 'Train hard');
      expect(restored.status, 'matched');
      expect(restored.matchedCoachId, 'coach_42');
    });

    test('toMap fromMap roundtrip without matchedCoachId', () {
      final req = CoachRequest(
        id: 'rt2',
        userId: 'u',
        sport: 'Swimming',
        experience: 'Beginner',
        goal: 'Learn',
        createdAt: DateTime(2026),
      );

      final map = req.toMap();
      final tsMap = Map<String, dynamic>.from(map);
      tsMap['createdAt'] = Timestamp.fromDate(req.createdAt);
      final restored = CoachRequest.fromMap('rt2', tsMap);

      expect(restored.matchedCoachId, isNull);
      expect(restored.status, 'pending');
    });

    test('handles empty matchedCoachId string', () {
      final map = <String, dynamic>{
        'userId': 'u',
        'sport': 'Running',
        'experience': 'Beginner',
        'goal': 'Fitness',
        'matchedCoachId': '',
        'status': 'matched',
      };
      final req = CoachRequest.fromMap('id', map);
      expect(req.matchedCoachId, '');
    });

    test('status variations', () {
      for (final status in ['pending', 'matched', 'rejected', 'completed']) {
        final req = CoachRequest(
          id: 'id',
          userId: 'u',
          sport: 'Running',
          experience: 'Beginner',
          goal: 'Fitness',
          status: status,
          createdAt: DateTime(2026),
        );
        expect(req.status, status);
      }
    });

    test('handles very long notes', () {
      final req = CoachRequest(
        id: 'id',
        userId: 'u',
        sport: 'Running',
        experience: 'Beginner',
        goal: 'Fitness',
        notes: 'N' * 1000,
        createdAt: DateTime(2026),
      );
      expect(req.notes.length, 1000);
    });

    test('toMap does not include id', () {
      final req = CoachRequest(
        id: 'no_id',
        userId: 'u',
        sport: 'Running',
        experience: 'Beginner',
        goal: 'Fitness',
        createdAt: DateTime(2026),
      );
      final map = req.toMap();
      expect(map.containsKey('id'), false);
    });

    test('toMap has correct number of fields', () {
      final req = CoachRequest(
        id: 'id',
        userId: 'u',
        sport: 'Running',
        experience: 'Beginner',
        goal: 'Fitness',
        notes: 'notes',
        status: 'pending',
        matchedCoachId: null,
        createdAt: DateTime(2026),
      );
      final map = req.toMap();
      expect(map.length, 9); // all fields except id (incl. package)
    });
  });
}

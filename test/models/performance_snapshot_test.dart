import 'package:flutter_test/flutter_test.dart';
import 'package:veltrix_sports/models/performance_snapshot.dart';

void main() {
  group('PerformanceSnapshot', () {
    test('fromMap creates correct snapshot', () {
      final map = {
        'userId': 'user1',
        'fitness': 54.0,
        'fatigue': 61.0,
        'form': -7.0,
        'weeklyTss': 286.0,
        'weeklyWorkouts': 5,
        'weeklyDuration': '4h 35m',
      };

      final snapshot = PerformanceSnapshot.fromMap('snap1', map);

      expect(snapshot.id, 'snap1');
      expect(snapshot.fitness, 54.0);
      expect(snapshot.fatigue, 61.0);
      expect(snapshot.form, -7.0);
      expect(snapshot.weeklyWorkouts, 5);
    });
  });
}

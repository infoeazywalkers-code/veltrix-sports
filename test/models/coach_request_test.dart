import 'package:flutter_test/flutter_test.dart';
import 'package:veltrix_sports/models/coach_request.dart';

void main() {
  group('CoachRequest', () {
    test('fromMap creates correct request', () {
      final map = {
        'userId': 'user1',
        'sport': 'Running',
        'experience': 'Intermediate',
        'goal': 'Improve performance',
        'notes': 'Busy schedule',
        'status': 'pending',
        'matchedCoachId': null,
      };

      final request = CoachRequest.fromMap('req1', map);

      expect(request.id, 'req1');
      expect(request.userId, 'user1');
      expect(request.sport, 'Running');
      expect(request.status, 'pending');
      expect(request.matchedCoachId, null);
    });
  });
}

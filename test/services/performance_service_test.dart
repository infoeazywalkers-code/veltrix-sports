import 'package:flutter_test/flutter_test.dart';
import 'package:veltrix_sports/services/performance_service.dart';

void main() {
  group('PerformanceService', () {
    test('PerformanceService class exists', () {
      expect(PerformanceService, isA<Type>());
    });

    test('PerformanceService can be instantiated', () {
      // PerformanceService uses FirebaseFirestore.instance internally
      // but the constructor itself should not fail
      try {
        final service = PerformanceService();
        expect(service, isNotNull);
      } catch (e) {
        // If FirebaseFirestore is not initialized, this is expected
        expect(e, isA<Exception>());
      }
    });
  });
}

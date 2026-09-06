import 'package:flutter_test/flutter_test.dart';
import 'package:veltrix_sports/services/connectivity_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ConnectivityService - Extended', () {
    test('creates instance', () {
      final service = ConnectivityService();
      expect(service, isNotNull);
    });

    test('onConnectivityChanged returns Stream', () {
      final service = ConnectivityService();
      expect(service.onConnectivityChanged, isA<Stream>());
    });

    test('multiple instances are different objects', () {
      final s1 = ConnectivityService();
      final s2 = ConnectivityService();
      expect(identical(s1, s2), isFalse);
    });
  });
}

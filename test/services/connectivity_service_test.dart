import 'package:flutter_test/flutter_test.dart';
import 'package:veltrix_sports/services/connectivity_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ConnectivityService', () {
    test('creates ConnectivityService instance', () {
      final service = ConnectivityService();
      expect(service, isNotNull);
    });

    test('onConnectivityChanged returns a stream', () {
      final service = ConnectivityService();
      expect(service.onConnectivityChanged, isA<Stream>());
    });
  });
}

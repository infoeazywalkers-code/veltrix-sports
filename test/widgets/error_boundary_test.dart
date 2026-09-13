import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:veltrix_sports/widgets/common/error_boundary.dart';

void main() {
  testWidgets('VeltrixErrorBoundary renders error message and reload button', (
    tester,
  ) async {
    const details = FlutterErrorDetails(
      exception: 'Test rendering exception error',
      library: 'test library',
    );

    await tester.pumpWidget(
      const MaterialApp(home: VeltrixErrorBoundary(details: details)),
    );

    expect(find.text('SOMETHING WENT WRONG'), findsOneWidget);
    expect(
      find.textContaining('Test rendering exception error'),
      findsOneWidget,
    );
    expect(find.text('Reload Application View'), findsOneWidget);
  });
}

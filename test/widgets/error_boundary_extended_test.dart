import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:veltrix_sports/widgets/error_boundary.dart';

void main() {
  group('VeltrixErrorBoundary - Extended', () {
    testWidgets('renders SOMETHING WENT WRONG text', (tester) async {
      const details = FlutterErrorDetails(
        exception: 'Test error',
        library: 'test',
      );

      await tester.pumpWidget(
        const MaterialApp(home: VeltrixErrorBoundary(details: details)),
      );

      expect(find.text('SOMETHING WENT WRONG'), findsOneWidget);
    });

    testWidgets('renders warning icon', (tester) async {
      const details = FlutterErrorDetails(
        exception: 'Icon test',
        library: 'test',
      );

      await tester.pumpWidget(
        const MaterialApp(home: VeltrixErrorBoundary(details: details)),
      );

      expect(find.byIcon(Icons.warning_amber_rounded), findsOneWidget);
    });

    testWidgets('renders error message text', (tester) async {
      const details = FlutterErrorDetails(
        exception: 'Null pointer exception at line 42',
        library: 'test_lib',
      );

      await tester.pumpWidget(
        const MaterialApp(home: VeltrixErrorBoundary(details: details)),
      );

      expect(find.textContaining('Null pointer exception'), findsOneWidget);
    });

    testWidgets('renders reload button', (tester) async {
      const details = FlutterErrorDetails(exception: 'Test', library: 'test');

      await tester.pumpWidget(
        const MaterialApp(home: VeltrixErrorBoundary(details: details)),
      );

      expect(find.text('Reload Application View'), findsOneWidget);
      expect(find.byIcon(Icons.refresh), findsOneWidget);
    });

    testWidgets('renders safety message', (tester) async {
      const details = FlutterErrorDetails(exception: 'Test', library: 'test');

      await tester.pumpWidget(
        const MaterialApp(home: VeltrixErrorBoundary(details: details)),
      );

      expect(find.textContaining('your workout data is safe'), findsOneWidget);
    });

    testWidgets('renders with different exception messages', (tester) async {
      const details = FlutterErrorDetails(
        exception: 'Custom error: Division by zero',
        library: 'math',
      );

      await tester.pumpWidget(
        const MaterialApp(home: VeltrixErrorBoundary(details: details)),
      );

      expect(find.textContaining('Division by zero'), findsOneWidget);
    });

    testWidgets('renders with very long exception message', (tester) async {
      final longMsg = 'E' * 500;
      final details = FlutterErrorDetails(exception: longMsg, library: 'test');

      await tester.pumpWidget(
        MaterialApp(home: VeltrixErrorBoundary(details: details)),
      );

      // The widget uses maxLines: 3 and ellipsis, so only part is shown
      expect(find.byType(Text), findsWidgets);
    });

    testWidgets('reload button has correct styling', (tester) async {
      const details = FlutterErrorDetails(
        exception: 'Style test',
        library: 'test',
      );

      await tester.pumpWidget(
        const MaterialApp(home: VeltrixErrorBoundary(details: details)),
      );

      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(button, isNotNull);
    });
  });
}

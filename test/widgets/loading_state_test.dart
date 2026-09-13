import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:veltrix_sports/widgets/common/loading_state.dart';

void main() {
  Widget wrap(Widget child) => MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(child: Center(child: child)),
    ),
  );

  group('LoadingSpinner', () {
    testWidgets('renders CircularProgressIndicator', (tester) async {
      await tester.pumpWidget(wrap(const LoadingSpinner()));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('renders message when provided', (tester) async {
      await tester.pumpWidget(
        wrap(const LoadingSpinner(message: 'Loading workouts...')),
      );
      expect(find.text('Loading workouts...'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('does not render message when null', (tester) async {
      await tester.pumpWidget(wrap(const LoadingSpinner()));
      expect(find.byType(Text), findsNothing);
    });
  });

  group('ErrorState', () {
    testWidgets('renders error icon and message', (tester) async {
      await tester.pumpWidget(
        wrap(const ErrorState(message: 'Something failed')),
      );
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
      expect(find.text('Something failed'), findsOneWidget);
      expect(find.byType(FilledButton), findsNothing);
    });

    testWidgets('renders retry button when onRetry is provided', (
      tester,
    ) async {
      var retried = false;
      await tester.pumpWidget(
        wrap(
          ErrorState(message: 'Network error', onRetry: () => retried = true),
        ),
      );
      expect(find.byType(FilledButton), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);

      await tester.tap(find.byType(FilledButton));
      expect(retried, isTrue);
    });

    testWidgets('does not render retry button when onRetry is null', (
      tester,
    ) async {
      await tester.pumpWidget(wrap(const ErrorState(message: 'Fail')));
      expect(find.byType(FilledButton), findsNothing);
    });
  });

  group('EmptyState', () {
    testWidgets('renders icon, title, and subtitle', (tester) async {
      await tester.pumpWidget(
        wrap(
          const EmptyState(
            icon: Icons.fitness_center,
            title: 'No Workouts',
            subtitle: 'Start your first workout to see data here.',
          ),
        ),
      );
      expect(find.byIcon(Icons.fitness_center), findsOneWidget);
      expect(find.text('No Workouts'), findsOneWidget);
      expect(
        find.text('Start your first workout to see data here.'),
        findsOneWidget,
      );
    });

    testWidgets('renders with different icon', (tester) async {
      await tester.pumpWidget(
        wrap(
          const EmptyState(
            icon: Icons.event_busy,
            title: 'No Events',
            subtitle: 'No upcoming events.',
          ),
        ),
      );
      expect(find.byIcon(Icons.event_busy), findsOneWidget);
    });
  });
}

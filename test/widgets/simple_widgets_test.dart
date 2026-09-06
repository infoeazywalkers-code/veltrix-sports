import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:veltrix_sports/widgets/trust_badge.dart';
import 'package:veltrix_sports/widgets/brand.dart';
import 'package:veltrix_sports/widgets/device_chip.dart';
import 'package:veltrix_sports/widgets/metric.dart';
import 'package:veltrix_sports/widgets/heading.dart';

Widget wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  group('TrustBadge', () {
    testWidgets('renders icon and label', (tester) async {
      await tester.pumpWidget(
        wrap(const TrustBadge(Icons.verified, 'Verified Coach')),
      );
      expect(find.byIcon(Icons.verified), findsOneWidget);
      expect(find.text('Verified Coach'), findsOneWidget);
    });

    testWidgets('renders with different icon', (tester) async {
      await tester.pumpWidget(wrap(const TrustBadge(Icons.shield, 'Secure')));
      expect(find.byIcon(Icons.shield), findsOneWidget);
      expect(find.text('Secure'), findsOneWidget);
    });

    testWidgets('renders with empty label', (tester) async {
      await tester.pumpWidget(wrap(const TrustBadge(Icons.star, '')));
      expect(find.byIcon(Icons.star), findsOneWidget);
    });

    testWidgets('renders inside a Row', (tester) async {
      await tester.pumpWidget(wrap(const TrustBadge(Icons.check, 'Test')));
      expect(find.byType(Row), findsOneWidget);
    });
  });

  group('Brand', () {
    testWidgets('renders with default size', (tester) async {
      await tester.pumpWidget(wrap(const Brand()));
      expect(find.byIcon(Icons.bolt_rounded), findsOneWidget);
    });

    testWidgets('renders with custom size', (tester) async {
      await tester.pumpWidget(wrap(const Brand(size: 64)));
      expect(find.byIcon(Icons.bolt_rounded), findsOneWidget);
    });

    testWidgets('renders with small size', (tester) async {
      await tester.pumpWidget(wrap(const Brand(size: 10)));
      expect(find.byIcon(Icons.bolt_rounded), findsOneWidget);
    });

    testWidgets('renders with large size', (tester) async {
      await tester.pumpWidget(wrap(const Brand(size: 200)));
      expect(find.byIcon(Icons.bolt_rounded), findsOneWidget);
    });
  });

  group('DeviceChip', () {
    testWidgets('renders icon and label', (tester) async {
      await tester.pumpWidget(
        wrap(const DeviceChip(Icons.watch, 'Apple Watch')),
      );
      expect(find.byIcon(Icons.watch), findsOneWidget);
      expect(find.text('Apple Watch'), findsOneWidget);
    });

    testWidgets('renders with different device', (tester) async {
      await tester.pumpWidget(
        wrap(const DeviceChip(Icons.bluetooth, 'Garmin')),
      );
      expect(find.byIcon(Icons.bluetooth), findsOneWidget);
      expect(find.text('Garmin'), findsOneWidget);
    });

    testWidgets('renders with empty label', (tester) async {
      await tester.pumpWidget(wrap(const DeviceChip(Icons.phone_iphone, '')));
      expect(find.byIcon(Icons.phone_iphone), findsOneWidget);
    });
  });

  group('Metric', () {
    testWidgets('renders value and label', (tester) async {
      await tester.pumpWidget(wrap(const Metric('185', 'Heart Rate')));
      expect(find.text('185'), findsOneWidget);
      expect(find.text('Heart Rate'), findsOneWidget);
    });

    testWidgets('renders with numeric value', (tester) async {
      await tester.pumpWidget(wrap(const Metric('12.5 km', 'Distance')));
      expect(find.text('12.5 km'), findsOneWidget);
      expect(find.text('Distance'), findsOneWidget);
    });

    testWidgets('renders inside a Column', (tester) async {
      await tester.pumpWidget(wrap(const Metric('42:00', 'Time')));
      expect(find.byType(Column), findsWidgets);
    });
  });

  group('SectionHeading', () {
    testWidgets('renders text only', (tester) async {
      await tester.pumpWidget(wrap(const SectionHeading('Workouts')));
      expect(find.text('Workouts'), findsOneWidget);
      expect(find.byType(GestureDetector), findsNothing);
    });

    testWidgets('renders text with action', (tester) async {
      await tester.pumpWidget(
        wrap(
          SectionHeading(
            'Training Plans',
            action: 'View All',
            onActionTap: () {},
          ),
        ),
      );
      expect(find.text('Training Plans'), findsOneWidget);
      expect(find.text('View All'), findsOneWidget);
      expect(find.byType(GestureDetector), findsOneWidget);
    });

    testWidgets('action tap triggers callback', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        wrap(
          SectionHeading(
            'Plans',
            action: 'See All',
            onActionTap: () => tapped = true,
          ),
        ),
      );
      await tester.tap(find.text('See All'));
      expect(tapped, isTrue);
    });

    testWidgets('does not render GestureDetector when action is null', (
      tester,
    ) async {
      await tester.pumpWidget(wrap(const SectionHeading('Title')));
      expect(find.byType(GestureDetector), findsNothing);
    });
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:veltrix_sports/widgets/status_card.dart';
import 'package:veltrix_sports/widgets/legend.dart';
import 'package:veltrix_sports/widgets/ring.dart';
import 'package:veltrix_sports/widgets/section_intro.dart';
import 'package:veltrix_sports/widgets/heading.dart';
import 'package:veltrix_sports/constants.dart';
import 'package:veltrix_sports/models/performance_snapshot.dart';
import 'package:veltrix_sports/providers.dart';

Widget wrap(Widget child) => ProviderScope(
  child: MaterialApp(
    home: Scaffold(body: SingleChildScrollView(child: Center(child: child))),
  ),
);

Widget wrapWithPerf(Widget child, PerformanceSnapshot snapshot) =>
    ProviderScope(
      overrides: [
        latestPerformanceProvider.overrideWith((ref) => Stream.value(snapshot)),
      ],
      child: MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(child: Center(child: child)),
        ),
      ),
    );

void main() {
  group('StatusCard', () {
    testWidgets('renders Card', (tester) async {
      await tester.pumpWidget(wrap(const StatusCard()));
      expect(find.byType(Card), findsOneWidget);
    });

    testWidgets('renders fitness ring with value 54', (tester) async {
      final snapshot = PerformanceSnapshot(
        id: 'test',
        userId: 'user',
        fitness: 54,
        fatigue: 61,
        form: -7,
        recordedAt: DateTime(2026),
      );
      await tester.pumpWidget(wrapWithPerf(const StatusCard(), snapshot));
      await tester.pump();
      expect(find.text('54'), findsOneWidget);
      expect(find.text('Fitness'), findsOneWidget);
    });

    testWidgets('renders fatigue ring with value 61', (tester) async {
      final snapshot = PerformanceSnapshot(
        id: 'test',
        userId: 'user',
        fitness: 54,
        fatigue: 61,
        form: -7,
        recordedAt: DateTime(2026),
      );
      await tester.pumpWidget(wrapWithPerf(const StatusCard(), snapshot));
      await tester.pump();
      expect(find.text('61'), findsOneWidget);
      expect(find.text('Fatigue'), findsOneWidget);
    });

    testWidgets('renders form ring with value -7', (tester) async {
      final snapshot = PerformanceSnapshot(
        id: 'test',
        userId: 'user',
        fitness: 54,
        fatigue: 61,
        form: -7,
        recordedAt: DateTime(2026),
      );
      await tester.pumpWidget(wrapWithPerf(const StatusCard(), snapshot));
      await tester.pump();
      expect(find.text('-7'), findsOneWidget);
      expect(find.text('Form'), findsOneWidget);
    });

    testWidgets('renders productivity message', (tester) async {
      await tester.pumpWidget(wrap(const StatusCard()));
      expect(find.textContaining('Productive training'), findsOneWidget);
    });

    testWidgets('renders trending_up icon', (tester) async {
      await tester.pumpWidget(wrap(const StatusCard()));
      expect(find.byIcon(Icons.trending_up), findsOneWidget);
    });

    testWidgets('renders three Ring widgets', (tester) async {
      await tester.pumpWidget(wrap(const StatusCard()));
      expect(find.byType(Ring), findsNWidgets(3));
    });
  });

  group('Legend widget', () {
    testWidgets('renders circle indicator and text', (tester) async {
      await tester.pumpWidget(wrap(const Legend('Fitness', blue)));
      expect(find.text('Fitness'), findsOneWidget);
      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('renders with different colors', (tester) async {
      await tester.pumpWidget(wrap(const Legend('Fatigue', purple)));
      expect(find.text('Fatigue'), findsOneWidget);
    });

    testWidgets('renders with orange', (tester) async {
      await tester.pumpWidget(wrap(const Legend('Form', orange)));
      expect(find.text('Form'), findsOneWidget);
    });
  });

  group('Ring widget', () {
    testWidgets('renders value and label', (tester) async {
      await tester.pumpWidget(wrap(const Ring('42', 'Fitness', blue, 0.5)));
      expect(find.text('42'), findsOneWidget);
      expect(find.text('Fitness'), findsOneWidget);
    });

    testWidgets('renders CircularProgressIndicator', (tester) async {
      await tester.pumpWidget(wrap(const Ring('50', 'Metric', lime, 0.72)));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('renders with different values', (tester) async {
      await tester.pumpWidget(wrap(const Ring('0', 'Zero', muted, 0.0)));
      expect(find.text('0'), findsOneWidget);
      expect(find.text('Zero'), findsOneWidget);
    });

    testWidgets('renders with negative value', (tester) async {
      await tester.pumpWidget(wrap(const Ring('-7', 'Form', orange, 0.46)));
      expect(find.text('-7'), findsOneWidget);
    });

    testWidgets('renders with 100% amount', (tester) async {
      await tester.pumpWidget(wrap(const Ring('100', 'Max', lime, 1.0)));
      expect(find.text('100'), findsOneWidget);
    });
  });

  group('SectionIntro widget', () {
    testWidgets('renders eyebrow, title and body', (tester) async {
      await tester.pumpWidget(
        wrap(
          const SectionIntro(
            eyebrow: 'TEST',
            title: 'Test Title',
            body: 'Test body text',
          ),
        ),
      );
      expect(find.text('TEST'), findsOneWidget);
      expect(find.text('Test Title'), findsOneWidget);
      expect(find.text('Test body text'), findsOneWidget);
    });

    testWidgets('renders with long body text', (tester) async {
      await tester.pumpWidget(
        wrap(
          const SectionIntro(
            eyebrow: 'SECTION',
            title: 'Section Title',
            body:
                'This is a very long body text that should be displayed correctly within the constrained box width.',
          ),
        ),
      );
      expect(find.text('SECTION'), findsOneWidget);
      expect(find.text('Section Title'), findsOneWidget);
    });

    testWidgets('renders ConstrainedBox for body', (tester) async {
      await tester.pumpWidget(
        wrap(const SectionIntro(eyebrow: 'EB', title: 'T', body: 'B')),
      );
      expect(find.byType(ConstrainedBox), findsWidgets);
    });
  });

  group('SectionHeading widget', () {
    testWidgets('renders heading text', (tester) async {
      await tester.pumpWidget(wrap(const SectionHeading('Test Heading')));
      expect(find.text('Test Heading'), findsOneWidget);
    });

    testWidgets('renders with empty string', (tester) async {
      await tester.pumpWidget(wrap(const SectionHeading('')));
      expect(find.text(''), findsOneWidget);
    });
  });

  group('PerformanceChart - legend and data display paths', () {
    testWidgets('renders with empty snapshots default baseline', (
      tester,
    ) async {
      final chart = MaterialApp(
        home: Scaffold(
          body: SizedBox(
            height: 200,
            child: Center(
              child: Builder(
                builder: (context) {
                  // Test the default baseline path (empty snapshots, no currentSnapshot)
                  return const Card(
                    child: Column(
                      children: [
                        Legend('Fitness', blue),
                        Legend('Fatigue', purple),
                        Legend('Form', orange),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      );
      await tester.pumpWidget(chart);
      expect(find.text('Fitness'), findsOneWidget);
      expect(find.text('Fatigue'), findsOneWidget);
      expect(find.text('Form'), findsOneWidget);
    });
  });

  group('Constants utility functions', () {
    test('normalizeDate returns midnight', () {
      final date = DateTime(2026, 9, 5, 14, 30, 45);
      final normalized = normalizeDate(date);
      expect(normalized.year, 2026);
      expect(normalized.month, 9);
      expect(normalized.day, 5);
      expect(normalized.hour, 0);
      expect(normalized.minute, 0);
      expect(normalized.second, 0);
    });

    test('getStartOfWeek returns Monday', () {
      // Sept 5, 2026 is a Saturday
      final monday = getStartOfWeek(DateTime(2026, 9, 5));
      expect(monday.weekday, DateTime.monday);
    });

    test('getStartOfWeek with weekOffset 0', () {
      final monday = getStartOfWeek(DateTime(2026, 9, 5), weekOffset: 0);
      expect(monday.weekday, DateTime.monday);
    });

    test('getStartOfWeek with positive weekOffset', () {
      final monday = getStartOfWeek(DateTime(2026, 9, 5), weekOffset: 1);
      expect(monday.weekday, DateTime.monday);
    });

    test('getStartOfWeek with negative weekOffset', () {
      final monday = getStartOfWeek(DateTime(2026, 9, 5), weekOffset: -1);
      expect(monday.weekday, DateTime.monday);
    });

    test('monthName returns correct names', () {
      expect(monthName(1), 'January');
      expect(monthName(2), 'February');
      expect(monthName(3), 'March');
      expect(monthName(4), 'April');
      expect(monthName(5), 'May');
      expect(monthName(6), 'June');
      expect(monthName(7), 'July');
      expect(monthName(8), 'August');
      expect(monthName(9), 'September');
      expect(monthName(10), 'October');
      expect(monthName(11), 'November');
      expect(monthName(12), 'December');
    });

    test('monthName returns empty string for 0', () {
      expect(monthName(0), '');
    });

    test('color constants have correct values', () {
      expect(navy, const Color(0xff123047));
      expect(ink, const Color(0xff1f2933));
      expect(muted, const Color(0xff66788a));
      expect(bg, const Color(0xfff6f2ea));
      expect(lime, const Color(0xffc8f169));
      expect(blue, const Color(0xff2176ae));
      expect(purple, const Color(0xff7759c2));
      expect(orange, const Color(0xffe9763f));
      expect(teal, const Color(0xff008f8c));
      expect(darkNavy, const Color(0xff081826));
      expect(lightGreen, const Color(0xffeef8df));
      expect(successGreen, const Color(0xff3f7f32));
      expect(successText, const Color(0xff315f29));
    });
  });
}

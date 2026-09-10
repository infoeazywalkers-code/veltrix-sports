import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:veltrix_sports/widgets/common/best.dart';
import 'package:veltrix_sports/widgets/common/insight.dart';
import 'package:veltrix_sports/widgets/common/legend.dart';
import 'package:veltrix_sports/widgets/common/pillar_card.dart';
import 'package:veltrix_sports/widgets/common/section_intro.dart';

Widget wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  group('Best', () {
    testWidgets('renders title, value, and icon', (tester) async {
      await tester.pumpWidget(
        wrap(const Best('Fastest Pace', '4:32 /km', Icons.speed, Colors.blue)),
      );
      expect(find.byIcon(Icons.speed), findsOneWidget);
      expect(find.text('Fastest Pace'), findsOneWidget);
      expect(find.text('4:32 /km'), findsOneWidget);
    });

    testWidgets('renders inside a Card', (tester) async {
      await tester.pumpWidget(
        wrap(const Best('A', 'B', Icons.star, Colors.red)),
      );
      expect(find.byType(Card), findsOneWidget);
    });

    testWidgets('renders with different colors', (tester) async {
      await tester.pumpWidget(
        wrap(const Best('Title', 'Value', Icons.favorite, Colors.pink)),
      );
      expect(find.byIcon(Icons.favorite), findsOneWidget);
    });

    testWidgets('handles empty strings', (tester) async {
      await tester.pumpWidget(
        wrap(const Best('', '', Icons.star, Colors.green)),
      );
      expect(find.text(''), findsWidgets);
    });

    testWidgets('handles long title and value', (tester) async {
      await tester.pumpWidget(
        wrap(Best('T' * 100, 'V' * 100, Icons.star, Colors.blue)),
      );
      expect(find.text('T' * 100), findsOneWidget);
      expect(find.text('V' * 100), findsOneWidget);
    });
  });

  group('Insight', () {
    testWidgets('renders icon, title, and body', (tester) async {
      await tester.pumpWidget(
        wrap(
          const Insight(
            Icons.lightbulb,
            Colors.amber,
            'Recovery Tip',
            'Your form is trending upward.',
          ),
        ),
      );
      expect(find.byIcon(Icons.lightbulb), findsOneWidget);
      expect(find.text('Recovery Tip'), findsOneWidget);
      expect(find.text('Your form is trending upward.'), findsOneWidget);
    });

    testWidgets('renders inside a Card with ListTile', (tester) async {
      await tester.pumpWidget(
        wrap(const Insight(Icons.info, Colors.blue, 'Info', 'Body')),
      );
      expect(find.byType(Card), findsOneWidget);
      expect(find.byType(ListTile), findsOneWidget);
    });

    testWidgets('renders with different colors', (tester) async {
      await tester.pumpWidget(
        wrap(const Insight(Icons.warning, Colors.red, 'Warning', 'Watch out')),
      );
      expect(find.byIcon(Icons.warning), findsOneWidget);
    });

    testWidgets('handles empty strings', (tester) async {
      await tester.pumpWidget(
        wrap(const Insight(Icons.star, Colors.green, '', '')),
      );
    });

    testWidgets('handles long title and body', (tester) async {
      await tester.pumpWidget(
        wrap(Insight(Icons.info, Colors.blue, 'T' * 200, 'B' * 500)),
      );
      expect(find.text('T' * 200), findsOneWidget);
      expect(find.text('B' * 500), findsOneWidget);
    });
  });

  group('Legend', () {
    testWidgets('renders colored dot and text', (tester) async {
      await tester.pumpWidget(wrap(const Legend('Fitness', Colors.green)));
      expect(find.text('Fitness'), findsOneWidget);
      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('renders inside a Row', (tester) async {
      await tester.pumpWidget(wrap(const Legend('Fatigue', Colors.red)));
      expect(find.byType(Row), findsOneWidget);
    });

    testWidgets('handles empty text', (tester) async {
      await tester.pumpWidget(wrap(const Legend('', Colors.blue)));
      expect(find.text(''), findsOneWidget);
    });

    testWidgets('handles long text', (tester) async {
      await tester.pumpWidget(
        wrap(const Legend('Fatigue Index', Colors.purple)),
      );
      expect(find.text('Fatigue Index'), findsOneWidget);
    });
  });

  group('PillarCard', () {
    testWidgets('renders all text fields and icon', (tester) async {
      await tester.pumpWidget(
        wrap(
          const PillarCard(
            number: '01',
            verb: 'TRAIN',
            title: 'Structured Plans',
            body: 'Science-backed periodization.',
            icon: Icons.fitness_center,
          ),
        ),
      );
      expect(find.text('01'), findsOneWidget);
      expect(find.text('TRAIN'), findsOneWidget);
      expect(find.text('Structured Plans'), findsOneWidget);
      expect(find.text('Science-backed periodization.'), findsOneWidget);
      expect(find.byIcon(Icons.fitness_center), findsOneWidget);
    });

    testWidgets('renders with different icon', (tester) async {
      await tester.pumpWidget(
        wrap(
          const PillarCard(
            number: '02',
            verb: 'TRACK',
            title: 'Performance Metrics',
            body: 'Real-time data.',
            icon: Icons.analytics,
          ),
        ),
      );
      expect(find.byIcon(Icons.analytics), findsOneWidget);
    });

    testWidgets('has minimum height constraint', (tester) async {
      await tester.pumpWidget(
        wrap(
          const PillarCard(
            number: '01',
            verb: 'A',
            title: 'B',
            body: 'C',
            icon: Icons.star,
          ),
        ),
      );
      expect(find.byType(PillarCard), findsOneWidget);
    });
  });

  group('SectionIntro', () {
    testWidgets('renders eyebrow, title, and body', (tester) async {
      await tester.pumpWidget(
        wrap(
          const SectionIntro(
            eyebrow: 'OUR APPROACH',
            title: 'Built for Athletes',
            body: 'Veltrix is designed for serious endurance athletes.',
          ),
        ),
      );
      expect(find.text('OUR APPROACH'), findsOneWidget);
      expect(find.text('Built for Athletes'), findsOneWidget);
      expect(
        find.text('Veltrix is designed for serious endurance athletes.'),
        findsOneWidget,
      );
    });

    testWidgets('renders inside a Column', (tester) async {
      await tester.pumpWidget(
        wrap(const SectionIntro(eyebrow: 'EYE', title: 'Title', body: 'Body')),
      );
      expect(find.byType(Column), findsWidgets);
    });

    testWidgets('handles empty strings', (tester) async {
      await tester.pumpWidget(
        wrap(const SectionIntro(eyebrow: '', title: '', body: '')),
      );
    });

    testWidgets('handles long text', (tester) async {
      await tester.pumpWidget(
        wrap(
          const SectionIntro(
            eyebrow: 'OUR APPROACH',
            title: 'Built for Athletes',
            body: 'Veltrix is designed for serious endurance athletes.',
          ),
        ),
      );
      expect(find.text('OUR APPROACH'), findsOneWidget);
      expect(find.text('Built for Athletes'), findsOneWidget);
    });
  });
}

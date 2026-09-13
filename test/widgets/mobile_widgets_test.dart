import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:veltrix_sports/mobile/widgets/mobile_card.dart';
import 'package:veltrix_sports/mobile/widgets/mobile_section.dart';
import 'package:veltrix_sports/mobile/widgets/mobile_stat_ring.dart';
import 'package:veltrix_sports/mobile/widgets/mobile_workout_card.dart';

void main() {
  Widget wrap(Widget child) => MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(child: Center(child: child)),
    ),
  );

  Widget wrapFull(Widget child) => MaterialApp(home: Scaffold(body: child));

  group('MCard', () {
    testWidgets('renders child content', (tester) async {
      await tester.pumpWidget(wrap(const MCard(child: Text('Hello Card'))));
      expect(find.text('Hello Card'), findsOneWidget);
      expect(find.byType(Card), findsOneWidget);
    });

    testWidgets('renders with custom padding', (tester) async {
      await tester.pumpWidget(
        wrap(const MCard(padding: EdgeInsets.all(32), child: Text('Padded'))),
      );
      expect(find.text('Padded'), findsOneWidget);
    });

    testWidgets('renders with custom color', (tester) async {
      await tester.pumpWidget(
        wrap(const MCard(color: Colors.red, child: Text('Colored'))),
      );
      final card = tester.widget<Card>(find.byType(Card));
      expect(card.color, Colors.red);
    });

    testWidgets('renders with onTap as InkWell', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        wrap(MCard(onTap: () => tapped = true, child: const Text('Tappable'))),
      );
      expect(find.byType(InkWell), findsOneWidget);
      await tester.tap(find.byType(InkWell));
      expect(tapped, isTrue);
    });

    testWidgets('renders without InkWell when onTap is null', (tester) async {
      await tester.pumpWidget(wrap(const MCard(child: Text('Not tappable'))));
      expect(find.byType(InkWell), findsNothing);
    });
  });

  group('MInfoCard', () {
    testWidgets('renders icon, title and subtitle', (tester) async {
      await tester.pumpWidget(
        wrap(
          const MInfoCard(
            icon: Icons.star,
            iconColor: Colors.blue,
            title: 'My Feature',
            subtitle: 'Description text',
          ),
        ),
      );
      expect(find.byIcon(Icons.star), findsOneWidget);
      expect(find.text('My Feature'), findsOneWidget);
      expect(find.text('Description text'), findsOneWidget);
    });

    testWidgets('renders without subtitle when null', (tester) async {
      await tester.pumpWidget(
        wrap(
          const MInfoCard(
            icon: Icons.star,
            iconColor: Colors.blue,
            title: 'No Subtitle',
          ),
        ),
      );
      expect(find.text('No Subtitle'), findsOneWidget);
      expect(find.byType(Card), findsOneWidget);
    });

    testWidgets('renders trailing widget', (tester) async {
      await tester.pumpWidget(
        wrap(
          const MInfoCard(
            icon: Icons.star,
            iconColor: Colors.blue,
            title: 'With Trailing',
            trailing: Icon(Icons.arrow_forward),
          ),
        ),
      );
      expect(find.byIcon(Icons.arrow_forward), findsOneWidget);
    });

    testWidgets('renders chevron when onTap is provided', (tester) async {
      await tester.pumpWidget(
        wrap(
          MInfoCard(
            icon: Icons.star,
            iconColor: Colors.blue,
            title: 'With Action',
            onTap: () {},
          ),
        ),
      );
      expect(find.byIcon(Icons.chevron_right), findsOneWidget);
    });

    testWidgets('does not render chevron when onTap is null', (tester) async {
      await tester.pumpWidget(
        wrap(
          const MInfoCard(
            icon: Icons.star,
            iconColor: Colors.blue,
            title: 'No Action',
          ),
        ),
      );
      expect(find.byIcon(Icons.chevron_right), findsNothing);
    });

    testWidgets('onTap triggers callback', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        wrap(
          MInfoCard(
            icon: Icons.star,
            iconColor: Colors.blue,
            title: 'Tap Me',
            onTap: () => tapped = true,
          ),
        ),
      );
      await tester.tap(find.byType(InkWell));
      expect(tapped, isTrue);
    });
  });

  group('MBanner', () {
    testWidgets('renders child with background color', (tester) async {
      await tester.pumpWidget(
        wrap(
          const MBanner(
            backgroundColor: Colors.green,
            child: Text('Banner Content'),
          ),
        ),
      );
      expect(find.text('Banner Content'), findsOneWidget);
      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('renders as tappable with InkWell when onTap provided', (
      tester,
    ) async {
      var tapped = false;
      await tester.pumpWidget(
        wrap(
          MBanner(
            backgroundColor: Colors.blue,
            onTap: () => tapped = true,
            child: const Text('Tap Banner'),
          ),
        ),
      );
      expect(find.byType(InkWell), findsOneWidget);
      await tester.tap(find.byType(InkWell));
      expect(tapped, isTrue);
    });

    testWidgets('renders without InkWell when onTap is null', (tester) async {
      await tester.pumpWidget(
        wrap(
          const MBanner(
            backgroundColor: Colors.blue,
            child: Text('Static Banner'),
          ),
        ),
      );
      expect(find.byType(InkWell), findsNothing);
    });

    testWidgets('renders with custom padding', (tester) async {
      await tester.pumpWidget(
        wrap(
          const MBanner(
            backgroundColor: Colors.red,
            padding: EdgeInsets.all(32),
            child: Text('Custom Padding'),
          ),
        ),
      );
      expect(find.text('Custom Padding'), findsOneWidget);
    });
  });

  group('MGradientBanner', () {
    testWidgets('renders child with gradient', (tester) async {
      await tester.pumpWidget(
        wrap(
          const MGradientBanner(
            colors: [Colors.blue, Colors.purple],
            child: Text('Gradient Content'),
          ),
        ),
      );
      expect(find.text('Gradient Content'), findsOneWidget);
    });

    testWidgets('renders with custom padding', (tester) async {
      await tester.pumpWidget(
        wrap(
          const MGradientBanner(
            colors: [Colors.red, Colors.orange],
            padding: EdgeInsets.all(40),
            child: Text('Custom Gradient'),
          ),
        ),
      );
      expect(find.text('Custom Gradient'), findsOneWidget);
    });
  });

  group('MSection', () {
    testWidgets('renders title and child', (tester) async {
      await tester.pumpWidget(
        wrapFull(
          const MSection(title: 'My Section', child: Text('Section Content')),
        ),
      );
      expect(find.text('My Section'), findsOneWidget);
      expect(find.text('Section Content'), findsOneWidget);
    });

    testWidgets('renders action when provided', (tester) async {
      await tester.pumpWidget(
        wrapFull(
          MSection(
            title: 'With Action',
            action: 'See All',
            onActionTap: () {},
            child: const Text('Content'),
          ),
        ),
      );
      expect(find.text('See All'), findsOneWidget);
      expect(find.byType(GestureDetector), findsWidgets);
    });

    testWidgets('does not render action when null', (tester) async {
      await tester.pumpWidget(
        wrapFull(const MSection(title: 'No Action', child: Text('Content'))),
      );
      expect(find.text('See All'), findsNothing);
    });

    testWidgets('action tap triggers callback', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        wrapFull(
          MSection(
            title: 'Section',
            action: 'More',
            onActionTap: () => tapped = true,
            child: const Text('Content'),
          ),
        ),
      );
      // Find the GestureDetector wrapping the action text
      await tester.tap(find.text('More'));
      expect(tapped, isTrue);
    });
  });

  group('MSectionIntro', () {
    testWidgets('renders eyebrow, title and body', (tester) async {
      await tester.pumpWidget(
        wrapFull(
          const MSectionIntro(
            eyebrow: 'FEATURE',
            title: 'Amazing Feature',
            body: 'This feature helps you train better.',
          ),
        ),
      );
      expect(find.text('FEATURE'), findsOneWidget);
      expect(find.text('Amazing Feature'), findsOneWidget);
      expect(find.text('This feature helps you train better.'), findsOneWidget);
    });
  });

  group('MDivider', () {
    testWidgets('renders plain Divider when label is null', (tester) async {
      await tester.pumpWidget(wrapFull(const MDivider()));
      expect(find.byType(Divider), findsOneWidget);
    });

    testWidgets('renders with label when provided', (tester) async {
      await tester.pumpWidget(wrapFull(const MDivider(label: 'OR')));
      expect(find.text('OR'), findsOneWidget);
      expect(find.byType(Divider), findsWidgets);
    });
  });

  group('MStatRing', () {
    testWidgets('renders value, label and CircularProgressIndicator', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrap(
          const MStatRing(
            value: '54',
            label: 'Fitness',
            color: Colors.blue,
            progress: 0.72,
          ),
        ),
      );
      expect(find.text('54'), findsOneWidget);
      expect(find.text('Fitness'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('renders with custom size', (tester) async {
      await tester.pumpWidget(
        wrap(
          const MStatRing(
            value: '61',
            label: 'Fatigue',
            color: Colors.purple,
            progress: 0.81,
            size: 96,
          ),
        ),
      );
      expect(find.text('61'), findsOneWidget);
      expect(find.text('Fatigue'), findsOneWidget);
    });

    testWidgets('renders with zero progress', (tester) async {
      await tester.pumpWidget(
        wrap(
          const MStatRing(
            value: '0',
            label: 'Rest',
            color: Colors.grey,
            progress: 0.0,
          ),
        ),
      );
      expect(find.text('0'), findsOneWidget);
      expect(find.text('Rest'), findsOneWidget);
    });
  });

  group('MWorkoutCard', () {
    testWidgets('renders sport, title and details', (tester) async {
      await tester.pumpWidget(
        wrap(
          const MWorkoutCard(
            sport: 'RUNNING',
            title: 'Easy Recovery',
            details: '35 min • 5.2 km',
            color: Colors.blue,
            icon: Icons.directions_run,
          ),
        ),
      );
      expect(find.text('RUNNING'), findsOneWidget);
      expect(find.text('Easy Recovery'), findsOneWidget);
      expect(find.text('35 min • 5.2 km'), findsOneWidget);
      expect(find.byIcon(Icons.directions_run), findsOneWidget);
    });

    testWidgets('renders progress bar when progress > 0', (tester) async {
      await tester.pumpWidget(
        wrap(
          const MWorkoutCard(
            sport: 'CYCLING',
            title: 'Endurance Spin',
            details: '1h 45 min',
            color: Colors.orange,
            icon: Icons.pedal_bike,
            progress: 0.68,
          ),
        ),
      );
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
    });

    testWidgets('does not render progress bar when progress is 0', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrap(
          const MWorkoutCard(
            sport: 'STRENGTH',
            title: 'Core Session',
            details: '30 min',
            color: Colors.teal,
            icon: Icons.fitness_center,
          ),
        ),
      );
      expect(find.byType(LinearProgressIndicator), findsNothing);
    });

    testWidgets('renders chevron icon', (tester) async {
      await tester.pumpWidget(
        wrap(
          const MWorkoutCard(
            sport: 'SWIMMING',
            title: 'Pool Laps',
            details: '45 min',
            color: Colors.cyan,
            icon: Icons.pool,
          ),
        ),
      );
      expect(find.byIcon(Icons.chevron_right), findsOneWidget);
    });

    testWidgets('onTap triggers callback', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        wrap(
          MWorkoutCard(
            sport: 'RUN',
            title: 'Sprint',
            details: '20 min',
            color: Colors.red,
            icon: Icons.directions_run,
            onTap: () => tapped = true,
          ),
        ),
      );
      await tester.tap(find.byType(InkWell));
      expect(tapped, isTrue);
    });
  });
}

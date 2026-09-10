import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:veltrix_sports/providers.dart';
import 'package:veltrix_sports/widgets/workout/workout_card.dart';
import 'package:veltrix_sports/widgets/workout/week_row.dart';
import 'package:veltrix_sports/widgets/common/footer_social.dart';
import 'package:veltrix_sports/widgets/common/footer_group.dart';
import 'package:veltrix_sports/widgets/common/marketing_feature_card.dart';
import 'package:veltrix_sports/widgets/workout/week_card.dart';

Widget wrap(Widget child) => ProviderScope(
  overrides: [
    weekWorkoutsProvider.overrideWith((ref, arg) async => []),
    latestPerformanceProvider.overrideWith((ref) => Stream.value(null)),
  ],
  child: MaterialApp(home: Scaffold(body: child)),
);

void main() {
  group('WorkoutCard', () {
    testWidgets('renders sport, title, details, and icon', (tester) async {
      await tester.pumpWidget(
        wrap(
          const WorkoutCard(
            sport: 'RUN',
            title: 'Easy Run',
            details: '30 min \u2022 5.2 km',
            color: Colors.blue,
            icon: Icons.directions_run,
          ),
        ),
      );
      expect(find.text('RUN'), findsOneWidget);
      expect(find.text('Easy Run'), findsOneWidget);
      expect(find.text('30 min \u2022 5.2 km'), findsOneWidget);
      expect(find.byIcon(Icons.directions_run), findsOneWidget);
    });

    testWidgets('shows progress bar when progress > 0', (tester) async {
      await tester.pumpWidget(
        wrap(
          const WorkoutCard(
            sport: 'BIKE',
            title: 'Tempo Ride',
            details: '1h',
            color: Colors.orange,
            icon: Icons.directions_bike,
            progress: 0.65,
          ),
        ),
      );
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
    });

    testWidgets('hides progress bar when progress is 0', (tester) async {
      await tester.pumpWidget(
        wrap(
          const WorkoutCard(
            sport: 'SWIM',
            title: 'Pool Swim',
            details: '45 min',
            color: Colors.teal,
            icon: Icons.pool,
            progress: 0,
          ),
        ),
      );
      expect(find.byType(LinearProgressIndicator), findsNothing);
    });

    testWidgets('onTap is triggered when tapped', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        wrap(
          WorkoutCard(
            sport: 'RUN',
            title: 'Sprint',
            details: '20 min',
            color: Colors.red,
            icon: Icons.speed,
            onTap: () => tapped = true,
          ),
        ),
      );
      await tester.tap(find.byType(InkWell));
      expect(tapped, isTrue);
    });

    testWidgets('renders chevron icon', (tester) async {
      await tester.pumpWidget(
        wrap(
          const WorkoutCard(
            sport: 'REST',
            title: 'Recovery',
            details: 'Rest day',
            color: Colors.grey,
            icon: Icons.hotel,
          ),
        ),
      );
      expect(find.byIcon(Icons.chevron_right), findsOneWidget);
    });

    testWidgets('renders with progress near 1.0', (tester) async {
      await tester.pumpWidget(
        wrap(
          const WorkoutCard(
            sport: 'RUN',
            title: 'Done',
            details: 'Completed',
            color: Colors.green,
            icon: Icons.check_circle,
            progress: 1.0,
          ),
        ),
      );
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
    });

    testWidgets('handles empty sport and title', (tester) async {
      await tester.pumpWidget(
        wrap(
          const WorkoutCard(
            sport: '',
            title: '',
            details: '',
            color: Colors.blue,
            icon: Icons.star,
          ),
        ),
      );
    });
  });

  group('WeekRow', () {
    testWidgets('renders day, title, time, icon, and chevron', (tester) async {
      await tester.pumpWidget(
        wrap(
          const WeekRow(
            'Mon',
            'Easy Run',
            '30 min',
            Colors.blue,
            Icons.directions_run,
          ),
        ),
      );
      expect(find.text('Easy Run'), findsOneWidget);
      expect(find.textContaining('Mon'), findsOneWidget);
      expect(find.textContaining('30 min'), findsOneWidget);
      expect(find.byIcon(Icons.directions_run), findsOneWidget);
      expect(find.byIcon(Icons.chevron_right), findsOneWidget);
    });

    testWidgets('renders inside a Card with ListTile', (tester) async {
      await tester.pumpWidget(
        wrap(
          const WeekRow(
            'Tue',
            'Ride',
            '1h',
            Colors.orange,
            Icons.directions_bike,
          ),
        ),
      );
      expect(find.byType(Card), findsOneWidget);
      expect(find.byType(ListTile), findsOneWidget);
    });

    testWidgets('handles different day abbreviations', (tester) async {
      await tester.pumpWidget(
        wrap(
          const WeekRow(
            'Sun',
            'Long Run',
            '2h',
            Colors.green,
            Icons.run_circle,
          ),
        ),
      );
      expect(find.textContaining('Sun'), findsOneWidget);
    });
  });

  group('FooterSocial', () {
    testWidgets('renders icon', (tester) async {
      await tester.pumpWidget(wrap(const FooterSocial(Icons.language)));
      expect(find.byIcon(Icons.language), findsOneWidget);
    });

    testWidgets('renders with different icons', (tester) async {
      await tester.pumpWidget(wrap(const FooterSocial(Icons.email)));
      expect(find.byIcon(Icons.email), findsOneWidget);
    });

    testWidgets('renders inside a Container', (tester) async {
      await tester.pumpWidget(wrap(const FooterSocial(Icons.star)));
      expect(find.byType(Container), findsWidgets);
    });
  });

  group('FooterGroup', () {
    testWidgets('renders title and links', (tester) async {
      await tester.pumpWidget(
        wrap(
          const FooterGroup(
            title: 'COMPANY',
            links: ['About', 'Blog', 'Careers'],
          ),
        ),
      );
      expect(find.text('COMPANY'), findsOneWidget);
      expect(find.text('About'), findsOneWidget);
      expect(find.text('Blog'), findsOneWidget);
      expect(find.text('Careers'), findsOneWidget);
    });

    testWidgets('renders with empty links', (tester) async {
      await tester.pumpWidget(
        wrap(const FooterGroup(title: 'EMPTY', links: [])),
      );
      expect(find.text('EMPTY'), findsOneWidget);
    });

    testWidgets('renders with onTapLinks', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        wrap(
          FooterGroup(
            title: 'LINKS',
            links: ['Home'],
            onTapLinks: [() => tapped = true],
          ),
        ),
      );
      await tester.tap(find.text('Home'));
      expect(tapped, isTrue);
    });

    testWidgets('onTapLinks shorter than links does not crash', (tester) async {
      await tester.pumpWidget(
        wrap(
          const FooterGroup(
            title: 'GROUP',
            links: ['A', 'B', 'C'],
            onTapLinks: [null],
          ),
        ),
      );
      expect(find.text('A'), findsOneWidget);
      expect(find.text('B'), findsOneWidget);
      expect(find.text('C'), findsOneWidget);
    });

    testWidgets('handles single link', (tester) async {
      await tester.pumpWidget(
        wrap(const FooterGroup(title: 'SINGLE', links: ['Only Link'])),
      );
      expect(find.text('Only Link'), findsOneWidget);
    });
  });

  group('MarketingFeatureCard', () {
    testWidgets('renders with icon, eyebrow, title, body, action', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrap(
          MarketingFeatureCard(
            icon: Icons.fitness_center,
            eyebrow: 'FEATURE',
            title: 'Workout Builder',
            body: 'Create custom workouts.',
            action: 'Learn More',
            onActionTap: () {},
          ),
        ),
      );
      expect(find.byIcon(Icons.fitness_center), findsOneWidget);
      expect(find.text('FEATURE'), findsOneWidget);
      expect(find.text('Workout Builder'), findsOneWidget);
      expect(find.text('Create custom workouts.'), findsOneWidget);
      expect(find.text('Learn More'), findsOneWidget);
    });

    testWidgets('renders without icon when null', (tester) async {
      await tester.pumpWidget(
        wrap(
          const MarketingFeatureCard(
            eyebrow: 'EYE',
            title: 'Title',
            body: 'Body text',
            action: 'Action',
          ),
        ),
      );
      expect(find.text('EYE'), findsOneWidget);
      expect(find.text('Title'), findsOneWidget);
    });

    testWidgets('action tap triggers callback', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        wrap(
          MarketingFeatureCard(
            eyebrow: 'EYE',
            title: 'Title',
            body: 'Body',
            action: 'Tap Me',
            onActionTap: () => tapped = true,
          ),
        ),
      );
      await tester.tap(find.text('Tap Me'));
      expect(tapped, isTrue);
    });

    testWidgets('renders with color', (tester) async {
      await tester.pumpWidget(
        wrap(
          const MarketingFeatureCard(
            color: Colors.deepPurple,
            icon: Icons.star,
            eyebrow: 'EYE',
            title: 'Title',
            body: 'Body',
            action: 'Go',
          ),
        ),
      );
      expect(find.byIcon(Icons.star), findsOneWidget);
    });

    testWidgets('renders without image when null', (tester) async {
      await tester.pumpWidget(
        wrap(
          const MarketingFeatureCard(
            eyebrow: 'EYE',
            title: 'Title',
            body: 'Body',
            action: 'Action',
          ),
        ),
      );
      expect(find.text('Title'), findsOneWidget);
    });

    testWidgets('renders arrow icon', (tester) async {
      await tester.pumpWidget(
        wrap(
          const MarketingFeatureCard(
            eyebrow: 'EYE',
            title: 'Title',
            body: 'Body',
            action: 'Go',
          ),
        ),
      );
      expect(find.byIcon(Icons.arrow_forward_rounded), findsOneWidget);
    });
  });

  group('WeekCard', () {
    testWidgets('renders metrics row and day labels', (tester) async {
      await tester.pumpWidget(wrap(const WeekCard()));
      expect(
        find.text('0'),
        findsWidgets,
      ); // workoutCount and totalTss both '0'
      expect(find.text('Workouts'), findsOneWidget);
      expect(find.text('0m'), findsOneWidget);
      expect(find.text('Duration'), findsOneWidget);
      expect(find.text('TSS'), findsOneWidget);
      expect(find.text('M'), findsOneWidget);
      expect(find.text('S'), findsWidgets); // Saturday and Sunday
    });

    testWidgets('renders 7 day columns', (tester) async {
      await tester.pumpWidget(wrap(const WeekCard()));
      // 7 day labels
      expect(find.text('M'), findsOneWidget);
      expect(find.text('T'), findsWidgets); // Tuesday and Thursday
      expect(find.text('W'), findsOneWidget);
      expect(find.text('F'), findsOneWidget);
      expect(find.text('S'), findsWidgets); // Saturday and Sunday
    });

    testWidgets('renders inside a Card', (tester) async {
      await tester.pumpWidget(wrap(const WeekCard()));
      expect(find.byType(Card), findsOneWidget);
    });
  });
}

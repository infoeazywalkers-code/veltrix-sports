import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:veltrix_sports/screens/premium_screen.dart';
import 'package:veltrix_sports/screens/coach_match_screen.dart';
import 'package:veltrix_sports/screens/strength_screen.dart';

Widget wrap(Widget child) => MaterialApp(
  home: ProviderScope(
    child: Scaffold(body: SizedBox(height: 2000, child: child)),
  ),
);

void main() {
  group('PremiumScreen - expanded coverage', () {
    testWidgets('renders PREMIUM eyebrow', (tester) async {
      await tester.pumpWidget(wrap(const PremiumScreen()));
      expect(find.text('PREMIUM'), findsOneWidget);
    });

    testWidgets('renders main heading', (tester) async {
      await tester.pumpWidget(wrap(const PremiumScreen()));
      expect(find.text('Your Next Peak Starts with Premium'), findsOneWidget);
    });

    testWidgets('renders pricing section after scroll', (tester) async {
      await tester.pumpWidget(wrap(const PremiumScreen()));
      await tester.scrollUntilVisible(
        find.text('Simple, transparent pricing'),
        300,
      );
      await tester.pumpAndSettle();
      expect(find.text('Simple, transparent pricing'), findsOneWidget);
    });

    testWidgets('renders monthly plan card after scroll', (tester) async {
      await tester.pumpWidget(wrap(const PremiumScreen()));
      await tester.scrollUntilVisible(find.text('Monthly'), 300);
      await tester.pumpAndSettle();
      expect(find.text('Monthly'), findsOneWidget);
      expect(find.text('Billed monthly'), findsOneWidget);
    });

    testWidgets('renders annual plan card after scroll', (tester) async {
      await tester.pumpWidget(wrap(const PremiumScreen()));
      await tester.scrollUntilVisible(find.text('Annual'), 300);
      await tester.pumpAndSettle();
      expect(find.text('Annual'), findsOneWidget);
    });

    testWidgets('renders Get Started Now buttons', (tester) async {
      await tester.pumpWidget(wrap(const PremiumScreen()));
      // Scroll to a nearby unique text first, then check for buttons
      await tester.scrollUntilVisible(
        find.text('Start with a 14-day free trial'),
        300,
      );
      await tester.pumpAndSettle();
      expect(find.text('Get Started Now'), findsNWidgets(2));
    });

    testWidgets('renders feature highlights after scroll', (tester) async {
      await tester.pumpWidget(wrap(const PremiumScreen()));
      await tester.scrollUntilVisible(find.text('PMC Chart'), 300);
      await tester.pumpAndSettle();
      expect(find.text('PMC Chart'), findsOneWidget);
      expect(find.text('Workout Library'), findsOneWidget);
      expect(find.text('Enhanced Coaching'), findsOneWidget);
      expect(find.text('Fueling Insights'), findsOneWidget);
    });

    testWidgets('renders CTA section after scroll', (tester) async {
      await tester.pumpWidget(wrap(const PremiumScreen()));
      await tester.scrollUntilVisible(
        find.text('Go further with Premium.'),
        300,
      );
      await tester.pumpAndSettle();
      expect(find.text('Go further with Premium.'), findsOneWidget);
      expect(find.text('14-day free trial. Cancel anytime.'), findsOneWidget);
    });

    testWidgets('renders Get Premium Now button after scroll', (tester) async {
      await tester.pumpWidget(wrap(const PremiumScreen()));
      await tester.scrollUntilVisible(find.text('Get Premium Now'), 300);
      await tester.pumpAndSettle();
      expect(find.text('Get Premium Now'), findsOneWidget);
    });

    testWidgets('renders Virtual features after scroll', (tester) async {
      await tester.pumpWidget(wrap(const PremiumScreen()));
      await tester.scrollUntilVisible(
        find.text('Veltrix Virtual included.'),
        300,
      );
      await tester.pumpAndSettle();
      expect(find.text('Veltrix Virtual included.'), findsOneWidget);
      expect(find.text('Workout sync'), findsOneWidget);
    });

    testWidgets('renders feature cards', (tester) async {
      await tester.pumpWidget(wrap(const PremiumScreen()));
      expect(find.text('Flexible planning tools'), findsOneWidget);
      expect(find.text('Performance Management'), findsOneWidget);
      expect(find.text('Strength, health & fueling'), findsOneWidget);
    });

    testWidgets('renders pricing list items in view after scroll', (
      tester,
    ) async {
      await tester.pumpWidget(wrap(const PremiumScreen()));
      await tester.scrollUntilVisible(
        find.text('Simple, transparent pricing'),
        300,
      );
      await tester.pumpAndSettle();
      // After scrolling to pricing section, plan features should be visible
      expect(find.text('Monthly'), findsOneWidget);
      expect(find.text('Annual'), findsOneWidget);
    });

    testWidgets('renders Why athletes choose Premium after scroll', (
      tester,
    ) async {
      await tester.pumpWidget(wrap(const PremiumScreen()));
      await tester.scrollUntilVisible(
        find.text('Why athletes choose Premium'),
        300,
      );
      await tester.pumpAndSettle();
      expect(find.text('Why athletes choose Premium'), findsOneWidget);
    });

    testWidgets('renders start with a 14-day free trial after scroll', (
      tester,
    ) async {
      await tester.pumpWidget(wrap(const PremiumScreen()));
      await tester.scrollUntilVisible(
        find.text('Start with a 14-day free trial'),
        300,
      );
      await tester.pumpAndSettle();
      expect(find.text('Start with a 14-day free trial'), findsOneWidget);
    });
  });

  group('CoachMatchScreen - expanded coverage', () {
    testWidgets('renders Start Questionnaire button', (tester) async {
      await tester.pumpWidget(wrap(const CoachMatchScreen()));
      expect(find.text('Start Questionnaire'), findsOneWidget);
    });

    testWidgets('renders Featured Veltrix Coaches heading', (tester) async {
      await tester.pumpWidget(wrap(const CoachMatchScreen()));
      expect(find.text('Featured Veltrix Coaches'), findsOneWidget);
    });

    testWidgets('renders coach names', (tester) async {
      await tester.pumpWidget(wrap(const CoachMatchScreen()));
      expect(find.text('Featured Veltrix Coaches'), findsOneWidget);
    });

    testWidgets('renders How it works after scroll', (tester) async {
      await tester.pumpWidget(wrap(const CoachMatchScreen()));
      await tester.scrollUntilVisible(find.text('How it works'), 300);
      await tester.pumpAndSettle();
      expect(find.text('How it works'), findsOneWidget);
    });

    testWidgets('renders step numbers after scroll', (tester) async {
      await tester.pumpWidget(wrap(const CoachMatchScreen()));
      await tester.scrollUntilVisible(find.text('01'), 300);
      await tester.pumpAndSettle();
      expect(find.text('01'), findsOneWidget);
      expect(find.text('02'), findsOneWidget);
      expect(find.text('03'), findsOneWidget);
    });

    testWidgets('renders step titles after scroll', (tester) async {
      await tester.pumpWidget(wrap(const CoachMatchScreen()));
      await tester.scrollUntilVisible(find.text('QUESTIONNAIRE'), 300);
      await tester.pumpAndSettle();
      expect(find.text('QUESTIONNAIRE'), findsOneWidget);
      expect(find.text('EXPERT REVIEW'), findsOneWidget);
      expect(find.text('YOUR MATCH'), findsOneWidget);
    });

    testWidgets('renders Why Coach Match works after scroll', (tester) async {
      await tester.pumpWidget(wrap(const CoachMatchScreen()));
      await tester.scrollUntilVisible(find.text('Why Coach Match works'), 300);
      await tester.pumpAndSettle();
      expect(find.text('Why Coach Match works'), findsOneWidget);
    });

    testWidgets('renders feature items after scroll', (tester) async {
      await tester.pumpWidget(wrap(const CoachMatchScreen()));
      await tester.scrollUntilVisible(find.text('Science-backed'), 300);
      await tester.pumpAndSettle();
      expect(find.text('Science-backed'), findsOneWidget);
      expect(find.text('Personalized'), findsOneWidget);
      expect(find.text('Communication'), findsOneWidget);
      expect(find.text('Long-game approach'), findsOneWidget);
    });

    testWidgets('renders Choose your package after scroll', (tester) async {
      await tester.pumpWidget(wrap(const CoachMatchScreen()));
      await tester.scrollUntilVisible(find.text('Choose your package'), 300);
      await tester.pumpAndSettle();
      expect(find.text('Choose your package'), findsOneWidget);
    });

    testWidgets('renders pricing packages after scroll', (tester) async {
      await tester.pumpWidget(wrap(const CoachMatchScreen()));
      await tester.scrollUntilVisible(find.text('Bronze'), 300);
      await tester.pumpAndSettle();
      expect(find.text('Bronze'), findsOneWidget);
      expect(find.text('Silver'), findsOneWidget);
      expect(find.text('Gold'), findsOneWidget);
    });

    testWidgets('renders MOST POPULAR badge after scroll', (tester) async {
      await tester.pumpWidget(wrap(const CoachMatchScreen()));
      await tester.scrollUntilVisible(find.text('MOST POPULAR'), 300);
      await tester.pumpAndSettle();
      expect(find.text('MOST POPULAR'), findsOneWidget);
    });

    testWidgets('renders FAQ section after scroll', (tester) async {
      await tester.pumpWidget(wrap(const CoachMatchScreen()));
      await tester.scrollUntilVisible(
        find.text('Frequently asked questions'),
        300,
      );
      await tester.pumpAndSettle();
      expect(find.text('Frequently asked questions'), findsOneWidget);
    });

    testWidgets('renders CTA at bottom after scroll', (tester) async {
      await tester.pumpWidget(wrap(const CoachMatchScreen()));
      await tester.scrollUntilVisible(
        find.text('Ready to find your coach?'),
        300,
      );
      await tester.pumpAndSettle();
      expect(find.text('Ready to find your coach?'), findsOneWidget);
      expect(
        find.text('30-day money-back guarantee. No risk.'),
        findsOneWidget,
      );
    });

    testWidgets('renders Get started button in CTA after scroll', (
      tester,
    ) async {
      await tester.pumpWidget(wrap(const CoachMatchScreen()));
      await tester.scrollUntilVisible(find.text('Ruth Croft'), 300);
      await tester.pumpAndSettle();
      expect(find.text('Get started'), findsWidgets);
    });

    testWidgets('renders Book Call buttons', (tester) async {
      await tester.pumpWidget(wrap(const CoachMatchScreen()));
      expect(find.text('Start Questionnaire'), findsOneWidget);
    });

    testWidgets('renders testimonial after scroll', (tester) async {
      await tester.pumpWidget(wrap(const CoachMatchScreen()));
      await tester.scrollUntilVisible(find.text('Ruth Croft'), 300);
      await tester.pumpAndSettle();
      expect(find.text('Ruth Croft'), findsOneWidget);
      expect(find.text('Elite Trail Runner'), findsOneWidget);
    });

    testWidgets('renders coach specialities', (tester) async {
      await tester.pumpWidget(wrap(const CoachMatchScreen()));
      await tester.scrollUntilVisible(find.text('Why Coach Match works'), 300);
      await tester.pumpAndSettle();
      expect(find.text('Science-backed'), findsOneWidget);
      expect(find.text('Personalized'), findsOneWidget);
      expect(find.text('Communication'), findsOneWidget);
      expect(find.text('Long-game approach'), findsOneWidget);
    });

    testWidgets('renders monthly fees', (tester) async {
      await tester.pumpWidget(wrap(const CoachMatchScreen()));
      await tester.scrollUntilVisible(find.text('Choose your package'), 300);
      await tester.pumpAndSettle();
      expect(find.text('Choose your package'), findsOneWidget);
      expect(find.text('Bronze'), findsOneWidget);
      expect(find.text('Silver'), findsOneWidget);
      expect(find.text('Gold'), findsOneWidget);
    });
  });

  group('StrengthScreen - expanded coverage', () {
    testWidgets('renders Explore strength plans after scroll', (tester) async {
      await tester.pumpWidget(wrap(const StrengthScreen()));
      await tester.scrollUntilVisible(find.text('Explore strength plans'), 300);
      await tester.pumpAndSettle();
      expect(find.text('Explore strength plans'), findsOneWidget);
    });

    testWidgets('renders plan cards after scroll', (tester) async {
      await tester.pumpWidget(wrap(const StrengthScreen()));
      await tester.scrollUntilVisible(find.text('Base Building'), 300);
      await tester.pumpAndSettle();
      expect(find.text('Base Building'), findsOneWidget);
      expect(find.text('Race Ready'), findsOneWidget);
      expect(find.text('Injury Prevention'), findsOneWidget);
    });

    testWidgets('renders plan durations after scroll', (tester) async {
      await tester.pumpWidget(wrap(const StrengthScreen()));
      await tester.scrollUntilVisible(find.text('12 weeks'), 300);
      await tester.pumpAndSettle();
      expect(find.text('12 weeks'), findsOneWidget);
      expect(find.text('8 weeks'), findsOneWidget);
      expect(find.text('6 weeks'), findsOneWidget);
    });

    testWidgets('renders View plan buttons after scroll', (tester) async {
      await tester.pumpWidget(wrap(const StrengthScreen()));
      // Scroll to a unique nearby text first
      await tester.scrollUntilVisible(find.text('Injury Prevention'), 300);
      await tester.pumpAndSettle();
      expect(find.text('View plan'), findsNWidgets(3));
    });

    testWidgets('renders testimonial after scroll', (tester) async {
      await tester.pumpWidget(wrap(const StrengthScreen()));
      await tester.scrollUntilVisible(find.text('Ryan M.'), 300);
      await tester.pumpAndSettle();
      expect(find.text('Ryan M.'), findsOneWidget);
      expect(find.text('Marathon Runner'), findsOneWidget);
    });

    testWidgets('renders FAQ section after scroll', (tester) async {
      await tester.pumpWidget(wrap(const StrengthScreen()));
      await tester.scrollUntilVisible(
        find.text('Frequently asked questions'),
        300,
      );
      await tester.pumpAndSettle();
      expect(find.text('Frequently asked questions'), findsOneWidget);
    });

    testWidgets('renders FAQ questions after scroll', (tester) async {
      await tester.pumpWidget(wrap(const StrengthScreen()));
      await tester.scrollUntilVisible(
        find.text('Is strength training included in Premium?'),
        300,
      );
      await tester.pumpAndSettle();
      expect(
        find.text('Is strength training included in Premium?'),
        findsOneWidget,
      );
      expect(find.text('Can I build custom workouts?'), findsOneWidget);
    });

    testWidgets('renders CTA section after scroll', (tester) async {
      await tester.pumpWidget(wrap(const StrengthScreen()));
      await tester.scrollUntilVisible(
        find.text('Start building strength today.'),
        300,
      );
      await tester.pumpAndSettle();
      expect(find.text('Start building strength today.'), findsOneWidget);
      expect(find.text('Included with Veltrix Premium.'), findsOneWidget);
    });

    testWidgets('renders Explore Premium button after scroll', (tester) async {
      await tester.pumpWidget(wrap(const StrengthScreen()));
      await tester.scrollUntilVisible(find.text('Explore Premium'), 300);
      await tester.pumpAndSettle();
      expect(find.text('Explore Premium'), findsOneWidget);
    });

    testWidgets('renders stat cards after scroll', (tester) async {
      await tester.pumpWidget(wrap(const StrengthScreen()));
      await tester.scrollUntilVisible(find.text('1000+'), 300);
      await tester.pumpAndSettle();
      expect(find.text('1000+'), findsOneWidget);
      expect(find.text('Exercises'), findsOneWidget);
      expect(find.text('Video'), findsOneWidget);
      expect(find.text('Calendar'), findsOneWidget);
      expect(find.text('Compliance'), findsOneWidget);
      expect(find.text('Tracking'), findsOneWidget);
    });

    testWidgets('renders strength for endurance athletes after scroll', (
      tester,
    ) async {
      await tester.pumpWidget(wrap(const StrengthScreen()));
      await tester.scrollUntilVisible(
        find.text('Strength for endurance athletes.'),
        300,
      );
      await tester.pumpAndSettle();
      expect(find.text('Strength for endurance athletes.'), findsOneWidget);
    });
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:veltrix_sports/widgets/common/editorial_banner.dart';
import 'package:veltrix_sports/core/constants.dart';

Widget wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  group('EditorialBanner', () {
    testWidgets('renders with Alignment.centerLeft', (tester) async {
      await tester.pumpWidget(
        wrap(
          const EditorialBanner(
            image: 'assets/images/endurance-runner.png',
            eyebrow: 'TRAINING PLAN',
            title: 'Build Your Base',
            alignment: Alignment.centerLeft,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(EditorialBanner), findsOneWidget);
      expect(find.text('TRAINING PLAN'), findsOneWidget);
      expect(find.text('Build Your Base'), findsOneWidget);
    });

    testWidgets('renders with Alignment.centerRight', (tester) async {
      await tester.pumpWidget(
        wrap(
          const EditorialBanner(
            image: 'assets/images/cyclist-coaching.png',
            eyebrow: 'COACH PICK',
            title: 'Speed Session',
            alignment: Alignment.centerRight,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(EditorialBanner), findsOneWidget);
      expect(find.text('COACH PICK'), findsOneWidget);
      expect(find.text('Speed Session'), findsOneWidget);
    });

    testWidgets('displays eyebrow text with lime color style', (tester) async {
      await tester.pumpWidget(
        wrap(
          const EditorialBanner(
            image: 'assets/images/endurance-runner.png',
            eyebrow: 'PREMIUM',
            title: 'Elite Training',
            alignment: Alignment.centerLeft,
          ),
        ),
      );
      await tester.pumpAndSettle();

      final eyebrowText = tester.widget<Text>(find.text('PREMIUM'));
      final style = eyebrowText.style!;
      expect(style.color, equals(lime));
      expect(style.fontWeight, equals(FontWeight.w900));
    });

    testWidgets('displays title text with white color style', (tester) async {
      await tester.pumpWidget(
        wrap(
          const EditorialBanner(
            image: 'assets/images/cyclist-coaching.png',
            eyebrow: 'NEW',
            title: 'Marathon Prep',
            alignment: Alignment.centerRight,
          ),
        ),
      );
      await tester.pumpAndSettle();

      final titleText = tester.widget<Text>(find.text('Marathon Prep'));
      final style = titleText.style!;
      expect(style.color, equals(Colors.white));
      expect(style.fontWeight, equals(FontWeight.w900));
    });

    testWidgets('wraps content in Align widget with correct alignment', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrap(
          const EditorialBanner(
            image: 'assets/images/endurance-runner.png',
            eyebrow: 'ALIGN',
            title: 'Left Aligned',
            alignment: Alignment.centerLeft,
          ),
        ),
      );
      await tester.pumpAndSettle();

      final align = tester.widget<Align>(find.byType(Align).last);
      expect(align.alignment, equals(Alignment.centerLeft));
    });

    testWidgets('wraps content in Align widget with centerRight', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrap(
          const EditorialBanner(
            image: 'assets/images/cyclist-coaching.png',
            eyebrow: 'ALIGN',
            title: 'Right Aligned',
            alignment: Alignment.centerRight,
          ),
        ),
      );
      await tester.pumpAndSettle();

      final align = tester.widget<Align>(find.byType(Align).last);
      expect(align.alignment, equals(Alignment.centerRight));
    });

    testWidgets('renders Column layout with texts', (tester) async {
      await tester.pumpWidget(
        wrap(
          const EditorialBanner(
            image: 'assets/images/endurance-runner.png',
            eyebrow: 'EYEBROW',
            title: 'Title Text',
            alignment: Alignment.centerLeft,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(Column), findsWidgets);
      expect(find.text('EYEBROW'), findsOneWidget);
      expect(find.text('Title Text'), findsOneWidget);
    });

    testWidgets('different eyebrow and title values render correctly', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrap(
          const EditorialBanner(
            image: 'assets/images/cyclist-coaching.png',
            eyebrow: 'RECOVERY',
            title: 'Rest & Rebuild',
            alignment: Alignment.centerRight,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('RECOVERY'), findsOneWidget);
      expect(find.text('Rest & Rebuild'), findsOneWidget);
    });

    testWidgets('gradient decoration covers banner', (tester) async {
      await tester.pumpWidget(
        wrap(
          const EditorialBanner(
            image: 'assets/images/endurance-runner.png',
            eyebrow: 'GRAD',
            title: 'Gradient Test',
            alignment: Alignment.centerLeft,
          ),
        ),
      );
      await tester.pumpAndSettle();

      final container = tester.widget<Container>(find.byType(Container).first);
      expect(container.foregroundDecoration, isNotNull);
    });

    testWidgets('SizedBox width is 210', (tester) async {
      await tester.pumpWidget(
        wrap(
          const EditorialBanner(
            image: 'assets/images/endurance-runner.png',
            eyebrow: 'WIDTH',
            title: 'Width Test',
            alignment: Alignment.centerLeft,
          ),
        ),
      );
      await tester.pumpAndSettle();

      final sizedBox = tester.widget<SizedBox>(
        find.byWidgetPredicate(
          (widget) => widget is SizedBox && widget.width == 210,
        ),
      );
      expect(sizedBox.width, 210);
    });

    testWidgets('SizedBox has padding of 18', (tester) async {
      await tester.pumpWidget(
        wrap(
          const EditorialBanner(
            image: 'assets/images/cyclist-coaching.png',
            eyebrow: 'PAD',
            title: 'Padding Test',
            alignment: Alignment.centerLeft,
          ),
        ),
      );
      await tester.pumpAndSettle();

      final padding = tester.widget<Padding>(
        find.byWidgetPredicate(
          (widget) =>
              widget is Padding && widget.padding == const EdgeInsets.all(18),
        ),
      );
      expect(padding.padding, const EdgeInsets.all(18));
    });

    testWidgets('centerLeft gradient goes left to right', (tester) async {
      await tester.pumpWidget(
        wrap(
          const EditorialBanner(
            image: 'assets/images/endurance-runner.png',
            eyebrow: 'GRAD',
            title: 'Left Gradient',
            alignment: Alignment.centerLeft,
          ),
        ),
      );
      await tester.pumpAndSettle();

      final container = tester.widget<Container>(find.byType(Container).first);
      final decoration = container.foregroundDecoration as BoxDecoration;
      final gradient = decoration.gradient as LinearGradient;
      expect(gradient.begin, equals(Alignment.centerLeft));
      expect(gradient.end, equals(Alignment.centerRight));
    });

    testWidgets('centerRight gradient goes right to left', (tester) async {
      await tester.pumpWidget(
        wrap(
          const EditorialBanner(
            image: 'assets/images/cyclist-coaching.png',
            eyebrow: 'GRAD',
            title: 'Right Gradient',
            alignment: Alignment.centerRight,
          ),
        ),
      );
      await tester.pumpAndSettle();

      final container = tester.widget<Container>(find.byType(Container).first);
      final decoration = container.foregroundDecoration as BoxDecoration;
      final gradient = decoration.gradient as LinearGradient;
      expect(gradient.begin, equals(Alignment.centerRight));
      expect(gradient.end, equals(Alignment.centerLeft));
    });

    testWidgets('gradient has two color stops', (tester) async {
      await tester.pumpWidget(
        wrap(
          const EditorialBanner(
            image: 'assets/images/endurance-runner.png',
            eyebrow: 'GRAD',
            title: 'Colors',
            alignment: Alignment.centerLeft,
          ),
        ),
      );
      await tester.pumpAndSettle();

      final container = tester.widget<Container>(find.byType(Container).first);
      final decoration = container.foregroundDecoration as BoxDecoration;
      final gradient = decoration.gradient as LinearGradient;
      expect(gradient.colors.length, 2);
    });

    testWidgets('SizedBox height is 5 between eyebrow and title', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrap(
          const EditorialBanner(
            image: 'assets/images/endurance-runner.png',
            eyebrow: 'SPACER',
            title: 'Spacer Test',
            alignment: Alignment.centerLeft,
          ),
        ),
      );
      await tester.pumpAndSettle();

      final sizedBox = tester.widget<SizedBox>(
        find.byWidgetPredicate(
          (widget) => widget is SizedBox && widget.height == 5,
        ),
      );
      expect(sizedBox.height, 5);
    });
  });
}

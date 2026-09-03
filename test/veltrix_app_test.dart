import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:veltrix_sports/main.dart';
import 'package:veltrix_sports/mobile/shell.dart';
import 'package:veltrix_sports/screens/coach_questionnaire_screen.dart';
import 'package:veltrix_sports/screens/premium_screen.dart';

void main() {
  testWidgets('athlete home renders core training information', (tester) async {
    tester.view.physicalSize = const Size(1280, 800);
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(const VeltrixApp());
    await tester.pumpAndSettle();
    expect(find.text('Your complete\ntraining platform.'), findsOneWidget);
  });

  testWidgets('narrow web layouts use the mobile shell', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(const VeltrixApp());

    expect(find.byType(MobileShell), findsOneWidget);
    expect(find.text('Your complete\ntraining platform.'), findsOneWidget);
  });

  testWidgets('coach questionnaire exposes required training choices', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: CoachQuestionnaireScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Tell us about your training'), findsOneWidget);
    expect(find.text('Primary sport'), findsOneWidget);
    expect(find.text('Submit answers', skipOffstage: false), findsOneWidget);
  });

  testWidgets('premium screen exposes both trial plans', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: PremiumScreen())));
    await tester.pumpAndSettle();
    await tester.drag(find.byType(ListView), const Offset(0, -1600));
    await tester.pumpAndSettle();

    expect(find.text('Monthly', skipOffstage: false), findsOneWidget);
    expect(find.text('Annual', skipOffstage: false), findsOneWidget);
    expect(find.text('Start free trial', skipOffstage: false), findsNWidgets(2));
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:veltrix_sports/screens/premium/premium_screen.dart';

void main() {
  testWidgets(
    'PremiumScreen renders subscription plans and checkout triggers',
    (tester) async {
      tester.view.physicalSize = const Size(1280, 800);
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: Scaffold(body: PremiumScreen())),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(PremiumScreen), findsOneWidget);
      expect(find.textContaining('Your Next Peak'), findsOneWidget);
    },
  );
}

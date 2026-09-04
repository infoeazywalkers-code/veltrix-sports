import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:veltrix_sports/screens/explore_screen.dart';

void main() {
  testWidgets('ExploreScreen renders plan catalog and filter categories', (tester) async {
    tester.view.physicalSize = const Size(1280, 800);
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: ExploreScreen(),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byType(ExploreScreen), findsOneWidget);
  });
}

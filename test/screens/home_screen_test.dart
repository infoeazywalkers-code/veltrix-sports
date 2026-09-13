import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:veltrix_sports/screens/home/home_screen.dart';

void main() {
  testWidgets('HomeScreen renders dashboard sections and quick actions', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1280, 800);
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: Scaffold(body: HomeScreen())),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.textContaining('Your complete'), findsOneWidget);
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:veltrix_sports/main.dart';

void main() {
  testWidgets('VeltrixRoot renders without crashing', (tester) async {
    tester.view.physicalSize = const Size(1280, 800);
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(const ProviderScope(child: VeltrixRoot()));
    await tester.pumpAndSettle();
    expect(find.byType(MaterialApp), findsOneWidget);
  });

  testWidgets('narrow layouts render without crashing', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(const ProviderScope(child: VeltrixRoot()));
    await tester.pumpAndSettle();
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}

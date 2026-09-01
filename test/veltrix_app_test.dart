import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:veltrix_sports/main.dart';
import 'package:veltrix_sports/mobile/shell.dart';

void main() {
  testWidgets('athlete home renders core training information', (tester) async {
    tester.view.physicalSize = const Size(1280, 800);
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(const VeltrixApp());
    expect(find.text('Your complete\ntraining platform.'), findsOneWidget);
    expect(find.text('Your strongest season starts here.'), findsOneWidget);
  });

  testWidgets('narrow web layouts use the mobile shell', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(const VeltrixApp());

    expect(find.byType(MobileShell), findsOneWidget);
    expect(find.text('Your complete\ntraining platform.'), findsOneWidget);
  });
}

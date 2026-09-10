import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:veltrix_sports/screens/devices/devices_screen.dart';

void main() {
  testWidgets('DevicesScreen renders Watch Auto-Sync banner and device categories', (tester) async {
    tester.view.physicalSize = const Size(1280, 800);
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: DevicesScreen(),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byType(DevicesScreen), findsOneWidget);
    expect(find.textContaining('Apple Watch'), findsWidgets);
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:veltrix_sports/models/user_preferences.dart';
import 'package:veltrix_sports/providers.dart';
import 'package:veltrix_sports/screens/settings_screen.dart';

Widget wrapSettings({
  ThemeModePreference themeMode = ThemeModePreference.system,
  UnitSystem unitSystem = UnitSystem.metric,
}) => ProviderScope(
  overrides: [
    userPreferencesProvider.overrideWith(
      (ref) => Stream.value(
        UserPreferences(
          theme: ThemePreferences(mode: themeMode),
          display: DisplayPreferences(unitSystem: unitSystem),
        ),
      ),
    ),
    themeModeProvider.overrideWithValue(themeMode),
  ],
  child: const MaterialApp(home: Scaffold(body: SettingsScreen())),
);

void main() {
  group('SettingsScreen', () {
    testWidgets('renders Settings title', (tester) async {
      await tester.pumpWidget(wrapSettings());
      await tester.pumpAndSettle();
      expect(find.text('Settings'), findsOneWidget);
    });

    testWidgets('renders Appearance section', (tester) async {
      await tester.pumpWidget(wrapSettings());
      await tester.pumpAndSettle();
      expect(find.text('Appearance'), findsOneWidget);
    });

    testWidgets('renders theme toggle with System, Light, Dark options', (
      tester,
    ) async {
      await tester.pumpWidget(wrapSettings());
      await tester.pumpAndSettle();
      expect(find.text('System'), findsOneWidget);
      expect(find.text('Light'), findsOneWidget);
      expect(find.text('Dark'), findsOneWidget);
    });

    testWidgets('renders Units section', (tester) async {
      await tester.pumpWidget(wrapSettings());
      await tester.pumpAndSettle();
      expect(find.text('Units'), findsOneWidget);
    });

    testWidgets('renders unit toggle with Metric and Imperial', (tester) async {
      await tester.pumpWidget(wrapSettings());
      await tester.pumpAndSettle();
      expect(find.text('Metric'), findsOneWidget);
      expect(find.text('Imperial'), findsOneWidget);
    });

    testWidgets('renders Training Zones section', (tester) async {
      await tester.pumpWidget(wrapSettings());
      await tester.pumpAndSettle();
      expect(find.text('Training Zones'), findsOneWidget);
    });

    testWidgets('renders Notifications section', (tester) async {
      await tester.pumpWidget(wrapSettings());
      await tester.pumpAndSettle();
      expect(find.text('Notifications'), findsOneWidget);
      expect(find.text('Workout Reminders'), findsOneWidget);
      expect(find.text('Coach Messages'), findsOneWidget);
      expect(find.text('Weekly Summary'), findsOneWidget);
      expect(find.text('Achievements'), findsOneWidget);
    });

    testWidgets('renders Schedule section', (tester) async {
      await tester.pumpWidget(wrapSettings());
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(find.text('Schedule'), 300);
      await tester.pumpAndSettle();
      expect(find.text('Schedule'), findsOneWidget);
      expect(find.text('Available Days'), findsOneWidget);
      expect(find.text('Rest Days'), findsOneWidget);
    });

    testWidgets('renders day-of-week chips', (tester) async {
      await tester.pumpWidget(wrapSettings());
      await tester.pumpAndSettle();
      // Scroll to the schedule section first
      await tester.scrollUntilVisible(find.text('Available Days'), 300);
      await tester.pumpAndSettle();
      expect(find.text('Mon'), findsWidgets);
      expect(find.text('Sun'), findsWidgets);
    });

    testWidgets('renders with default preferences (null)', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            userPreferencesProvider.overrideWith((ref) => Stream.value(null)),
          ],
          child: const MaterialApp(home: Scaffold(body: SettingsScreen())),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Settings'), findsOneWidget);
      expect(find.text('Appearance'), findsOneWidget);
    });
  });
}

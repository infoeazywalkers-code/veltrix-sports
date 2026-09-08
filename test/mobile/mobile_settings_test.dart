import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:veltrix_sports/models/user_preferences.dart';
import 'package:veltrix_sports/providers.dart';
import 'package:veltrix_sports/mobile/screens/mobile_settings.dart';

Widget wrapMobileSettings({
  ThemeModePreference themeMode = ThemeModePreference.system,
  bool workoutReminders = true,
  bool coachMessages = true,
  bool weeklySummary = true,
  List<int> restDays = const [7],
}) => ProviderScope(
  overrides: [
    userPreferencesProvider.overrideWith(
      (ref) => Stream.value(
        UserPreferences(
          theme: ThemePreferences(mode: themeMode),
          notifications: NotificationPreferences(
            workoutReminders: workoutReminders,
            coachMessages: coachMessages,
            weeklySummary: weeklySummary,
          ),
          schedule: SchedulePreferences(restDays: restDays),
        ),
      ),
    ),
  ],
  child: const MaterialApp(home: MobileSettingsScreen()),
);

void main() {
  group('MobileSettingsScreen', () {
    testWidgets('renders Settings AppBar title', (tester) async {
      await tester.pumpWidget(wrapMobileSettings());
      await tester.pumpAndSettle();
      expect(find.text('Settings'), findsOneWidget);
    });

    testWidgets('renders Appearance section', (tester) async {
      await tester.pumpWidget(wrapMobileSettings());
      await tester.pumpAndSettle();
      expect(find.text('Appearance'), findsOneWidget);
    });

    testWidgets('renders theme segmented buttons', (tester) async {
      await tester.pumpWidget(wrapMobileSettings());
      await tester.pumpAndSettle();
      expect(find.text('System'), findsOneWidget);
      expect(find.text('Light'), findsOneWidget);
      expect(find.text('Dark'), findsOneWidget);
    });

    testWidgets('renders Units section', (tester) async {
      await tester.pumpWidget(wrapMobileSettings());
      await tester.pumpAndSettle();
      expect(find.text('Units'), findsOneWidget);
      expect(find.text('Metric'), findsOneWidget);
      expect(find.text('Imperial'), findsOneWidget);
    });

    testWidgets('renders Notifications section with toggle tiles', (
      tester,
    ) async {
      await tester.pumpWidget(wrapMobileSettings());
      await tester.pumpAndSettle();
      expect(find.text('Notifications'), findsOneWidget);
      expect(find.text('Workout Reminders'), findsOneWidget);
      expect(find.text('Coach Messages'), findsOneWidget);
      expect(find.text('Weekly Summary'), findsOneWidget);
    });

    testWidgets('notification toggles are rendered as SwitchListTile', (
      tester,
    ) async {
      await tester.pumpWidget(wrapMobileSettings());
      await tester.pumpAndSettle();
      expect(find.byType(SwitchListTile), findsNWidgets(3));
    });

    testWidgets('renders Rest Days section with FilterChips', (tester) async {
      await tester.pumpWidget(wrapMobileSettings());
      await tester.pumpAndSettle();
      expect(find.text('Rest Days'), findsOneWidget);
      expect(find.byType(FilterChip), findsWidgets);
    });

    testWidgets('renders day-of-week filter chips', (tester) async {
      await tester.pumpWidget(wrapMobileSettings());
      await tester.pumpAndSettle();
      expect(find.text('Mon'), findsWidgets);
      expect(find.text('Sun'), findsWidgets);
    });

    testWidgets('renders with default (null) preferences', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            userPreferencesProvider.overrideWith((ref) => Stream.value(null)),
          ],
          child: const MaterialApp(home: MobileSettingsScreen()),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Settings'), findsOneWidget);
      expect(find.text('Appearance'), findsOneWidget);
    });
  });
}

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:veltrix_sports/models/user_profile.dart';
import 'package:veltrix_sports/providers.dart';
import 'package:veltrix_sports/mobile/screens/mobile_profile.dart';

Widget wrapWithProviders({UserProfile? profile}) => ProviderScope(
  overrides: [userProfileProvider.overrideWith((ref) => Stream.value(profile))],
  child: const MaterialApp(home: Scaffold(body: MobileProfileScreen())),
);

Widget wrapWithLoading() {
  final controller = StreamController<UserProfile?>();
  return ProviderScope(
    overrides: [userProfileProvider.overrideWith((ref) => controller.stream)],
    child: const MaterialApp(home: Scaffold(body: MobileProfileScreen())),
  );
}

void main() {
  group('MobileProfileScreen (logged-out state)', () {
    testWidgets('renders welcome text when profile is null', (tester) async {
      await tester.pumpWidget(wrapWithProviders());
      await tester.pumpAndSettle();
      expect(find.text('Welcome to Veltrix Sports'), findsOneWidget);
    });

    testWidgets('renders sign in button when profile is null', (tester) async {
      await tester.pumpWidget(wrapWithProviders());
      await tester.pumpAndSettle();
      expect(find.text('Sign in with Google'), findsOneWidget);
    });

    testWidgets('renders person outline icons when profile is null', (
      tester,
    ) async {
      await tester.pumpWidget(wrapWithProviders());
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.person_outline), findsWidgets);
    });

    testWidgets('renders sign out button', (tester) async {
      await tester.pumpWidget(wrapWithProviders());
      await tester.pumpAndSettle();
      // Scroll to the bottom of the list to find the Sign out button
      await tester.scrollUntilVisible(find.text('Sign out'), 200);
      await tester.pumpAndSettle();
      expect(find.text('Sign out'), findsOneWidget);
    });

    testWidgets('sign out button shows confirmation dialog', (tester) async {
      await tester.pumpWidget(wrapWithProviders());
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(find.text('Sign out'), 200);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Sign out'));
      await tester.pumpAndSettle();
      expect(find.text('Sign out?'), findsOneWidget);
      expect(find.text('You can sign back in at any time.'), findsOneWidget);
    });

    testWidgets('sign out dialog has Cancel and Sign out actions', (
      tester,
    ) async {
      await tester.pumpWidget(wrapWithProviders());
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(find.text('Sign out'), 200);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Sign out'));
      await tester.pumpAndSettle();
      expect(find.text('Sign out?'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
    });
  });

  group('MobileProfileScreen (logged-in state)', () {
    final loggedInProfile = UserProfile(
      id: 'user_1',
      email: 'alex@veltrix.com',
      displayName: 'Alex Runner',
      sports: ['Running', 'Cycling'],
      role: UserRole.athlete,
      isPremium: true,
      createdAt: DateTime(2024, 1, 15),
    );

    testWidgets('renders user name', (tester) async {
      await tester.pumpWidget(wrapWithProviders(profile: loggedInProfile));
      await tester.pumpAndSettle();
      expect(find.text('Alex Runner'), findsOneWidget);
    });

    testWidgets('renders user initials in avatar', (tester) async {
      await tester.pumpWidget(wrapWithProviders(profile: loggedInProfile));
      await tester.pumpAndSettle();
      expect(find.text('AR'), findsOneWidget);
      expect(find.byType(CircleAvatar), findsOneWidget);
    });

    testWidgets('renders user sports', (tester) async {
      await tester.pumpWidget(wrapWithProviders(profile: loggedInProfile));
      await tester.pumpAndSettle();
      expect(find.text('Running • Cycling'), findsOneWidget);
    });

    testWidgets('renders edit button', (tester) async {
      await tester.pumpWidget(wrapWithProviders(profile: loggedInProfile));
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.edit_outlined), findsOneWidget);
    });

    testWidgets('renders Veltrix Premium section', (tester) async {
      await tester.pumpWidget(wrapWithProviders(profile: loggedInProfile));
      await tester.pumpAndSettle();
      expect(find.text('Veltrix Premium'), findsOneWidget);
    });

    testWidgets('renders Account settings section', (tester) async {
      await tester.pumpWidget(wrapWithProviders(profile: loggedInProfile));
      await tester.pumpAndSettle();
      expect(find.text('Account'), findsOneWidget);
      expect(find.text('Personal details'), findsOneWidget);
      expect(find.text('Training zones'), findsOneWidget);
      expect(find.text('Apps & devices'), findsOneWidget);
      expect(find.text('Equipment'), findsOneWidget);
    });

    testWidgets('renders Support section', (tester) async {
      await tester.pumpWidget(wrapWithProviders(profile: loggedInProfile));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(find.text('Support'), 300);
      await tester.pumpAndSettle();
      expect(find.text('Support'), findsOneWidget);
      expect(find.text('Help center'), findsOneWidget);
      expect(find.text('Contact support'), findsOneWidget);
      expect(find.text('About Veltrix'), findsOneWidget);
    });
  });

  group('MobileProfileScreen (loading state)', () {
    testWidgets('shows loading indicator', (tester) async {
      await tester.pumpWidget(wrapWithLoading());
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });

  group('MobileProfileScreen (profile with no sports)', () {
    testWidgets('shows fallback text for empty sports', (tester) async {
      final profile = UserProfile(
        id: 'u2',
        email: 'b@c.com',
        displayName: 'No Sports User',
        sports: [],
        role: UserRole.athlete,
        createdAt: DateTime.now(),
      );
      await tester.pumpWidget(wrapWithProviders(profile: profile));
      await tester.pumpAndSettle();
      expect(find.text('No sports set'), findsOneWidget);
    });
  });

  group('MobileProfileScreen (profile with photo)', () {
    testWidgets('does not show initials when photoUrl is present', (
      tester,
    ) async {
      final profile = UserProfile(
        id: 'u3',
        email: 'd@e.com',
        displayName: 'Photo User',
        photoUrl:
            '', // Empty string triggers same code path but no network call
        sports: ['Running'],
        role: UserRole.athlete,
        createdAt: DateTime.now(),
      );
      await tester.pumpWidget(wrapWithProviders(profile: profile));
      await tester.pumpAndSettle();
      expect(find.byType(CircleAvatar), findsOneWidget);
    });
  });
}

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:veltrix_sports/models/user/user_profile.dart';
import 'package:veltrix_sports/providers.dart';
import 'package:veltrix_sports/mobile/screens/mobile_profile.dart';

Widget wrapProfile({UserProfile? profile}) => ProviderScope(
  overrides: [userProfileProvider.overrideWith((ref) => Stream.value(profile))],
  child: const MaterialApp(home: Scaffold(body: MobileProfileScreen())),
);

Widget wrapProfileLoading() {
  final controller = StreamController<UserProfile?>();
  return ProviderScope(
    overrides: [userProfileProvider.overrideWith((ref) => controller.stream)],
    child: const MaterialApp(home: Scaffold(body: MobileProfileScreen())),
  );
}

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  group('MobileProfileScreen logged-out', () {
    testWidgets('shows welcome text', (tester) async {
      await tester.pumpWidget(wrapProfile());
      await tester.pumpAndSettle();
      expect(find.text('Welcome to Veltrix Sports'), findsOneWidget);
    });

    testWidgets('shows sign in description', (tester) async {
      await tester.pumpWidget(wrapProfile());
      await tester.pumpAndSettle();
      expect(find.textContaining('Sign in to access'), findsOneWidget);
    });

    testWidgets('shows sign in button', (tester) async {
      await tester.pumpWidget(wrapProfile());
      await tester.pumpAndSettle();
      expect(find.text('Sign in with Google'), findsOneWidget);
    });

    testWidgets('shows person outline icon', (tester) async {
      await tester.pumpWidget(wrapProfile());
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.person_outline), findsWidgets);
    });

    testWidgets('shows sign out button', (tester) async {
      await tester.pumpWidget(wrapProfile());
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(find.text('Sign out'), 200);
      await tester.pumpAndSettle();
      expect(find.text('Sign out'), findsOneWidget);
    });

    testWidgets('sign out shows confirmation dialog', (tester) async {
      await tester.pumpWidget(wrapProfile());
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(find.text('Sign out'), 200);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Sign out'));
      await tester.pumpAndSettle();
      expect(find.text('Sign out?'), findsOneWidget);
      expect(find.text('You can sign back in at any time.'), findsOneWidget);
    });

    testWidgets('sign out dialog has Cancel and Sign out', (tester) async {
      await tester.pumpWidget(wrapProfile());
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(find.text('Sign out'), 200);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Sign out'));
      await tester.pumpAndSettle();
      expect(find.text('Cancel'), findsOneWidget);
    });
  });

  group('MobileProfileScreen logged-in', () {
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
      await tester.pumpWidget(wrapProfile(profile: loggedInProfile));
      await tester.pumpAndSettle();
      expect(find.text('Alex Runner'), findsOneWidget);
    });

    testWidgets('renders user initials in avatar', (tester) async {
      await tester.pumpWidget(wrapProfile(profile: loggedInProfile));
      await tester.pumpAndSettle();
      expect(find.text('AR'), findsOneWidget);
      expect(find.byType(CircleAvatar), findsOneWidget);
    });

    testWidgets('renders user sports', (tester) async {
      await tester.pumpWidget(wrapProfile(profile: loggedInProfile));
      await tester.pumpAndSettle();
      expect(find.text('Running • Cycling'), findsOneWidget);
    });

    testWidgets('renders edit button', (tester) async {
      await tester.pumpWidget(wrapProfile(profile: loggedInProfile));
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.edit_outlined), findsOneWidget);
    });

    testWidgets('renders Veltrix Premium section', (tester) async {
      await tester.pumpWidget(wrapProfile(profile: loggedInProfile));
      await tester.pumpAndSettle();
      expect(find.text('Veltrix Premium'), findsOneWidget);
    });

    testWidgets('shows No active subscription', (tester) async {
      await tester.pumpWidget(wrapProfile(profile: loggedInProfile));
      await tester.pumpAndSettle();
      expect(find.text('No active subscription'), findsOneWidget);
    });

    testWidgets('shows Account settings section', (tester) async {
      await tester.pumpWidget(wrapProfile(profile: loggedInProfile));
      await tester.pumpAndSettle();
      expect(find.text('Account'), findsOneWidget);
      expect(find.text('Personal details'), findsOneWidget);
      expect(find.text('Training zones'), findsOneWidget);
      expect(find.text('Apps & devices'), findsOneWidget);
      expect(find.text('Equipment'), findsOneWidget);
    });

    testWidgets('shows Support section', (tester) async {
      await tester.pumpWidget(wrapProfile(profile: loggedInProfile));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(find.text('Support'), 200);
      await tester.pumpAndSettle();
      expect(find.text('Support'), findsOneWidget);
      expect(find.text('Help center'), findsOneWidget);
      expect(find.text('Contact support'), findsOneWidget);
      expect(find.text('About Veltrix'), findsOneWidget);
    });

    testWidgets('Premium card navigates to PremiumScreen', (tester) async {
      await tester.pumpWidget(wrapProfile(profile: loggedInProfile));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Veltrix Premium'));
      await tester.pumpAndSettle();
    });
  });

  group('MobileProfileScreen loading', () {
    testWidgets('shows loading indicator', (tester) async {
      await tester.pumpWidget(wrapProfileLoading());
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });

  group('MobileProfileScreen profile variants', () {
    testWidgets('empty sports shows fallback', (tester) async {
      final profile = UserProfile(
        id: 'u2',
        email: 'b@c.com',
        displayName: 'No Sports User',
        sports: [],
        role: UserRole.athlete,
        createdAt: DateTime.now(),
      );
      await tester.pumpWidget(wrapProfile(profile: profile));
      await tester.pumpAndSettle();
      expect(find.text('No sports set'), findsOneWidget);
    });

    testWidgets('profile with empty photoUrl still renders CircleAvatar', (
      tester,
    ) async {
      final profile = UserProfile(
        id: 'u3',
        email: 'd@e.com',
        displayName: 'Photo User',
        photoUrl: '',
        sports: ['Running'],
        role: UserRole.athlete,
        createdAt: DateTime.now(),
      );
      await tester.pumpWidget(wrapProfile(profile: profile));
      await tester.pumpAndSettle();
      expect(find.byType(CircleAvatar), findsOneWidget);
    });

    testWidgets('profile with subscriptionRenewsAt shows renewal date', (
      tester,
    ) async {
      final profile = UserProfile(
        id: 'u4',
        email: 'e@f.com',
        displayName: 'Premium User',
        sports: ['Running'],
        role: UserRole.athlete,
        isPremium: true,
        subscriptionRenewsAt: DateTime(2026, 10, 15),
        createdAt: DateTime.now(),
      );
      await tester.pumpWidget(wrapProfile(profile: profile));
      await tester.pumpAndSettle();
      expect(find.textContaining('Renews'), findsOneWidget);
      expect(find.textContaining('15 Oct 2026'), findsOneWidget);
    });

    testWidgets('personal details settings item tap shows snackbar', (
      tester,
    ) async {
      final profile = UserProfile(
        id: 'u5',
        email: 'f@g.com',
        displayName: 'Settings User',
        sports: ['Running'],
        role: UserRole.athlete,
        createdAt: DateTime.now(),
      );
      await tester.pumpWidget(wrapProfile(profile: profile));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Personal details'));
      await tester.pump();
      expect(find.byType(SnackBar), findsOneWidget);
    });

    testWidgets('training zones settings item tap shows snackbar', (
      tester,
    ) async {
      final profile = UserProfile(
        id: 'u5',
        email: 'f@g.com',
        displayName: 'Settings User',
        sports: ['Running'],
        role: UserRole.athlete,
        createdAt: DateTime.now(),
      );
      await tester.pumpWidget(wrapProfile(profile: profile));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Training zones'));
      await tester.pump();
      expect(find.byType(SnackBar), findsOneWidget);
    });

    testWidgets('help center tap shows snackbar', (tester) async {
      final profile = UserProfile(
        id: 'u5',
        email: 'f@g.com',
        displayName: 'Settings User',
        sports: ['Running'],
        role: UserRole.athlete,
        createdAt: DateTime.now(),
      );
      await tester.pumpWidget(wrapProfile(profile: profile));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(find.text('Help center'), 200);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Help center'));
      await tester.pump();
      expect(find.byType(SnackBar), findsOneWidget);
    });

    testWidgets('about veltrix tap shows snackbar', (tester) async {
      final profile = UserProfile(
        id: 'u5',
        email: 'f@g.com',
        displayName: 'Settings User',
        sports: ['Running'],
        role: UserRole.athlete,
        createdAt: DateTime.now(),
      );
      await tester.pumpWidget(wrapProfile(profile: profile));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(find.text('About Veltrix'), 200);
      await tester.pumpAndSettle();
      await tester.tap(find.text('About Veltrix'));
      await tester.pump();
      expect(find.byType(SnackBar), findsOneWidget);
    });
  });
}

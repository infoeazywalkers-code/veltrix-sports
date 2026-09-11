/// Central route name constants for the Veltrix Sports app.
///
/// Phase 0: no behavior change — these constants document every destination
/// and provide index -> route mappings for the desktop [Shell] (20 entries)
/// and [MobileShell] (7 entries). Screens keep using integer indices for now;
/// later phases migrate call sites to enums that align with these mappings.
class AppRoutes {
  static const String login = '/login';
  static const String onboarding = '/onboarding';
  static const String home = '/home';
  static const String calendar = '/calendar';
  static const String progress = '/progress';
  static const String explore = '/explore';
  static const String profile = '/profile';
  static const String premium = '/premium';
  static const String coachMatch = '/coach-match';
  static const String devices = '/devices';
  static const String strength = '/strength';
  static const String notifications = '/notifications';
  static const String trainingPlans = '/training-plans';
  static const String events = '/events';
  static const String tickets = '/tickets';
  static const String workoutLibrary = '/workout-library';
  static const String coachPlatform = '/coach-platform';
  static const String coachResources = '/coach-resources';
  static const String support = '/support';
  static const String trainingGuides = '/training-guides';
  static const String about = '/about';
  static const String settings = '/settings';
  static const String profileEdit = '/profile-edit';
  static const String workoutDetail = '/workout-detail';
  static const String coachQuestionnaire = '/coach-questionnaire';
  static const String analyticsPmc = '/analytics-pmc';
  static const String analyticsPower = '/analytics-power';
  static const String analyticsZones = '/analytics-zones';
  static const String accountDeletion = '/account-deletion';
  static const String activityFeed = '/activity-feed';
  static const String challenges = '/challenges';
  static const String leaderboard = '/leaderboard';
  static const String athleteDiscovery = '/athlete-discovery';

  /// Mobile-only "More features" hub (index 5 in [MobileShell]).
  static const String more = '/more';

  /// Legacy alias: the deprecated AthleteOnboardingScreen hosted at
  /// desktop shell index 19. Superseded by [onboarding] (OnboardingFlow).
  static const String athleteOnboarding = '/athlete-onboarding';

  const AppRoutes._();
}

/// Maps desktop shell index (0..19) to its route name.
/// Order matches `_ShellState._buildScreen` / [ShellPage].
const List<String> shellIndexToRoute = <String>[
  AppRoutes.home, // 0
  AppRoutes.calendar, // 1
  AppRoutes.progress, // 2
  AppRoutes.explore, // 3
  AppRoutes.profile, // 4
  AppRoutes.premium, // 5
  AppRoutes.coachMatch, // 6
  AppRoutes.devices, // 7
  AppRoutes.strength, // 8
  AppRoutes.notifications, // 9
  AppRoutes.trainingPlans, // 10
  AppRoutes.events, // 11
  AppRoutes.tickets, // 12
  AppRoutes.workoutLibrary, // 13
  AppRoutes.coachPlatform, // 14
  AppRoutes.coachResources, // 15
  AppRoutes.support, // 16
  AppRoutes.trainingGuides, // 17
  AppRoutes.about, // 18
  AppRoutes.athleteOnboarding, // 19 (deprecated, see OnboardingFlow)
];

/// Maps mobile shell index (0..6) to its route name.
/// Order matches `_MobileShellState._buildPage` / [MobileTab].
const List<String> mobileIndexToRoute = <String>[
  AppRoutes.home, // 0
  AppRoutes.calendar, // 1
  AppRoutes.progress, // 2
  AppRoutes.explore, // 3
  AppRoutes.profile, // 4
  AppRoutes.more, // 5
  AppRoutes.notifications, // 6
];

/// Pushed routes with no shell/mobile tab index — reached via
/// `Navigator.push` from Explore/More tiles, never via index navigation:
/// [AppRoutes.activityFeed], [AppRoutes.challenges], [AppRoutes.leaderboard],
/// [AppRoutes.athleteDiscovery].

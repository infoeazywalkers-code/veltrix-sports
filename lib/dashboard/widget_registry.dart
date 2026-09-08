import 'package:flutter/material.dart';

/// Identifiers for all available dashboard widgets.
class DashboardWidgetId {
  DashboardWidgetId._();

  static const String heroVideo = 'hero_video';
  static const String todayTraining = 'today_training';
  static const String trainingStatus = 'training_status';
  static const String weekSummary = 'week_summary';
  static const String upcomingEvents = 'upcoming_events';
  static const String coachNote = 'coach_note';
  static const String quickStats = 'quick_stats';
  static const String recentWorkouts = 'recent_workouts';
  static const String motivationalQuote = 'motivational_quote';

  /// All available widget IDs with display labels.
  static const Map<String, String> allWidgets = {
    heroVideo: 'Hero Video',
    todayTraining: "Today's Training",
    trainingStatus: 'Training Status',
    weekSummary: 'Week Summary',
    upcomingEvents: 'Upcoming Events',
    coachNote: 'Coach Note',
    quickStats: 'Quick Stats',
    recentWorkouts: 'Recent Workouts',
    motivationalQuote: 'Motivational Quote',
  };

  /// Default order for widgets.
  static const List<String> defaultOrder = [
    heroVideo,
    todayTraining,
    trainingStatus,
    weekSummary,
    upcomingEvents,
    coachNote,
  ];

  /// Default set of visible widgets.
  static const List<String> defaultVisible = [
    heroVideo,
    todayTraining,
    trainingStatus,
    weekSummary,
    coachNote,
  ];
}

/// A builder function that creates a widget for a dashboard slot.
typedef DashboardWidgetBuilder = Widget Function(BuildContext context);

/// Registry mapping widget IDs to their builders.
class WidgetRegistry {
  WidgetRegistry._();

  static final Map<String, DashboardWidgetBuilder> _builders = {};

  /// Registers a widget builder for a given ID.
  static void register(String id, DashboardWidgetBuilder builder) {
    _builders[id] = builder;
  }

  /// Returns the builder for the given ID, or null if not registered.
  static DashboardWidgetBuilder? getBuilder(String id) {
    return _builders[id];
  }

  /// Returns all registered widget IDs.
  static List<String> get registeredIds => _builders.keys.toList();

  /// Checks if a widget ID is registered.
  static bool isRegistered(String id) => _builders.containsKey(id);
}

/// Pre-defined motivational quotes for the dashboard.
class MotivationalQuotes {
  MotivationalQuotes._();

  static const List<String> quotes = [
    "The only bad workout is the one that didn't happen.",
    "Strength does not come from the body. It comes from the will.",
    "The difference between the impossible and the possible lies in a person's determination.",
    "Success is walking from failure to failure with no loss of enthusiasm.",
    "The harder you work, the luckier you get.",
    "Don't count the days. Make the days count.",
    "The pain you feel today will be the strength you feel tomorrow.",
    "Your body can stand almost anything. It's your mind that you have to convince.",
  ];

  static String get random {
    final index = DateTime.now().millisecondsSinceEpoch % quotes.length;
    return quotes[index];
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';

// ---------------------------------------------------------------------------
// Enums
// ---------------------------------------------------------------------------

enum UnitSystem { metric, imperial }

enum PaceFormat { minPerKm, minPerMile }

enum ThemeModePreference { light, dark, system }

enum ExperienceLevel { beginner, intermediate, advanced, elite }

enum HrCalculationMethod { manual, formula220Age, formula220_07Age, karvonen }

// ---------------------------------------------------------------------------
// PhysicalProfile
// ---------------------------------------------------------------------------

class PhysicalProfile {
  final DateTime? dateOfBirth;
  final double? weightKg;
  final double? heightCm;
  final int? maxHeartRate;
  final int? restingHeartRate;
  final HrCalculationMethod hrCalculationMethod;

  const PhysicalProfile({
    this.dateOfBirth,
    this.weightKg,
    this.heightCm,
    this.maxHeartRate,
    this.restingHeartRate,
    this.hrCalculationMethod = HrCalculationMethod.formula220Age,
  });

  /// Returns the user's age in whole years, or null if date of birth is unset.
  int? get age {
    if (dateOfBirth == null) return null;
    final now = DateTime.now();
    int years = now.year - dateOfBirth!.year;
    if (now.month < dateOfBirth!.month ||
        (now.month == dateOfBirth!.month && now.day < dateOfBirth!.day)) {
      years--;
    }
    return years;
  }

  /// Calculates max HR using the configured method.
  /// Returns the manually-entered value when method is [HrCalculationMethod.manual]
  /// or when age cannot be determined for formula-based methods.
  int get calculatedMaxHr {
    switch (hrCalculationMethod) {
      case HrCalculationMethod.manual:
        return maxHeartRate ?? 190;
      case HrCalculationMethod.formula220Age:
        final a = age;
        if (a == null) return maxHeartRate ?? 190;
        return 220 - a;
      case HrCalculationMethod.formula220_07Age:
        final a = age;
        if (a == null) return maxHeartRate ?? 190;
        return (220 - 0.7 * a).round();
      case HrCalculationMethod.karvonen:
        // Karvonen formula typically uses resting HR, but here we use it
        // as an alternative max-HR estimate: 208 - 0.7 * age
        final a = age;
        if (a == null) return maxHeartRate ?? 190;
        return (208 - 0.7 * a).round();
    }
  }

  factory PhysicalProfile.fromMap(Map<String, dynamic> m) => PhysicalProfile(
    dateOfBirth: (m['dateOfBirth'] as Timestamp?)?.toDate(),
    weightKg: (m['weightKg'] as num?)?.toDouble(),
    heightCm: (m['heightCm'] as num?)?.toDouble(),
    maxHeartRate: (m['maxHeartRate'] as num?)?.toInt(),
    restingHeartRate: (m['restingHeartRate'] as num?)?.toInt(),
    hrCalculationMethod: HrCalculationMethod.values.firstWhere(
      (v) => v.name == m['hrCalculationMethod'],
      orElse: () => HrCalculationMethod.formula220Age,
    ),
  );

  Map<String, dynamic> toMap() => {
    'dateOfBirth':
        dateOfBirth != null ? Timestamp.fromDate(dateOfBirth!) : null,
    'weightKg': weightKg,
    'heightCm': heightCm,
    'maxHeartRate': maxHeartRate,
    'restingHeartRate': restingHeartRate,
    'hrCalculationMethod': hrCalculationMethod.name,
  };

  PhysicalProfile copyWith({
    DateTime? dateOfBirth,
    bool clearDateOfBirth = false,
    double? weightKg,
    bool clearWeightKg = false,
    double? heightCm,
    bool clearHeightCm = false,
    int? maxHeartRate,
    bool clearMaxHeartRate = false,
    int? restingHeartRate,
    bool clearRestingHeartRate = false,
    HrCalculationMethod? hrCalculationMethod,
  }) => PhysicalProfile(
    dateOfBirth: clearDateOfBirth ? null : (dateOfBirth ?? this.dateOfBirth),
    weightKg: clearWeightKg ? null : (weightKg ?? this.weightKg),
    heightCm: clearHeightCm ? null : (heightCm ?? this.heightCm),
    maxHeartRate:
        clearMaxHeartRate ? null : (maxHeartRate ?? this.maxHeartRate),
    restingHeartRate:
        clearRestingHeartRate
            ? null
            : (restingHeartRate ?? this.restingHeartRate),
    hrCalculationMethod: hrCalculationMethod ?? this.hrCalculationMethod,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PhysicalProfile &&
          other.dateOfBirth == dateOfBirth &&
          other.weightKg == weightKg &&
          other.heightCm == heightCm &&
          other.maxHeartRate == maxHeartRate &&
          other.restingHeartRate == restingHeartRate &&
          other.hrCalculationMethod == hrCalculationMethod;

  @override
  int get hashCode => Object.hash(
    dateOfBirth,
    weightKg,
    heightCm,
    maxHeartRate,
    restingHeartRate,
    hrCalculationMethod,
  );
}

// ---------------------------------------------------------------------------
// SportProfile
// ---------------------------------------------------------------------------

class SportProfile {
  final String primarySport;
  final List<String> secondarySports;
  final ExperienceLevel experienceLevel;
  final int? yearsExperience;

  const SportProfile({
    this.primarySport = '',
    this.secondarySports = const [],
    this.experienceLevel = ExperienceLevel.beginner,
    this.yearsExperience,
  });

  factory SportProfile.fromMap(Map<String, dynamic> m) => SportProfile(
    primarySport: m['primarySport'] as String? ?? '',
    secondarySports: (m['secondarySports'] as List? ?? []).cast<String>(),
    experienceLevel: ExperienceLevel.values.firstWhere(
      (v) => v.name == m['experienceLevel'],
      orElse: () => ExperienceLevel.beginner,
    ),
    yearsExperience: (m['yearsExperience'] as num?)?.toInt(),
  );

  Map<String, dynamic> toMap() => {
    'primarySport': primarySport,
    'secondarySports': secondarySports,
    'experienceLevel': experienceLevel.name,
    'yearsExperience': yearsExperience,
  };

  SportProfile copyWith({
    String? primarySport,
    List<String>? secondarySports,
    ExperienceLevel? experienceLevel,
    int? yearsExperience,
    bool clearYearsExperience = false,
  }) => SportProfile(
    primarySport: primarySport ?? this.primarySport,
    secondarySports: secondarySports ?? this.secondarySports,
    experienceLevel: experienceLevel ?? this.experienceLevel,
    yearsExperience:
        clearYearsExperience ? null : (yearsExperience ?? this.yearsExperience),
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SportProfile &&
          other.primarySport == primarySport &&
          _listEquals(other.secondarySports, secondarySports) &&
          other.experienceLevel == experienceLevel &&
          other.yearsExperience == yearsExperience;

  @override
  int get hashCode => Object.hash(
    primarySport,
    Object.hashAll(secondarySports),
    experienceLevel,
    yearsExperience,
  );
}

// ---------------------------------------------------------------------------
// TargetEvent
// ---------------------------------------------------------------------------

class TargetEvent {
  final String name;
  final DateTime date;
  final String? distance;

  const TargetEvent({required this.name, required this.date, this.distance});

  /// Returns the number of days from now until this event (negative if past).
  int get daysUntil => date.difference(DateTime.now()).inDays;

  factory TargetEvent.fromMap(Map<String, dynamic> m) => TargetEvent(
    name: m['name'] as String? ?? '',
    date: (m['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
    distance: m['distance'] as String?,
  );

  Map<String, dynamic> toMap() => {
    'name': name,
    'date': Timestamp.fromDate(date),
    'distance': distance,
  };

  TargetEvent copyWith({
    String? name,
    DateTime? date,
    String? distance,
    bool clearDistance = false,
  }) => TargetEvent(
    name: name ?? this.name,
    date: date ?? this.date,
    distance: clearDistance ? null : (distance ?? this.distance),
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TargetEvent &&
          other.name == name &&
          other.date == date &&
          other.distance == distance;

  @override
  int get hashCode => Object.hash(name, date, distance);
}

// ---------------------------------------------------------------------------
// TrainingGoals
// ---------------------------------------------------------------------------

class TrainingGoals {
  final List<TargetEvent> targetEvents;
  final List<String> performanceGoals;
  final int? weeklyHoursTarget;

  const TrainingGoals({
    this.targetEvents = const [],
    this.performanceGoals = const [],
    this.weeklyHoursTarget,
  });

  factory TrainingGoals.fromMap(Map<String, dynamic> m) => TrainingGoals(
    targetEvents:
        (m['targetEvents'] as List? ?? [])
            .map((e) => TargetEvent.fromMap(e as Map<String, dynamic>))
            .toList(),
    performanceGoals: (m['performanceGoals'] as List? ?? []).cast<String>(),
    weeklyHoursTarget: (m['weeklyHoursTarget'] as num?)?.toInt(),
  );

  Map<String, dynamic> toMap() => {
    'targetEvents': targetEvents.map((e) => e.toMap()).toList(),
    'performanceGoals': performanceGoals,
    'weeklyHoursTarget': weeklyHoursTarget,
  };

  TrainingGoals copyWith({
    List<TargetEvent>? targetEvents,
    List<String>? performanceGoals,
    int? weeklyHoursTarget,
    bool clearWeeklyHoursTarget = false,
  }) => TrainingGoals(
    targetEvents: targetEvents ?? this.targetEvents,
    performanceGoals: performanceGoals ?? this.performanceGoals,
    weeklyHoursTarget:
        clearWeeklyHoursTarget
            ? null
            : (weeklyHoursTarget ?? this.weeklyHoursTarget),
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TrainingGoals &&
          _listEquals(other.targetEvents, targetEvents) &&
          _listEquals(other.performanceGoals, performanceGoals) &&
          other.weeklyHoursTarget == weeklyHoursTarget;

  @override
  int get hashCode => Object.hash(
    Object.hashAll(targetEvents),
    Object.hashAll(performanceGoals),
    weeklyHoursTarget,
  );
}

// ---------------------------------------------------------------------------
// SchedulePreferences
// ---------------------------------------------------------------------------

class SchedulePreferences {
  /// Days of the week the user is available (1=Mon .. 7=Sun).
  final List<int> availableDays;

  /// Explicit rest days (1=Mon .. 7=Sun).
  final List<int> restDays;

  /// Day of the week reserved for the long workout (1=Mon .. 7=Sun).
  final int longWorkoutDay;

  const SchedulePreferences({
    this.availableDays = const [1, 2, 3, 4, 5, 6, 7],
    this.restDays = const [7],
    this.longWorkoutDay = 6,
  });

  factory SchedulePreferences.fromMap(Map<String, dynamic> m) =>
      SchedulePreferences(
        availableDays: (m['availableDays'] as List? ?? []).cast<int>(),
        restDays: (m['restDays'] as List? ?? []).cast<int>(),
        longWorkoutDay: (m['longWorkoutDay'] as num?)?.toInt() ?? 6,
      );

  Map<String, dynamic> toMap() => {
    'availableDays': availableDays,
    'restDays': restDays,
    'longWorkoutDay': longWorkoutDay,
  };

  SchedulePreferences copyWith({
    List<int>? availableDays,
    List<int>? restDays,
    int? longWorkoutDay,
  }) => SchedulePreferences(
    availableDays: availableDays ?? this.availableDays,
    restDays: restDays ?? this.restDays,
    longWorkoutDay: longWorkoutDay ?? this.longWorkoutDay,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SchedulePreferences &&
          _listEquals(other.availableDays, availableDays) &&
          _listEquals(other.restDays, restDays) &&
          other.longWorkoutDay == longWorkoutDay;

  @override
  int get hashCode => Object.hash(
    Object.hashAll(availableDays),
    Object.hashAll(restDays),
    longWorkoutDay,
  );
}

// ---------------------------------------------------------------------------
// HeartRateZone & HeartRateZones
// ---------------------------------------------------------------------------

class HeartRateZone {
  final String label;
  final int min;
  final int max;

  const HeartRateZone({
    required this.label,
    required this.min,
    required this.max,
  });

  factory HeartRateZone.fromMap(Map<String, dynamic> m) => HeartRateZone(
    label: m['label'] as String? ?? '',
    min: (m['min'] as num?)?.toInt() ?? 0,
    max: (m['max'] as num?)?.toInt() ?? 0,
  );

  Map<String, dynamic> toMap() => {'label': label, 'min': min, 'max': max};

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HeartRateZone &&
          other.label == label &&
          other.min == min &&
          other.max == max;

  @override
  int get hashCode => Object.hash(label, min, max);
}

class HeartRateZones {
  final String method;
  final List<HeartRateZone> zones;

  const HeartRateZones({required this.method, required this.zones});

  /// Generates standard 5-zone model from a known max HR.
  factory HeartRateZones.autoFromMaxHr(int maxHr) => HeartRateZones(
    method: 'auto',
    zones: [
      HeartRateZone(
        label: 'Recovery',
        min: (maxHr * 0.50).round(),
        max: (maxHr * 0.60).round(),
      ),
      HeartRateZone(
        label: 'Aerobic',
        min: (maxHr * 0.60).round(),
        max: (maxHr * 0.70).round(),
      ),
      HeartRateZone(
        label: 'Tempo',
        min: (maxHr * 0.70).round(),
        max: (maxHr * 0.80).round(),
      ),
      HeartRateZone(
        label: 'Threshold',
        min: (maxHr * 0.80).round(),
        max: (maxHr * 0.90).round(),
      ),
      HeartRateZone(label: 'VO2max', min: (maxHr * 0.90).round(), max: maxHr),
    ],
  );

  factory HeartRateZones.fromMap(Map<String, dynamic> m) => HeartRateZones(
    method: m['method'] as String? ?? 'auto',
    zones:
        (m['zones'] as List? ?? [])
            .map((z) => HeartRateZone.fromMap(z as Map<String, dynamic>))
            .toList(),
  );

  Map<String, dynamic> toMap() => {
    'method': method,
    'zones': zones.map((z) => z.toMap()).toList(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HeartRateZones &&
          other.method == method &&
          _listEquals(other.zones, zones);

  @override
  int get hashCode => Object.hash(method, Object.hashAll(zones));
}

// ---------------------------------------------------------------------------
// DisplayPreferences
// ---------------------------------------------------------------------------

class DisplayPreferences {
  final UnitSystem unitSystem;
  final PaceFormat paceFormat;

  /// 1=Mon, 7=Sun
  final int weekStartsOn;

  const DisplayPreferences({
    this.unitSystem = UnitSystem.metric,
    this.paceFormat = PaceFormat.minPerKm,
    this.weekStartsOn = 1,
  });

  factory DisplayPreferences.fromMap(Map<String, dynamic> m) =>
      DisplayPreferences(
        unitSystem: UnitSystem.values.firstWhere(
          (v) => v.name == m['unitSystem'],
          orElse: () => UnitSystem.metric,
        ),
        paceFormat: PaceFormat.values.firstWhere(
          (v) => v.name == m['paceFormat'],
          orElse: () => PaceFormat.minPerKm,
        ),
        weekStartsOn: (m['weekStartsOn'] as num?)?.toInt() ?? 1,
      );

  Map<String, dynamic> toMap() => {
    'unitSystem': unitSystem.name,
    'paceFormat': paceFormat.name,
    'weekStartsOn': weekStartsOn,
  };

  DisplayPreferences copyWith({
    UnitSystem? unitSystem,
    PaceFormat? paceFormat,
    int? weekStartsOn,
  }) => DisplayPreferences(
    unitSystem: unitSystem ?? this.unitSystem,
    paceFormat: paceFormat ?? this.paceFormat,
    weekStartsOn: weekStartsOn ?? this.weekStartsOn,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DisplayPreferences &&
          other.unitSystem == unitSystem &&
          other.paceFormat == paceFormat &&
          other.weekStartsOn == weekStartsOn;

  @override
  int get hashCode => Object.hash(unitSystem, paceFormat, weekStartsOn);
}

// ---------------------------------------------------------------------------
// ThemePreferences
// ---------------------------------------------------------------------------

class ThemePreferences {
  final ThemeModePreference mode;
  final String? accentColor;

  const ThemePreferences({
    this.mode = ThemeModePreference.system,
    this.accentColor,
  });

  factory ThemePreferences.fromMap(Map<String, dynamic> m) => ThemePreferences(
    mode: ThemeModePreference.values.firstWhere(
      (v) => v.name == m['mode'],
      orElse: () => ThemeModePreference.system,
    ),
    accentColor: m['accentColor'] as String?,
  );

  Map<String, dynamic> toMap() => {
    'mode': mode.name,
    'accentColor': accentColor,
  };

  ThemePreferences copyWith({
    ThemeModePreference? mode,
    String? accentColor,
    bool clearAccentColor = false,
  }) => ThemePreferences(
    mode: mode ?? this.mode,
    accentColor: clearAccentColor ? null : (accentColor ?? this.accentColor),
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ThemePreferences &&
          other.mode == mode &&
          other.accentColor == accentColor;

  @override
  int get hashCode => Object.hash(mode, accentColor);
}

// ---------------------------------------------------------------------------
// NotificationPreferences
// ---------------------------------------------------------------------------

class NotificationPreferences {
  final bool workoutReminders;
  final int reminderMinutesBefore;
  final bool coachMessages;
  final bool weeklySummary;
  final bool achievements;
  final bool quietHoursEnabled;
  final String quietHoursStart;
  final String quietHoursEnd;

  const NotificationPreferences({
    this.workoutReminders = true,
    this.reminderMinutesBefore = 30,
    this.coachMessages = true,
    this.weeklySummary = true,
    this.achievements = true,
    this.quietHoursEnabled = false,
    this.quietHoursStart = '22:00',
    this.quietHoursEnd = '07:00',
  });

  factory NotificationPreferences.fromMap(Map<String, dynamic> m) =>
      NotificationPreferences(
        workoutReminders: m['workoutReminders'] as bool? ?? true,
        reminderMinutesBefore:
            (m['reminderMinutesBefore'] as num?)?.toInt() ?? 30,
        coachMessages: m['coachMessages'] as bool? ?? true,
        weeklySummary: m['weeklySummary'] as bool? ?? true,
        achievements: m['achievements'] as bool? ?? true,
        quietHoursEnabled: m['quietHoursEnabled'] as bool? ?? false,
        quietHoursStart: m['quietHoursStart'] as String? ?? '22:00',
        quietHoursEnd: m['quietHoursEnd'] as String? ?? '07:00',
      );

  Map<String, dynamic> toMap() => {
    'workoutReminders': workoutReminders,
    'reminderMinutesBefore': reminderMinutesBefore,
    'coachMessages': coachMessages,
    'weeklySummary': weeklySummary,
    'achievements': achievements,
    'quietHoursEnabled': quietHoursEnabled,
    'quietHoursStart': quietHoursStart,
    'quietHoursEnd': quietHoursEnd,
  };

  NotificationPreferences copyWith({
    bool? workoutReminders,
    int? reminderMinutesBefore,
    bool? coachMessages,
    bool? weeklySummary,
    bool? achievements,
    bool? quietHoursEnabled,
    String? quietHoursStart,
    String? quietHoursEnd,
  }) => NotificationPreferences(
    workoutReminders: workoutReminders ?? this.workoutReminders,
    reminderMinutesBefore: reminderMinutesBefore ?? this.reminderMinutesBefore,
    coachMessages: coachMessages ?? this.coachMessages,
    weeklySummary: weeklySummary ?? this.weeklySummary,
    achievements: achievements ?? this.achievements,
    quietHoursEnabled: quietHoursEnabled ?? this.quietHoursEnabled,
    quietHoursStart: quietHoursStart ?? this.quietHoursStart,
    quietHoursEnd: quietHoursEnd ?? this.quietHoursEnd,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NotificationPreferences &&
          other.workoutReminders == workoutReminders &&
          other.reminderMinutesBefore == reminderMinutesBefore &&
          other.coachMessages == coachMessages &&
          other.weeklySummary == weeklySummary &&
          other.achievements == achievements &&
          other.quietHoursEnabled == quietHoursEnabled &&
          other.quietHoursStart == quietHoursStart &&
          other.quietHoursEnd == quietHoursEnd;

  @override
  int get hashCode => Object.hash(
    workoutReminders,
    reminderMinutesBefore,
    coachMessages,
    weeklySummary,
    achievements,
    quietHoursEnabled,
    quietHoursStart,
    quietHoursEnd,
  );
}

// ---------------------------------------------------------------------------
// DashboardPreferences
// ---------------------------------------------------------------------------

class DashboardPreferences {
  final List<String> visibleWidgets;
  final List<String> widgetOrder;

  /// 'minimal', 'standard', or 'detailed'
  final String layout;

  const DashboardPreferences({
    this.visibleWidgets = const [],
    this.widgetOrder = const [],
    this.layout = 'standard',
  });

  factory DashboardPreferences.fromMap(Map<String, dynamic> m) =>
      DashboardPreferences(
        visibleWidgets: (m['visibleWidgets'] as List? ?? []).cast<String>(),
        widgetOrder: (m['widgetOrder'] as List? ?? []).cast<String>(),
        layout: m['layout'] as String? ?? 'standard',
      );

  Map<String, dynamic> toMap() => {
    'visibleWidgets': visibleWidgets,
    'widgetOrder': widgetOrder,
    'layout': layout,
  };

  DashboardPreferences copyWith({
    List<String>? visibleWidgets,
    List<String>? widgetOrder,
    String? layout,
  }) => DashboardPreferences(
    visibleWidgets: visibleWidgets ?? this.visibleWidgets,
    widgetOrder: widgetOrder ?? this.widgetOrder,
    layout: layout ?? this.layout,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DashboardPreferences &&
          _listEquals(other.visibleWidgets, visibleWidgets) &&
          _listEquals(other.widgetOrder, widgetOrder) &&
          other.layout == layout;

  @override
  int get hashCode => Object.hash(
    Object.hashAll(visibleWidgets),
    Object.hashAll(widgetOrder),
    layout,
  );
}

// ---------------------------------------------------------------------------
// PrivacyPreferences
// ---------------------------------------------------------------------------

class PrivacyPreferences {
  final bool profileVisibleToCoaches;
  final bool activityFeedVisible;
  final bool shareLocationInWorkouts;
  final bool showOnLeaderboards;
  final bool allowCoachDataAccess;
  final bool analyticsEnabled;

  const PrivacyPreferences({
    this.profileVisibleToCoaches = true,
    this.activityFeedVisible = true,
    this.shareLocationInWorkouts = true,
    this.showOnLeaderboards = true,
    this.allowCoachDataAccess = true,
    this.analyticsEnabled = true,
  });

  factory PrivacyPreferences.fromMap(Map<String, dynamic> map) {
    return PrivacyPreferences(
      profileVisibleToCoaches: map['profileVisibleToCoaches'] as bool? ?? true,
      activityFeedVisible: map['activityFeedVisible'] as bool? ?? true,
      shareLocationInWorkouts: map['shareLocationInWorkouts'] as bool? ?? true,
      showOnLeaderboards: map['showOnLeaderboards'] as bool? ?? true,
      allowCoachDataAccess: map['allowCoachDataAccess'] as bool? ?? true,
      analyticsEnabled: map['analyticsEnabled'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'profileVisibleToCoaches': profileVisibleToCoaches,
      'activityFeedVisible': activityFeedVisible,
      'shareLocationInWorkouts': shareLocationInWorkouts,
      'showOnLeaderboards': showOnLeaderboards,
      'allowCoachDataAccess': allowCoachDataAccess,
      'analyticsEnabled': analyticsEnabled,
    };
  }

  PrivacyPreferences copyWith({
    bool? profileVisibleToCoaches,
    bool? activityFeedVisible,
    bool? shareLocationInWorkouts,
    bool? showOnLeaderboards,
    bool? allowCoachDataAccess,
    bool? analyticsEnabled,
  }) {
    return PrivacyPreferences(
      profileVisibleToCoaches:
          profileVisibleToCoaches ?? this.profileVisibleToCoaches,
      activityFeedVisible: activityFeedVisible ?? this.activityFeedVisible,
      shareLocationInWorkouts:
          shareLocationInWorkouts ?? this.shareLocationInWorkouts,
      showOnLeaderboards: showOnLeaderboards ?? this.showOnLeaderboards,
      allowCoachDataAccess: allowCoachDataAccess ?? this.allowCoachDataAccess,
      analyticsEnabled: analyticsEnabled ?? this.analyticsEnabled,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PrivacyPreferences &&
          runtimeType == other.runtimeType &&
          profileVisibleToCoaches == other.profileVisibleToCoaches &&
          activityFeedVisible == other.activityFeedVisible &&
          shareLocationInWorkouts == other.shareLocationInWorkouts &&
          showOnLeaderboards == other.showOnLeaderboards &&
          allowCoachDataAccess == other.allowCoachDataAccess &&
          analyticsEnabled == other.analyticsEnabled;

  @override
  int get hashCode => Object.hash(
    profileVisibleToCoaches,
    activityFeedVisible,
    shareLocationInWorkouts,
    showOnLeaderboards,
    allowCoachDataAccess,
    analyticsEnabled,
  );
}

// ---------------------------------------------------------------------------
// UserPreferences (root)
// ---------------------------------------------------------------------------

class UserPreferences {
  final int schemaVersion;
  final PhysicalProfile physical;
  final SportProfile sport;
  final TrainingGoals goals;
  final SchedulePreferences schedule;
  final HeartRateZones heartRateZones;
  final DisplayPreferences display;
  final ThemePreferences theme;
  final NotificationPreferences notifications;
  final DashboardPreferences dashboard;
  final PrivacyPreferences privacy;

  const UserPreferences({
    this.schemaVersion = 1,
    this.physical = const PhysicalProfile(),
    this.sport = const SportProfile(),
    this.goals = const TrainingGoals(),
    this.schedule = const SchedulePreferences(),
    this.heartRateZones = const HeartRateZones(method: 'auto', zones: []),
    this.display = const DisplayPreferences(),
    this.theme = const ThemePreferences(),
    this.notifications = const NotificationPreferences(),
    this.dashboard = const DashboardPreferences(),
    this.privacy = const PrivacyPreferences(),
  });

  /// Creates a default [UserPreferences] with HR zones auto-calculated from
  /// the given [maxHr].
  factory UserPreferences.defaultFor(int maxHr) =>
      UserPreferences(heartRateZones: HeartRateZones.autoFromMaxHr(maxHr));

  factory UserPreferences.fromMap(Map<String, dynamic> m) => UserPreferences(
    schemaVersion: (m['schemaVersion'] as num?)?.toInt() ?? 1,
    physical: PhysicalProfile.fromMap(
      (m['physical'] as Map<String, dynamic>?) ?? {},
    ),
    sport: SportProfile.fromMap((m['sport'] as Map<String, dynamic>?) ?? {}),
    goals: TrainingGoals.fromMap((m['goals'] as Map<String, dynamic>?) ?? {}),
    schedule: SchedulePreferences.fromMap(
      (m['schedule'] as Map<String, dynamic>?) ?? {},
    ),
    heartRateZones: HeartRateZones.fromMap(
      (m['heartRateZones'] as Map<String, dynamic>?) ?? {},
    ),
    display: DisplayPreferences.fromMap(
      (m['display'] as Map<String, dynamic>?) ?? {},
    ),
    theme: ThemePreferences.fromMap(
      (m['theme'] as Map<String, dynamic>?) ?? {},
    ),
    notifications: NotificationPreferences.fromMap(
      (m['notifications'] as Map<String, dynamic>?) ?? {},
    ),
    dashboard: DashboardPreferences.fromMap(
      (m['dashboard'] as Map<String, dynamic>?) ?? {},
    ),
    privacy: PrivacyPreferences.fromMap(
      (m['privacy'] as Map<String, dynamic>?) ?? {},
    ),
  );

  Map<String, dynamic> toMap() => {
    'schemaVersion': schemaVersion,
    'physical': physical.toMap(),
    'sport': sport.toMap(),
    'goals': goals.toMap(),
    'schedule': schedule.toMap(),
    'heartRateZones': heartRateZones.toMap(),
    'display': display.toMap(),
    'theme': theme.toMap(),
    'notifications': notifications.toMap(),
    'dashboard': dashboard.toMap(),
    'privacy': privacy.toMap(),
  };

  UserPreferences copyWith({
    int? schemaVersion,
    PhysicalProfile? physical,
    SportProfile? sport,
    TrainingGoals? goals,
    SchedulePreferences? schedule,
    HeartRateZones? heartRateZones,
    DisplayPreferences? display,
    ThemePreferences? theme,
    NotificationPreferences? notifications,
    DashboardPreferences? dashboard,
    PrivacyPreferences? privacy,
  }) => UserPreferences(
    schemaVersion: schemaVersion ?? this.schemaVersion,
    physical: physical ?? this.physical,
    sport: sport ?? this.sport,
    goals: goals ?? this.goals,
    schedule: schedule ?? this.schedule,
    heartRateZones: heartRateZones ?? this.heartRateZones,
    display: display ?? this.display,
    theme: theme ?? this.theme,
    notifications: notifications ?? this.notifications,
    dashboard: dashboard ?? this.dashboard,
    privacy: privacy ?? this.privacy,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserPreferences &&
          other.schemaVersion == schemaVersion &&
          other.physical == physical &&
          other.sport == sport &&
          other.goals == goals &&
          other.schedule == schedule &&
          other.heartRateZones == heartRateZones &&
          other.display == display &&
          other.theme == theme &&
          other.notifications == notifications &&
          other.dashboard == dashboard &&
          other.privacy == privacy;

  @override
  int get hashCode => Object.hash(
    schemaVersion,
    physical,
    sport,
    goals,
    schedule,
    heartRateZones,
    display,
    theme,
    notifications,
    dashboard,
    privacy,
  );
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Material-equality check for lists.
bool _listEquals<T>(List<T> a, List<T> b) {
  if (identical(a, b)) return true;
  if (a.length != b.length) return false;
  for (int i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}

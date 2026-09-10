import '../activity/activity.dart';

class LeaderboardAthlete {
  final String id;
  final String name;
  final String handle;
  final String avatar;
  final String location;
  final String country;
  final String flagEmoji;
  final String? team;
  final bool isCurrentUser;
  final bool isPro;
  final SportType primarySport;
  final double monthlyTSS;
  final double monthlyElevationMeters;
  final double monthlyDistanceKm;
  final double monthlyActiveHours;
  final int monthlyActivitiesCount;
  final int streakDays;
  final int? rankChange;
  final int? ftpWatts;
  final int kudosCount;
  final bool hasUserKudoed;
  final String? recentHighlight;

  const LeaderboardAthlete({
    required this.id,
    required this.name,
    required this.handle,
    required this.avatar,
    required this.location,
    required this.country,
    required this.flagEmoji,
    this.team,
    this.isCurrentUser = false,
    this.isPro = false,
    required this.primarySport,
    this.monthlyTSS = 0,
    this.monthlyElevationMeters = 0,
    this.monthlyDistanceKm = 0,
    this.monthlyActiveHours = 0,
    this.monthlyActivitiesCount = 0,
    this.streakDays = 0,
    this.rankChange,
    this.ftpWatts,
    this.kudosCount = 0,
    this.hasUserKudoed = false,
    this.recentHighlight,
  });

  factory LeaderboardAthlete.fromMap(Map<String, dynamic> m) =>
      LeaderboardAthlete(
        id: m['id'] ?? '',
        name: m['name'] ?? '',
        handle: m['handle'] ?? '',
        avatar: m['avatar'] ?? '',
        location: m['location'] ?? '',
        country: m['country'] ?? '',
        flagEmoji: m['flagEmoji'] ?? '',
        team: m['team'],
        isCurrentUser: m['isCurrentUser'] ?? false,
        isPro: m['isPro'] ?? false,
        primarySport: SportType.values.firstWhere(
          (e) => e.name == m['primarySport'],
          orElse: () => SportType.cycling,
        ),
        monthlyTSS: (m['monthlyTSS'] ?? 0).toDouble(),
        monthlyElevationMeters: (m['monthlyElevationMeters'] ?? 0).toDouble(),
        monthlyDistanceKm: (m['monthlyDistanceKm'] ?? 0).toDouble(),
        monthlyActiveHours: (m['monthlyActiveHours'] ?? 0).toDouble(),
        monthlyActivitiesCount: m['monthlyActivitiesCount'] ?? 0,
        streakDays: m['streakDays'] ?? 0,
        rankChange: m['rankChange'],
        ftpWatts: m['ftpWatts'],
        kudosCount: m['kudosCount'] ?? 0,
        hasUserKudoed: m['hasUserKudoed'] ?? false,
        recentHighlight: m['recentHighlight'],
      );

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'handle': handle,
    'avatar': avatar,
    'location': location,
    'country': country,
    'flagEmoji': flagEmoji,
    if (team != null) 'team': team,
    'isCurrentUser': isCurrentUser,
    'isPro': isPro,
    'primarySport': primarySport.name,
    'monthlyTSS': monthlyTSS,
    'monthlyElevationMeters': monthlyElevationMeters,
    'monthlyDistanceKm': monthlyDistanceKm,
    'monthlyActiveHours': monthlyActiveHours,
    'monthlyActivitiesCount': monthlyActivitiesCount,
    'streakDays': streakDays,
    if (rankChange != null) 'rankChange': rankChange,
    if (ftpWatts != null) 'ftpWatts': ftpWatts,
    'kudosCount': kudosCount,
    'hasUserKudoed': hasUserKudoed,
    if (recentHighlight != null) 'recentHighlight': recentHighlight,
  };

  String get rankChangeLabel {
    if (rankChange == null || rankChange == 0) return '';
    if (rankChange! > 0) return '+$rankChange';
    return '$rankChange';
  }
}

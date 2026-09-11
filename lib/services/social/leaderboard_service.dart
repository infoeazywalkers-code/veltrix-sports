import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/social/athlete_card.dart';

/// One ranked row on the monthly board.
///
/// Every row traces to real `activities` docs (current month) joined to a
/// real `athlete_directory/{uid}` card. No fabricated athletes.
class LeaderboardRow {
  final String userId;
  final String displayName;
  final String handle;
  final String? photoUrl;
  final String team;
  final String location;
  final String sport;
  final int monthlyTss;
  final double monthlyElevationM;
  final double monthlyDistanceKm;
  final int monthlyMinutes;
  final int activitiesCount;

  const LeaderboardRow({
    required this.userId,
    required this.displayName,
    required this.handle,
    this.photoUrl,
    this.team = '',
    this.location = '',
    this.sport = '',
    this.monthlyTss = 0,
    this.monthlyElevationM = 0,
    this.monthlyDistanceKm = 0,
    this.monthlyMinutes = 0,
    this.activitiesCount = 0,
  });
}

/// Client-side monthly aggregation over real activity data.
///
/// Phase 2: capped at [limit] docs per snapshot event (default 200), all
/// aggregation is O(docs). Server-side aggregation is the Phase-4 path.
class LeaderboardService {
  final FirebaseFirestore _db;

  LeaderboardService({FirebaseFirestore? db})
    : _db = db ?? FirebaseFirestore.instance;

  /// Watches the current-month board, sorted by total TSS desc.
  ///
  /// Reads `activities` where `date >= monthStart` (limit 200, snapshots for
  /// liveness — existing reads, no new rules/indexes), groups by `userId`,
  /// and joins each id to `athlete_directory/{uid}`. Ids with no card or
  /// with `showOnLeaderboards == false` are skipped.
  Stream<List<LeaderboardRow>> watchMonthlyBoard({int limit = 200}) {
    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month, 1);
    try {
      return _db
          .collection('activities')
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(monthStart))
          .limit(limit)
          .snapshots()
          .asyncMap((snap) => _buildRows(snap))
          .handleError((Object e) {
            throw Exception('Failed to load leaderboard: $e');
          });
    } catch (e) {
      throw Exception('Failed to load leaderboard: $e');
    }
  }

  Future<List<LeaderboardRow>> _buildRows(
    QuerySnapshot<Map<String, dynamic>> snap,
  ) async {
    try {
      final Map<String, _Agg> agg = {};
      for (final doc in snap.docs) {
        final data = doc.data();
        final userId = (data['userId'] as String?) ?? '';
        if (userId.isEmpty) continue;
        final entry = agg.putIfAbsent(userId, () => _Agg(sportCounts: {}));
        entry.tss += _toInt(data['tss']);
        entry.elevationM += _toDouble(data['elevationGainMeters']);
        entry.distanceKm += _toDouble(data['distanceKm']);
        entry.minutes += _minutesFor(data);
        entry.count += 1;
        final sport = (data['sport'] as String?) ?? '';
        if (sport.isNotEmpty) {
          entry.sportCounts[sport] = (entry.sportCounts[sport] ?? 0) + 1;
        }
      }
      if (agg.isEmpty) return const <LeaderboardRow>[];

      final ids = agg.keys.toList();
      final cards = await Future.wait(ids.map(_fetchCard));

      final rows = <LeaderboardRow>[];
      for (var i = 0; i < ids.length; i++) {
        final card = cards[i];
        if (card == null || !card.showOnLeaderboards) continue;
        final a = agg[ids[i]]!;
        final dominantSport = _dominantSport(a.sportCounts);
        final sport =
            card.sports.isNotEmpty ? card.sports.first : dominantSport;
        rows.add(
          LeaderboardRow(
            userId: ids[i],
            displayName:
                card.displayName.isNotEmpty ? card.displayName : 'Athlete',
            handle: card.handle,
            photoUrl: card.photoUrl,
            team: card.team,
            location: card.location,
            sport: sport,
            monthlyTss: a.tss,
            monthlyElevationM: a.elevationM,
            monthlyDistanceKm: a.distanceKm,
            monthlyMinutes: a.minutes,
            activitiesCount: a.count,
          ),
        );
      }
      rows.sort((a, b) => b.monthlyTss.compareTo(a.monthlyTss));
      return rows;
    } catch (e) {
      throw Exception('Failed to load leaderboard: $e');
    }
  }

  Future<AthleteCard?> _fetchCard(String uid) async {
    try {
      final doc = await _db.collection('athlete_directory').doc(uid).get();
      if (!doc.exists || doc.data() == null) return null;
      return AthleteCard.fromMap(doc.id, doc.data()!);
    } catch (_) {
      return null;
    }
  }

  String _dominantSport(Map<String, int> counts) {
    if (counts.isEmpty) return '';
    var best = '';
    var bestCount = -1;
    counts.forEach((sport, count) {
      if (count > bestCount) {
        bestCount = count;
        best = sport;
      }
    });
    return best;
  }
}

class _Agg {
  int tss = 0;
  double elevationM = 0;
  double distanceKm = 0;
  int minutes = 0;
  int count = 0;
  final Map<String, int> sportCounts;

  _Agg({required this.sportCounts});
}

int _toInt(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value.trim()) ?? 0;
  return 0;
}

double _toDouble(Object? value) {
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value.trim()) ?? 0;
  return 0;
}

/// Active minutes for one raw activity doc.
///
/// Prefers `durationSeconds` / `movingTimeSeconds` ints; falls back to
/// parsing a legacy `duration` string ("1h 05 min" pattern from
/// providers/week_card) with best-effort int parsing.
int _minutesFor(Map<String, dynamic> data) {
  try {
    final seconds = data['durationSeconds'];
    if (seconds is num && seconds > 0) return (seconds / 60).floor();
    final moving = data['movingTimeSeconds'];
    if (moving is num && moving > 0) return (moving / 60).floor();
    final raw = data['duration'];
    if (raw is num && raw > 0) {
      // Heuristic: large values are seconds, small values are minutes.
      if (raw >= 600) return (raw / 60).floor();
      return raw.toInt();
    }
    if (raw is String) return _parseDurationMinutes(raw);
    return 0;
  } catch (_) {
    return 0;
  }
}

/// Parses "45 min", "1h 05 min", plain "45" into minutes (week_card pattern).
int _parseDurationMinutes(String duration) {
  try {
    final trimmed = duration.trim().toLowerCase();
    var totalMinutes = 0;
    final hourMatch = RegExp(r'(\d+)\s*h').firstMatch(trimmed);
    if (hourMatch != null) {
      totalMinutes += int.parse(hourMatch.group(1)!) * 60;
    }
    final minMatch = RegExp(r'(\d+)\s*min').firstMatch(trimmed);
    if (minMatch != null) {
      totalMinutes += int.parse(minMatch.group(1)!);
    }
    if (totalMinutes == 0) {
      final plainMatch = RegExp(r'^(\d+)$').firstMatch(trimmed);
      if (plainMatch != null) {
        totalMinutes = int.parse(plainMatch.group(1)!);
      }
    }
    return totalMinutes;
  } catch (_) {
    return 0;
  }
}

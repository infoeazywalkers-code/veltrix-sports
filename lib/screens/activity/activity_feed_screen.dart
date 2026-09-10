import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/activity/activity.dart';
import '../../services/activity/activity_service.dart';
import '../../core/utils/unit_conversion.dart';
import '../../providers.dart' show unitSystemProvider;

final activityServiceProvider = Provider<ActivityService>(
  (_) => ActivityService(),
);

final activitiesStreamProvider = StreamProvider<List<Activity>>((ref) {
  return ref.watch(activityServiceProvider).watchActivities();
});

class ActivityFeedScreen extends ConsumerStatefulWidget {
  const ActivityFeedScreen({super.key});

  @override
  ConsumerState<ActivityFeedScreen> createState() => _ActivityFeedScreenState();
}

class _ActivityFeedScreenState extends ConsumerState<ActivityFeedScreen> {
  @override
  Widget build(BuildContext context) {
    final activitiesAsync = ref.watch(activitiesStreamProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: activitiesAsync.when(
        data: (activities) {
          if (activities.isEmpty) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.run_circle_outlined,
                    size: 64,
                    color: Colors.white24,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No activities yet',
                    style: TextStyle(color: Colors.white54, fontSize: 16),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Record your first workout to see it here',
                    style: TextStyle(color: Colors.white38, fontSize: 13),
                  ),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: activities.length,
            itemBuilder:
                (context, index) => _ActivityCard(activity: activities[index]),
          );
        },
        loading:
            () => const Center(
              child: CircularProgressIndicator(color: Color(0xFFF97316)),
            ),
        error:
            (e, _) => Center(
              child: Text(
                'Error: $e',
                style: const TextStyle(color: Colors.red),
              ),
            ),
      ),
    );
  }
}

class _ActivityCard extends ConsumerWidget {
  final Activity activity;
  const _ActivityCard({required this.activity});

  String _sportIcon(SportType sport) {
    switch (sport) {
      case SportType.cycling:
        return '🚴';
      case SportType.running:
        return '🏃';
      case SportType.trailRunning:
        return '⛰️';
      case SportType.gravel:
        return '🛤️';
      case SportType.rowing:
        return '🚣';
      case SportType.swimming:
        return '🏊';
    }
  }

  String _formatDuration(int seconds) {
    final h = seconds ~/ 3600;
    final m = (seconds % 3600) ~/ 60;
    final s = seconds % 60;
    if (h > 0) return '${h}h ${m}m';
    return '${m}m ${s}s';
  }

  String _formatPace(int secondsPerKm) {
    final m = secondsPerKm ~/ 60;
    final s = secondsPerKm % 60;
    return '$m:${s.toString().padLeft(2, '0')}/km';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final units = ref.watch(unitSystemProvider);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundImage:
                      activity.athleteAvatar.isNotEmpty
                          ? NetworkImage(activity.athleteAvatar)
                          : null,
                  backgroundColor: const Color(
                    0xFFF97316,
                  ).withValues(alpha: 0.2),
                  child:
                      activity.athleteAvatar.isEmpty
                          ? Text(
                            activity.athleteName.isNotEmpty
                                ? activity.athleteName[0].toUpperCase()
                                : '?',
                            style: const TextStyle(color: Color(0xFFF97316)),
                          )
                          : null,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        activity.athleteName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        '${_sportIcon(activity.sport)} ${activity.sport.name.toUpperCase()} · ${_timeAgo(activity.date)}',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.5),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                if (activity.tss > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF97316).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${activity.tss} TSS',
                      style: const TextStyle(
                        color: Color(0xFFF97316),
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Title
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
            child: Text(
              activity.title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ),

          if (activity.description != null && activity.description!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 6, 16, 0),
              child: Text(
                activity.description!,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.6),
                  fontSize: 12,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),

          // Stats Row
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Row(
              children: [
                _stat(
                  'Distance',
                  UnitConversion.formatDistance(units, activity.distanceKm),
                ),
                const SizedBox(width: 16),
                _stat('Duration', _formatDuration(activity.durationSeconds)),
                const SizedBox(width: 16),
                _stat(
                  'Elevation',
                  '+${UnitConversion.formatElevation(units, activity.elevationGainMeters)}',
                ),
                if (activity.avgPower != null) ...[
                  const SizedBox(width: 16),
                  _stat('Power', '${activity.avgPower}W'),
                ],
              ],
            ),
          ),

          // Pace/Speed
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 6, 16, 0),
            child: Row(
              children: [
                _stat(
                  'Avg Speed',
                  '${activity.avgSpeedKmh.toStringAsFixed(1)} km/h',
                ),
                const SizedBox(width: 16),
                if (activity.avgHeartRate != null)
                  _stat('Avg HR', '${activity.avgHeartRate} bpm'),
                if (activity.avgPaceSecondsPerKm > 0) ...[
                  const SizedBox(width: 16),
                  _stat('Pace', _formatPace(activity.avgPaceSecondsPerKm)),
                ],
              ],
            ),
          ),

          // Weather
          if (activity.weather != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Text('🌤️', style: TextStyle(fontSize: 12)),
                    const SizedBox(width: 6),
                    Text(
                      '${activity.weather!.tempC.round()}°C · ${activity.weather!.condition}',
                      style: const TextStyle(
                        color: Colors.white60,
                        fontSize: 11,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${activity.weather!.windKmh.round()} km/h wind',
                      style: const TextStyle(
                        color: Colors.white38,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // PR Badges
          if (activity.prBadges.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Wrap(
                spacing: 6,
                runSpacing: 4,
                children:
                    activity.prBadges
                        .map(
                          (pr) => Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(
                                0xFFFBBF24,
                              ).withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: const Color(
                                  0xFFFBBF24,
                                ).withValues(alpha: 0.3),
                              ),
                            ),
                            child: Text(
                              '🏆 $pr',
                              style: const TextStyle(
                                color: Color(0xFFFBBF24),
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        )
                        .toList(),
              ),
            ),

          // Actions
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
            child: Row(
              children: [
                _actionButton(
                  icon:
                      activity.userHasKudoed
                          ? Icons.favorite
                          : Icons.favorite_border,
                  label: '${activity.kudosCount}',
                  color:
                      activity.userHasKudoed
                          ? const Color(0xFFEF4444)
                          : Colors.white54,
                ),
                const SizedBox(width: 16),
                _actionButton(
                  icon: Icons.chat_bubble_outline,
                  label: '${activity.commentsCount}',
                  color: Colors.white54,
                ),
                const Spacer(),
                _actionButton(icon: Icons.share, color: Colors.white54),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _stat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.4),
            fontSize: 9,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _actionButton({
    required IconData icon,
    String? label,
    required Color color,
  }) {
    return Row(
      children: [
        Icon(icon, color: color, size: 18),
        if (label != null) ...[
          const SizedBox(width: 4),
          Text(label, style: TextStyle(color: color, fontSize: 12)),
        ],
      ],
    );
  }

  String _timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${(diff.inDays / 7).floor()}w ago';
  }
}

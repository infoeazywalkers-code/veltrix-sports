import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/activity/activity.dart';
import '../../services/activity/activity_service.dart';
import '../../core/utils/unit_conversion.dart';
import '../../providers.dart' show unitSystemProvider, currentUserProvider;

final activityServiceProvider = Provider<ActivityService>(
  (_) => ActivityService(),
);

/// Feed page size. Doubled by "Load more" (25 → 50 → 100, capped at 100).
final feedLimitProvider = StateProvider<int>((_) => 25);

final activitiesStreamProvider = StreamProvider<List<Activity>>((ref) {
  return ref
      .watch(activityServiceProvider)
      .watchActivities(limit: ref.watch(feedLimitProvider));
});

class ActivityFeedScreen extends ConsumerStatefulWidget {
  const ActivityFeedScreen({super.key});

  @override
  ConsumerState<ActivityFeedScreen> createState() => _ActivityFeedScreenState();
}

class _ActivityFeedScreenState extends ConsumerState<ActivityFeedScreen> {
  String _sportFilter = 'all';

  static const List<Map<String, String>> _filters = [
    {'id': 'all', 'label': 'All'},
    {'id': 'cycling', 'label': 'Cycling'},
    {'id': 'running', 'label': 'Running'},
    {'id': 'trailRunning', 'label': 'Trail'},
    {'id': 'gravel', 'label': 'Gravel'},
  ];

  bool _matchesFilter(Activity activity) {
    if (_sportFilter == 'all') return true;
    return activity.sport.name == _sportFilter;
  }

  Future<void> _refresh() async {
    ref.invalidate(activitiesStreamProvider);
    try {
      await ref.read(activitiesStreamProvider.future);
    } catch (_) {
      // Error state surfaces via the provider's AsyncValue below.
    }
  }

  @override
  Widget build(BuildContext context) {
    final activitiesAsync = ref.watch(activitiesStreamProvider);
    final limit = ref.watch(feedLimitProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: activitiesAsync.when(
        data: (activities) {
          final filtered = activities.where(_matchesFilter).toList();
          // Show "Load more" only while the backend may hold more rows:
          // at cap (100) or a short page means everything is loaded.
          final showLoadMore = limit < 100 && activities.length >= limit;
          final itemCount = filtered.length + (showLoadMore ? 1 : 0);
          return Column(
            children: [
              SizedBox(
                height: 48,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  itemCount: _filters.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final filter = _filters[index];
                    final selected = _sportFilter == filter['id'];
                    return ChoiceChip(
                      label: Text(
                        filter['label']!,
                        style: TextStyle(
                          color: selected ? Colors.black : Colors.white70,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                      selected: selected,
                      selectedColor: const Color(0xFFF97316),
                      backgroundColor: const Color(0xFF1A1A1A),
                      side: BorderSide(
                        color:
                            selected
                                ? const Color(0xFFF97316)
                                : Colors.white.withValues(alpha: 0.12),
                      ),
                      onSelected:
                          (_) => setState(() => _sportFilter = filter['id']!),
                    );
                  },
                ),
              ),
              Expanded(
                child: RefreshIndicator(
                  color: const Color(0xFFF97316),
                  onRefresh: _refresh,
                  child:
                      filtered.isEmpty
                          ? ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(top: 72),
                                child: Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.run_circle_outlined,
                                        size: 64,
                                        color: Colors.white24,
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        activities.isEmpty
                                            ? 'No activities yet'
                                            : 'No activities for this filter',
                                        style: const TextStyle(
                                          color: Colors.white54,
                                          fontSize: 16,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      const Text(
                                        'Record your first workout to see it here',
                                        style: TextStyle(
                                          color: Colors.white38,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          )
                          : ListView.builder(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            itemCount: itemCount,
                            itemBuilder: (context, index) {
                              if (index >= filtered.length) {
                                return _LoadMoreButton(
                                  loadedCount: activities.length,
                                  onLoadMore:
                                      () =>
                                          ref
                                              .read(feedLimitProvider.notifier)
                                              .state = limit >= 50
                                                  ? 100
                                                  : limit * 2,
                                );
                              }
                              return _ActivityCard(activity: filtered[index]);
                            },
                          ),
                ),
              ),
            ],
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

class _LoadMoreButton extends StatelessWidget {
  final int loadedCount;
  final VoidCallback onLoadMore;

  const _LoadMoreButton({required this.loadedCount, required this.onLoadMore});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Center(
        child: OutlinedButton(
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
            foregroundColor: const Color(0xFFF97316),
          ),
          onPressed: onLoadMore,
          child: Text(
            'Load more ($loadedCount loaded)',
            style: const TextStyle(fontWeight: FontWeight.w700),
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
    final uid = ref.watch(currentUserProvider)?.uid;
    final hasKudoed = uid != null && activity.kudoedBy.contains(uid);
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
                InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: () => _onKudosTap(context, ref, uid),
                  child: _actionButton(
                    icon: hasKudoed ? Icons.favorite : Icons.favorite_border,
                    label: '${activity.kudosCount}',
                    color: hasKudoed ? const Color(0xFFEF4444) : Colors.white54,
                  ),
                ),
                const SizedBox(width: 16),
                InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: () => _openCommentsSheet(context, ref),
                  child: _actionButton(
                    icon: Icons.chat_bubble_outline,
                    label: '${activity.commentsCount}',
                    color: Colors.white54,
                  ),
                ),
                const Spacer(),
                InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap:
                      () => ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Link copied')),
                      ),
                  child: _actionButton(
                    icon: Icons.share,
                    color: Colors.white54,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _onKudosTap(
    BuildContext context,
    WidgetRef ref,
    String? uid,
  ) async {
    if (uid == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Sign in to give kudos')));
      return;
    }
    try {
      await ref.read(activityServiceProvider).toggleKudos(activity.id, uid);
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Could not update kudos')));
      }
    }
  }

  void _openCommentsSheet(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1A1A1A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (sheetContext) => Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
            ),
            child: DraggableScrollableSheet(
              expand: false,
              initialChildSize: 0.6,
              minChildSize: 0.4,
              maxChildSize: 0.9,
              builder:
                  (_, scrollController) => Column(
                    children: [
                      const SizedBox(height: 12),
                      Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.white24,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Comments',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: StreamBuilder<QuerySnapshot>(
                          stream: ref
                              .read(activityServiceProvider)
                              .watchComments(activity.id),
                          builder: (context, snapshot) {
                            if (snapshot.hasError) {
                              return const Center(
                                child: Text(
                                  'Could not load comments',
                                  style: TextStyle(color: Colors.white54),
                                ),
                              );
                            }
                            if (!snapshot.hasData) {
                              return const Center(
                                child: CircularProgressIndicator(
                                  color: Color(0xFFF97316),
                                ),
                              );
                            }
                            final docs = snapshot.data!.docs;
                            if (docs.isEmpty) {
                              return const Center(
                                child: Text(
                                  'No comments yet. Start the conversation!',
                                  style: TextStyle(color: Colors.white38),
                                ),
                              );
                            }
                            return ListView.separated(
                              controller: scrollController,
                              padding: const EdgeInsets.all(16),
                              itemCount: docs.length,
                              separatorBuilder:
                                  (_, __) => const SizedBox(height: 8),
                              itemBuilder: (context, index) {
                                final data =
                                    docs[index].data() as Map<String, dynamic>;
                                final createdAt =
                                    data['createdAt'] as Timestamp?;
                                return Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    CircleAvatar(
                                      radius: 14,
                                      backgroundColor: const Color(
                                        0xFFF97316,
                                      ).withValues(alpha: 0.2),
                                      child: Text(
                                        ((data['userName'] ?? '?')
                                                .toString()
                                                .isNotEmpty)
                                            ? (data['userName'])
                                                .toString()[0]
                                                .toUpperCase()
                                            : '?',
                                        style: const TextStyle(
                                          color: Color(0xFFF97316),
                                          fontSize: 11,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  (data['userName'] ??
                                                          'Athlete')
                                                      .toString(),
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ),
                                              if (createdAt != null)
                                                Text(
                                                  _commentTimeAgo(
                                                    createdAt.toDate(),
                                                  ),
                                                  style: const TextStyle(
                                                    color: Colors.white38,
                                                    fontSize: 10,
                                                  ),
                                                ),
                                            ],
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            (data['text'] ?? '').toString(),
                                            style: const TextStyle(
                                              color: Colors.white70,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: controller,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                ),
                                decoration: InputDecoration(
                                  hintText: 'Add a comment...',
                                  hintStyle: const TextStyle(
                                    color: Colors.white38,
                                  ),
                                  filled: true,
                                  fillColor: const Color(0xFF0A0A0A),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 10,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              icon: const Icon(
                                Icons.send,
                                color: Color(0xFFF97316),
                              ),
                              onPressed: () async {
                                final text = controller.text.trim();
                                if (text.isEmpty) return;
                                final user = ref.read(currentUserProvider);
                                if (user == null) {
                                  ScaffoldMessenger.of(
                                    sheetContext,
                                  ).showSnackBar(
                                    const SnackBar(
                                      content: Text('Sign in to comment'),
                                    ),
                                  );
                                  return;
                                }
                                final displayName =
                                    (user.displayName?.isNotEmpty == true)
                                        ? user.displayName!
                                        : 'Athlete';
                                try {
                                  await ref
                                      .read(activityServiceProvider)
                                      .addComment(
                                        activity.id,
                                        user.uid,
                                        displayName,
                                        text,
                                      );
                                  controller.clear();
                                } catch (_) {
                                  if (sheetContext.mounted) {
                                    ScaffoldMessenger.of(
                                      sheetContext,
                                    ).showSnackBar(
                                      const SnackBar(
                                        content: Text('Could not post comment'),
                                      ),
                                    );
                                  }
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
            ),
          ),
    ).whenComplete(controller.dispose);
  }

  String _commentTimeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
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

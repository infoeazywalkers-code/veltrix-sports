import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants.dart';
import '../../core/errors/error_handler.dart';
import '../../models/activity/activity.dart';
import '../../models/social/athlete_card.dart';
import '../../providers.dart';
import 'athlete_compare_screen.dart';
import 'widgets/achievements_row.dart';

/// Public athlete profile (Phase 1).
///
/// Shows the published [AthleteCard], follow/unfollow + counts, a PR
/// showcase, and recent activities. The compare action is intentionally
/// omitted (Phase 4) rather than stubbed.
class AthleteProfileScreen extends ConsumerWidget {
  final String uid;

  const AthleteProfileScreen({super.key, required this.uid});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cardAsync = ref.watch(athleteCardProvider(uid));
    final me = ref.watch(currentUserProvider);
    final isSelf = me?.uid == uid;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          cardAsync.valueOrNull?.displayName ?? 'Athlete',
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      body: cardAsync.when(
        loading:
            () => const Center(child: CircularProgressIndicator(color: navy)),
        error:
            (e, _) => _ErrorState(
              message: ErrorHandler.getUserMessage(e),
              onRetry: () => ref.invalidate(athleteCardProvider(uid)),
            ),
        data: (card) {
          if (card == null) {
            return const _NotAvailableState();
          }
          return ListView(
            padding: const EdgeInsets.all(18),
            children: [
              _Header(
                card: card,
                isDark: isDark,
                isSelf: isSelf,
                viewerUid: me?.uid,
              ),
              const SizedBox(height: 16),
              _CountsRow(uid: uid),
              const SizedBox(height: 20),
              _PrShowcase(uid: uid, isSelf: isSelf),
              const SizedBox(height: 16),
              AthleteAchievementsRow(uid: uid),
              const SizedBox(height: 20),
              Text(
                'Recent activities',
                style: TextStyle(
                  color: isDark ? Colors.white : navy,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              _RecentActivities(uid: uid),
            ],
          );
        },
      ),
    );
  }
}

class _Header extends ConsumerWidget {
  final AthleteCard card;
  final bool isDark;
  final bool isSelf;
  final String? viewerUid;

  const _Header({
    required this.card,
    required this.isDark,
    required this.isSelf,
    required this.viewerUid,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final displayName = card.displayName;
    final handle = card.handle;
    final location = card.location;
    final team = card.team;
    final photoUrl = card.photoUrl;
    final initials =
        displayName
            .split(' ')
            .map((w) => w.isNotEmpty ? w[0] : '')
            .take(2)
            .join()
            .toUpperCase();
    final sub = [
      if (handle.isNotEmpty) handle,
      if (location.isNotEmpty) location,
      if (team.isNotEmpty) team,
    ].join('  •  ');

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: navy,
                  backgroundImage:
                      photoUrl != null && photoUrl.isNotEmpty
                          ? NetworkImage(photoUrl)
                          : null,
                  child:
                      photoUrl == null || photoUrl.isEmpty
                          ? Text(
                            initials.isNotEmpty ? initials : 'A',
                            style: const TextStyle(
                              color: lime,
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                            ),
                          )
                          : null,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        displayName.isNotEmpty ? displayName : 'Athlete',
                        style: TextStyle(
                          color: isDark ? Colors.white : navy,
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      if (sub.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            sub,
                            style: TextStyle(
                              color: isDark ? const Color(0xFF78909C) : muted,
                              fontSize: 12,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            if (!isSelf) ...[
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: _FollowButton(targetUid: card.uid, viewerUid: viewerUid),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed:
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (_) => AthleteCompareScreen(
                                otherUid: card.uid,
                                otherName: card.displayName,
                              ),
                        ),
                      ),
                  icon: const Icon(Icons.compare_arrows_outlined),
                  label: const Text(
                    'Compare',
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _FollowButton extends ConsumerWidget {
  final String targetUid;
  final String? viewerUid;

  const _FollowButton({required this.targetUid, required this.viewerUid});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final followingAsync = ref.watch(
      isFollowingProvider((follower: viewerUid ?? '', following: targetUid)),
    );
    return followingAsync.when(
      loading:
          () => const FilledButton(onPressed: null, child: Text('Loading…')),
      error:
          (_, _) => FilledButton(
            onPressed: () => _requireSignIn(context),
            child: const Text('Follow'),
          ),
      data: (following) {
        return FilledButton.icon(
          style: FilledButton.styleFrom(
            backgroundColor: following ? null : navy,
            foregroundColor: following ? null : Colors.white,
          ),
          onPressed: () => _toggle(context, ref, following),
          icon: Icon(following ? Icons.check : Icons.add),
          label: Text(
            following ? 'Following' : 'Follow',
            style: const TextStyle(fontWeight: FontWeight.w900),
          ),
        );
      },
    );
  }

  void _requireSignIn(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Sign in to follow athletes.')),
    );
  }

  Future<void> _toggle(
    BuildContext context,
    WidgetRef ref,
    bool following,
  ) async {
    if (viewerUid == null || viewerUid!.isEmpty) {
      _requireSignIn(context);
      return;
    }
    try {
      final service = ref.read(followServiceProvider);
      if (following) {
        await service.unfollow(viewerUid!, targetUid);
      } else {
        await service.follow(viewerUid!, targetUid);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(ErrorHandler.getUserMessage(e))));
      }
    }
  }
}

class _CountsRow extends ConsumerWidget {
  final String uid;

  const _CountsRow({required this.uid});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final followersAsync = ref.watch(followerCountProvider(uid));
    final followingAsync = ref.watch(followingCountProvider(uid));
    final followers = followersAsync.valueOrNull;
    final following = followingAsync.valueOrNull;
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          children: [
            Expanded(
              child: _Count(
                label: 'Followers',
                value: followers != null ? '$followers' : '–',
              ),
            ),
            Container(width: 1, height: 36, color: Colors.grey.shade300),
            Expanded(
              child: _Count(
                label: 'Following',
                value: following != null ? '$following' : '–',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Count extends StatelessWidget {
  final String label;
  final String value;

  const _Count({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: isDark ? Colors.white : navy,
            fontSize: 20,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            color: isDark ? const Color(0xFF78909C) : muted,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

class _PrShowcase extends ConsumerWidget {
  final String uid;
  final bool isSelf;

  const _PrShowcase({required this.uid, required this.isSelf});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (isSelf) {
      final prAsync = ref.watch(personalBestsProvider);
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Personal bests',
                style: TextStyle(
                  color: isDark ? Colors.white : navy,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 10),
              prAsync.when(
                loading:
                    () => const Center(
                      child: Padding(
                        padding: EdgeInsets.all(8),
                        child: CircularProgressIndicator(),
                      ),
                    ),
                error: (_, _) => const _PrRow('Best 5K', 'No PR yet'),
                data:
                    (pr) => Column(
                      children: [
                        _PrRow('Best 5K pace', pr.best5kPace),
                        const SizedBox(height: 8),
                        _PrRow('Best 20-min power', pr.best20MinPower),
                      ],
                    ),
              ),
            ],
          ),
        ),
      );
    }
    final activitiesStream = ref
        .read(activityServiceProvider)
        .watchUserActivities(uid, limit: 50);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Personal bests',
              style: TextStyle(
                color: isDark ? Colors.white : navy,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 10),
            StreamBuilder<List<Activity>>(
              stream: activitiesStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(8),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
                if (snapshot.hasError) {
                  return const _PrRow('Best 5K', 'No PR yet');
                }
                final pr = prFromActivities(snapshot.data ?? const []);
                return Column(
                  children: [
                    _PrRow('Best 5K pace', pr.pace),
                    const SizedBox(height: 8),
                    _PrRow('Best 20-min power', pr.power),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// Derives honest PR labels from real activity data.
({String pace, String power}) prFromActivities(List<Activity> activities) {
  String pace = 'No PR yet';
  double? bestPace;
  for (final a in activities) {
    final isRun =
        a.sport == SportType.running || a.sport == SportType.trailRunning;
    if (!isRun || a.distanceKm < 4.5 || a.distanceKm > 5.5) continue;
    final minutes = a.durationSeconds / 60;
    if (minutes <= 0 || a.distanceKm <= 0) continue;
    final p = minutes / a.distanceKm;
    if (bestPace == null || p < bestPace) {
      bestPace = p;
      final m = p.floor();
      final s = ((p - m) * 60).round();
      pace = '$m:${s.toString().padLeft(2, '0')} /km';
    }
  }
  String power = 'No PR yet';
  int? best;
  for (final a in activities) {
    final minutes = a.durationSeconds / 60;
    if (minutes < 15 || minutes > 25) continue;
    final w = a.normalizedPower ?? a.avgPower;
    if (w != null && (best == null || w > best)) best = w;
  }
  if (best != null) power = '$best W';
  return (pace: pace, power: power);
}

class _PrRow extends StatelessWidget {
  final String label;
  final String value;

  const _PrRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: isDark ? const Color(0xFF78909C) : muted,
              fontSize: 13,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: isDark ? Colors.white : navy,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _RecentActivities extends ConsumerWidget {
  final String uid;

  const _RecentActivities({required this.uid});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activitiesStream = ref
        .read(activityServiceProvider)
        .watchUserActivities(uid, limit: 5);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return StreamBuilder<List<Activity>>(
      stream: activitiesStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(),
            ),
          );
        }
        if (snapshot.hasError) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Could not load activities.',
                style: TextStyle(
                  color: isDark ? const Color(0xFF78909C) : muted,
                ),
              ),
            ),
          );
        }
        final activities = snapshot.data ?? const <Activity>[];
        if (activities.isEmpty) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'No recent activities.',
                style: TextStyle(
                  color: isDark ? const Color(0xFF78909C) : muted,
                ),
              ),
            ),
          );
        }
        return Column(
          children:
              activities
                  .map(
                    (a) => Card(
                      child: ListTile(
                        leading: Icon(
                          Icons.directions_run,
                          color: isDark ? Colors.white : navy,
                        ),
                        title: Text(
                          a.title.isNotEmpty ? a.title : a.sport.name,
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                        subtitle: Text(
                          '${a.sport.name} • ${a.distanceKm.toStringAsFixed(1)} km • ${a.date.day}/${a.date.month}/${a.date.year}',
                        ),
                      ),
                    ),
                  )
                  .toList(),
        );
      },
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}

class _NotAvailableState extends StatelessWidget {
  const _NotAvailableState();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.person_off_outlined,
              size: 64,
              color: isDark ? Colors.white : navy,
            ),
            const SizedBox(height: 16),
            Text(
              'Athlete card not published',
              style: TextStyle(
                color: isDark ? Colors.white : navy,
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'This athlete has not published their public card yet.',
              textAlign: TextAlign.center,
              style: TextStyle(color: isDark ? const Color(0xFF78909C) : muted),
            ),
          ],
        ),
      ),
    );
  }
}

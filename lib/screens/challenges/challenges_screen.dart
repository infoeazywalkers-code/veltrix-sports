import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/errors/error_handler.dart';
import '../../providers.dart';
import '../../services/social/challenge_service.dart';
import '../../services/social/leaderboard_service.dart';
import '../athletes/athlete_profile_screen.dart';
import '../athletes/leaderboard_screen.dart';

class ChallengesScreen extends StatefulWidget {
  const ChallengesScreen({super.key});

  @override
  State<ChallengesScreen> createState() => _ChallengesScreenState();
}

class _ChallengesScreenState extends State<ChallengesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: TabBar(
              controller: _tabController,
              indicatorColor: const Color(0xFFF97316),
              labelColor: const Color(0xFFF97316),
              unselectedLabelColor: Colors.white54,
              labelStyle: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
              tabs: const [Tab(text: 'Challenges'), Tab(text: 'Leaderboard')],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [_ChallengesList(), const _LeaderboardList()],
            ),
          ),
        ],
      ),
    );
  }
}

class _ChallengesList extends ConsumerStatefulWidget {
  @override
  ConsumerState<_ChallengesList> createState() => _ChallengesListState();
}

class _ChallengesListState extends ConsumerState<_ChallengesList> {
  String? _selectedCategory;
  final Set<String> _busy = {};

  @override
  Widget build(BuildContext context) {
    final challengesAsync = ref.watch(challengesProvider);
    final me = ref.watch(currentUserProvider);
    final entriesAsync =
        me == null
            ? const AsyncValue<Map<String, ChallengeEntry>>.data({})
            : ref.watch(myChallengeEntriesProvider(me.uid));

    return challengesAsync.when(
      loading:
          () => const Center(
            child: CircularProgressIndicator(color: Color(0xFFF97316)),
          ),
      error:
          (e, _) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    ErrorHandler.getUserMessage(e),
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () => ref.invalidate(challengesProvider),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          ),
      data: (challenges) {
        if (challenges.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Text(
                'No challenges yet. Check back soon.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70),
              ),
            ),
          );
        }
        final entries = entriesAsync.valueOrNull ?? const {};
        final categories =
            challenges.map((c) => c.category.name).toSet().toList()..sort();
        final visible =
            _selectedCategory == null
                ? challenges
                : challenges
                    .where((c) => c.category.name == _selectedCategory)
                    .toList();
        return Column(
          children: [
            SizedBox(
              height: 44,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 6,
                ),
                children: [
                  _FilterChip(
                    label: 'All',
                    selected: _selectedCategory == null,
                    onTap: () => setState(() => _selectedCategory = null),
                  ),
                  for (final cat in categories)
                    _FilterChip(
                      label: cat,
                      selected: _selectedCategory == cat,
                      onTap:
                          () => setState(
                            () =>
                                _selectedCategory =
                                    _selectedCategory == cat ? null : cat,
                          ),
                    ),
                ],
              ),
            ),
            Expanded(
              child:
                  visible.isEmpty
                      ? const Center(
                        child: Padding(
                          padding: EdgeInsets.all(24),
                          child: Text(
                            'No challenges in this category yet.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white70),
                          ),
                        ),
                      )
                      : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: visible.length,
                        itemBuilder: (context, index) {
                          final c = visible[index];
                          final entry = entries[c.id];
                          final joined = entry != null;
                          final completed = entry?.completed ?? false;
                          return _ChallengeCard(
                            challengeId: c.id,
                            title: c.title,
                            description: c.description,
                            categoryLabel: c.category.name,
                            sportLabel: c.sport.name,
                            badgeIcon: c.badgeIcon,
                            targetValue: c.targetValue,
                            currentValue: c.currentValue,
                            unit: c.unit,
                            participants: c.participantsCount,
                            daysLeft: c.daysRemaining,
                            joined: joined,
                            completed: completed,
                            entryProgress: entry?.progress,
                            busy: _busy.contains(c.id),
                            onJoin: () => _join(me?.uid, c.id),
                            onLeave: () => _leave(me?.uid, c.id),
                          );
                        },
                      ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _join(String? uid, String challengeId) async {
    if (uid == null || uid.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sign in to join challenges.')),
        );
      }
      return;
    }
    setState(() => _busy.add(challengeId));
    try {
      await ref.read(challengeServiceProvider).joinChallenge(uid, challengeId);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(ErrorHandler.getUserMessage(e))));
      }
    } finally {
      if (mounted) setState(() => _busy.remove(challengeId));
    }
  }

  Future<void> _leave(String? uid, String challengeId) async {
    if (uid == null || uid.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sign in to join challenges.')),
        );
      }
      return;
    }
    setState(() => _busy.add(challengeId));
    try {
      await ref.read(challengeServiceProvider).leaveChallenge(uid, challengeId);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(ErrorHandler.getUserMessage(e))));
      }
    } finally {
      if (mounted) setState(() => _busy.remove(challengeId));
    }
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onTap(),
        selectedColor: const Color(0xFFF97316).withValues(alpha: 0.2),
        backgroundColor: const Color(0xFF1A1A1A),
        labelStyle: TextStyle(
          color: selected ? const Color(0xFFF97316) : Colors.white70,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
        side: BorderSide(
          color:
              selected
                  ? const Color(0xFFF97316)
                  : Colors.white.withValues(alpha: 0.12),
        ),
      ),
    );
  }
}

class _ChallengeCard extends StatelessWidget {
  final String challengeId;
  final String title;
  final String description;
  final String categoryLabel;
  final String sportLabel;
  final String badgeIcon;
  final double targetValue;
  final double currentValue;
  final String unit;
  final int participants;
  final int daysLeft;
  final bool joined;
  final bool completed;
  final double? entryProgress;
  final bool busy;
  final VoidCallback onJoin;
  final VoidCallback onLeave;

  const _ChallengeCard({
    required this.challengeId,
    required this.title,
    required this.description,
    required this.categoryLabel,
    required this.sportLabel,
    required this.badgeIcon,
    required this.targetValue,
    required this.currentValue,
    required this.unit,
    required this.participants,
    required this.daysLeft,
    required this.joined,
    required this.completed,
    required this.entryProgress,
    required this.busy,
    required this.onJoin,
    required this.onLeave,
  });

  @override
  Widget build(BuildContext context) {
    final hasTarget = targetValue > 0;
    final progress =
        hasTarget ? (currentValue / targetValue).clamp(0.0, 1.0) : 0.0;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFF97316).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child:
                      badgeIcon.isNotEmpty
                          ? Text(
                            badgeIcon,
                            style: const TextStyle(fontSize: 22),
                          )
                          : const Icon(
                            Icons.emoji_events_outlined,
                            color: Color(0xFFF97316),
                          ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      description,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.5),
                        fontSize: 11,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              _MetaChip(label: categoryLabel),
              _MetaChip(label: sportLabel),
              if (completed)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFF10B981).withValues(alpha: 0.4),
                    ),
                  ),
                  child: const Text(
                    'Completed',
                    style: TextStyle(
                      color: Color(0xFF10B981),
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              if (joined && !completed)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF97316).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFFF97316).withValues(alpha: 0.4),
                    ),
                  ),
                  child: const Text(
                    'Joined ✓',
                    style: TextStyle(
                      color: Color(0xFFF97316),
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          if (hasTarget) ...[
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: progress,
                      backgroundColor: Colors.white.withValues(alpha: 0.08),
                      valueColor: const AlwaysStoppedAnimation(
                        Color(0xFFF97316),
                      ),
                      minHeight: 8,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  '${(progress * 100).round()}%',
                  style: const TextStyle(
                    color: Color(0xFFF97316),
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
          Row(
            children: [
              if (hasTarget)
                Text(
                  '${_formatValue(currentValue)} / ${_formatValue(targetValue)} $unit',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.6),
                    fontSize: 11,
                  ),
                )
              else if (joined && entryProgress != null && entryProgress! > 0)
                Text(
                  'Your progress: ${_formatValue(entryProgress!)} $unit',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.6),
                    fontSize: 11,
                  ),
                )
              else if (joined)
                Text(
                  'Joined',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.6),
                    fontSize: 11,
                  ),
                ),
              const Spacer(),
              Text(
                '${NumberFormat.compact().format(participants)} athletes',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.4),
                  fontSize: 10,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${daysLeft}d left',
                style: const TextStyle(
                  color: Color(0xFFF97316),
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child:
                joined
                    ? OutlinedButton(
                      onPressed: busy ? null : onLeave,
                      child: Text(
                        busy ? 'Working…' : 'Leave challenge',
                        style: const TextStyle(color: Colors.white70),
                      ),
                    )
                    : FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFFF97316),
                        foregroundColor: Colors.white,
                      ),
                      onPressed: busy ? null : onJoin,
                      child: Text(busy ? 'Joining…' : 'Join challenge'),
                    ),
          ),
        ],
      ),
    );
  }

  String _formatValue(double v) {
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(1)}k';
    return v.round().toString();
  }
}

/// Live monthly leaderboard tab (Phase 2).
///
/// Every row traces to real `activities` docs from the current month joined
/// to a real `athlete_directory` card via [monthlyBoardProvider]. No mocks.
class _LeaderboardList extends ConsumerWidget {
  const _LeaderboardList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final boardAsync = ref.watch(monthlyBoardProvider);
    final me = ref.watch(currentUserProvider);

    return boardAsync.when(
      loading:
          () => const Center(
            child: CircularProgressIndicator(color: Color(0xFFF97316)),
          ),
      error:
          (e, _) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    ErrorHandler.getUserMessage(e),
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () => ref.invalidate(monthlyBoardProvider),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          ),
      data: (rows) {
        if (rows.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Text(
                'No activities logged this month yet.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70),
              ),
            ),
          );
        }
        final visible = rows.take(10).toList();
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Row(
              children: [
                const Text(
                  'Monthly TSS board',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => _openFullBoard(context),
                  child: const Text(
                    'Full board',
                    style: TextStyle(
                      color: Color(0xFFF97316),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ...visible.asMap().entries.map(
              (entry) => _LiveLeaderRow(
                rank: entry.key + 1,
                row: entry.value,
                isCurrentUser: me != null && entry.value.userId == me.uid,
                onTap: () => _openProfile(context, entry.value.userId),
              ),
            ),
            if (rows.length > visible.length)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: OutlinedButton(
                  onPressed: () => _openFullBoard(context),
                  child: Text(
                    'View all ${rows.length} athletes',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  void _openProfile(BuildContext context, String uid) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AthleteProfileScreen(uid: uid)),
    );
  }

  void _openFullBoard(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const LeaderboardScreen()),
    );
  }
}

class _LiveLeaderRow extends StatelessWidget {
  final int rank;
  final LeaderboardRow row;
  final bool isCurrentUser;
  final VoidCallback onTap;

  const _LiveLeaderRow({
    required this.rank,
    required this.row,
    required this.isCurrentUser,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color:
              isCurrentUser
                  ? const Color(0xFFF97316).withValues(alpha: 0.1)
                  : const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color:
                isCurrentUser
                    ? const Color(0xFFF97316).withValues(alpha: 0.3)
                    : Colors.white.withValues(alpha: 0.06),
          ),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 30,
              child: Text(
                '#$rank',
                style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 10),
            CircleAvatar(
              radius: 16,
              backgroundColor: const Color(0xFFF97316).withValues(alpha: 0.2),
              backgroundImage:
                  row.photoUrl != null && row.photoUrl!.isNotEmpty
                      ? NetworkImage(row.photoUrl!)
                      : null,
              child:
                  row.photoUrl == null || row.photoUrl!.isEmpty
                      ? Text(
                        row.displayName.isNotEmpty
                            ? row.displayName[0].toUpperCase()
                            : 'A',
                        style: const TextStyle(
                          color: Color(0xFFF97316),
                          fontSize: 13,
                        ),
                      )
                      : null,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    row.displayName,
                    style: TextStyle(
                      color:
                          isCurrentUser
                              ? const Color(0xFFF97316)
                              : Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${row.monthlyTss} TSS · +${(row.monthlyElevationM / 1000).toStringAsFixed(1)}k m · ${row.monthlyDistanceKm.toStringAsFixed(0)} km',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.4),
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.white38, size: 18),
          ],
        ),
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  final String label;

  const _MetaChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.6),
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

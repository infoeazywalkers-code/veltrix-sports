import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/errors/error_handler.dart';
import '../../providers.dart';
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

class _ChallengesList extends StatelessWidget {
  final List<_MockChallenge> challenges = const [
    _MockChallenge(
      title: 'Tour de Mont Blanc 10,000m Elevation',
      description:
          'Scale 10,000 meters of cumulative vertical climbing this month.',
      targetValue: 10000,
      currentValue: 6840,
      unit: 'meters',
      participants: 14820,
      isJoined: true,
      badgeIcon: '⛰️',
      gradient: [Color(0xFFF59E0B), Color(0xFFDC2626)],
      daysLeft: 22,
    ),
    _MockChallenge(
      title: 'Veltrix Gran Fondo 150km',
      description: 'Ride 150km in a single session to claim the Fondo Badge.',
      targetValue: 150,
      currentValue: 122,
      unit: 'km',
      participants: 28410,
      isJoined: true,
      badgeIcon: '🚴',
      gradient: [Color(0xFFF97316), Color(0xFFF59E0B)],
      daysLeft: 22,
    ),
    _MockChallenge(
      title: 'Sub-20 5K Speed Blitz',
      description: 'Log a validated 5K run under 20:00 minutes.',
      targetValue: 5,
      currentValue: 5,
      unit: 'km',
      participants: 8940,
      isJoined: true,
      badgeIcon: '⚡',
      gradient: [Color(0xFF10B981), Color(0xFF14B8A6)],
      daysLeft: 22,
      completed: true,
    ),
    _MockChallenge(
      title: 'Consistency Streak: 21 Days Active',
      description:
          'Log at least 30 minutes of training for 21 consecutive days.',
      targetValue: 21,
      currentValue: 18,
      unit: 'days',
      participants: 34100,
      isJoined: true,
      badgeIcon: '🔥',
      gradient: [Color(0xFFEF4444), Color(0xFFF97316)],
      daysLeft: 22,
    ),
    _MockChallenge(
      title: 'Alps Trans-Chamonix 250km Ultra',
      description: 'Tackle 250km of high-altitude gravel and trail running.',
      targetValue: 250,
      currentValue: 84,
      unit: 'km',
      participants: 4120,
      isJoined: false,
      badgeIcon: '🧭',
      gradient: [Color(0xFF8B5CF6), Color(0xFF6366F1)],
      daysLeft: 37,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: challenges.length,
      itemBuilder: (context, index) {
        final c = challenges[index];
        final progress = (c.currentValue / c.targetValue).clamp(0.0, 1.0);
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
                      gradient: LinearGradient(colors: c.gradient),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        c.badgeIcon,
                        style: const TextStyle(fontSize: 22),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          c.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          c.description,
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
              const SizedBox(height: 12),
              // Progress bar
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: progress,
                        backgroundColor: Colors.white.withValues(alpha: 0.08),
                        valueColor: AlwaysStoppedAnimation(c.gradient[0]),
                        minHeight: 8,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    '${(progress * 100).round()}%',
                    style: TextStyle(
                      color: c.gradient[0],
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    '${_formatValue(c.currentValue)} / ${_formatValue(c.targetValue)} ${c.unit}',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.6),
                      fontSize: 11,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${NumberFormat.compact().format(c.participants)} athletes',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.4),
                      fontSize: 10,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${c.daysLeft}d left',
                    style: const TextStyle(
                      color: Color(0xFFF97316),
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
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

class _MockChallenge {
  final String title;
  final String description;
  final double targetValue;
  final double currentValue;
  final String unit;
  final int participants;
  final bool isJoined;
  final String badgeIcon;
  final List<Color> gradient;
  final int daysLeft;
  final bool completed;

  const _MockChallenge({
    required this.title,
    required this.description,
    required this.targetValue,
    required this.currentValue,
    required this.unit,
    required this.participants,
    required this.isJoined,
    required this.badgeIcon,
    required this.gradient,
    required this.daysLeft,
    this.completed = false,
  });
}

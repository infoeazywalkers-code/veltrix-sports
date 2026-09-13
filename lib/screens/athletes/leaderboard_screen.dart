import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants.dart';
import '../../core/errors/error_handler.dart';
import '../../services/auth/auth_service.dart';
import '../../services/social/leaderboard_service.dart';
import '../../providers.dart';
import 'athlete_profile_screen.dart';

/// Live monthly leaderboard (Phase 2).
///
/// Every row traces to real `activities` docs from the current month joined
/// to a real `athlete_directory` card. Athletes who opted out
/// (`showOnLeaderboards == false`) are excluded upstream in
/// [LeaderboardService]. No mock rows.
class LeaderboardScreen extends ConsumerStatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  ConsumerState<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends ConsumerState<LeaderboardScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  String _sport = 'All';
  String _metric = 'TSS';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final me = ref.watch(currentUserProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (me == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Leaderboard')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.leaderboard_outlined,
                  size: 64,
                  color: isDark ? Colors.white : navy,
                ),
                const SizedBox(height: 16),
                Text(
                  'Sign in to view the leaderboard',
                  style: TextStyle(
                    color: isDark ? Colors.white : navy,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'The monthly board is available to signed-in members.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isDark ? const Color(0xFF78909C) : muted,
                  ),
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: lime,
                    foregroundColor: navy,
                  ),
                  onPressed: () async {
                    try {
                      await AuthService().signInWithGoogle();
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(ErrorHandler.getUserMessage(e)),
                          ),
                        );
                      }
                    }
                  },
                  icon: const Icon(Icons.login),
                  label: const Text(
                    'Sign in with Google',
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final boardAsync = ref.watch(monthlyBoardProvider);
    final now = DateTime.now();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Leaderboard · ${monthName(now.month)}',
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      body: boardAsync.when(
        loading: () => const Center(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 48),
            child: CircularProgressIndicator(color: navy),
          ),
        ),
        error: (e, _) => _BoardError(
          message: ErrorHandler.getUserMessage(e),
          onRetry: () => ref.invalidate(monthlyBoardProvider),
        ),
        data: (rows) {
          if (rows.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'No activities logged this month yet.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            );
          }
          final sports = <String>{};
          for (final r in rows) {
            if (r.sport.isNotEmpty) sports.add(r.sport);
          }
          final sportOptions = ['All', ...sports.toList()..sort()];
          if (!sportOptions.contains(_sport)) _sport = 'All';

          final filtered = _applyFilters(_sorted(rows));
          return ListView(
            padding: const EdgeInsets.all(18),
            children: [
              _MetricToggle(
                metric: _metric,
                onChanged: (v) => setState(() => _metric = v),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _searchController,
                onChanged: (val) => setState(() => _query = val.trim()),
                decoration: InputDecoration(
                  hintText: 'Search name, handle, team, location',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _query.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _query = '');
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.filter_list, size: 20),
                  const SizedBox(width: 8),
                  DropdownButton<String>(
                    value: _sport,
                    items: sportOptions
                        .map(
                          (s) => DropdownMenuItem(
                            value: s,
                            child: Text(
                              s == 'All' ? 'All sports' : s,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (v) {
                      if (v != null) setState(() => _sport = v);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _YourStanding(
                ranked: _sorted(rows),
                metric: _metric,
                currentUid: me.uid,
              ),
              const SizedBox(height: 16),
              if (filtered.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 48),
                  child: Center(
                    child: Text(
                      'No athletes match your search.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                )
              else ...[
                _Podium(
                  top3: filtered.take(3).toList(),
                  metric: _metric,
                  onTap: _openProfile,
                ),
                const SizedBox(height: 12),
                ...filtered.asMap().entries.map(
                  (entry) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _BoardRow(
                      rank: entry.key + 1,
                      row: entry.value,
                      metric: _metric,
                      leaderValue: _metricValue(filtered.first),
                      isSelf: entry.value.userId == me.uid,
                      onTap: () => _openProfile(entry.value.userId),
                    ),
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  void _openProfile(String uid) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AthleteProfileScreen(uid: uid)),
    );
  }

  double _metricValue(LeaderboardRow row) {
    return _metric == 'Elevation'
        ? row.monthlyElevationM
        : row.monthlyTss.toDouble();
  }

  List<LeaderboardRow> _sorted(List<LeaderboardRow> rows) {
    final sorted = [...rows];
    if (_metric == 'Elevation') {
      sorted.sort((a, b) => b.monthlyElevationM.compareTo(a.monthlyElevationM));
    } else {
      sorted.sort((a, b) => b.monthlyTss.compareTo(a.monthlyTss));
    }
    return sorted;
  }

  List<LeaderboardRow> _applyFilters(List<LeaderboardRow> ranked) {
    final q = _query.toLowerCase();
    return ranked.where((row) {
      if (_sport != 'All' && row.sport != _sport) return false;
      if (q.isEmpty) return true;
      return row.displayName.toLowerCase().contains(q) ||
          row.handle.toLowerCase().contains(q) ||
          row.team.toLowerCase().contains(q) ||
          row.location.toLowerCase().contains(q);
    }).toList();
  }
}

class _MetricToggle extends StatelessWidget {
  final String metric;
  final ValueChanged<String> onChanged;

  const _MetricToggle({required this.metric, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<String>(
      segments: const [
        ButtonSegment(value: 'TSS', label: Text('TSS')),
        ButtonSegment(value: 'Elevation', label: Text('Elevation')),
      ],
      selected: {metric},
      onSelectionChanged: (selection) => onChanged(selection.first),
    );
  }
}

class _YourStanding extends StatelessWidget {
  final List<LeaderboardRow> ranked;
  final String metric;
  final String currentUid;

  const _YourStanding({
    required this.ranked,
    required this.metric,
    required this.currentUid,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final index = ranked.indexWhere((r) => r.userId == currentUid);
    final String title;
    final String subtitle;
    if (index == -1) {
      title = 'Race unranked — log an activity';
      subtitle = 'Log an activity this month to join the board.';
    } else {
      final mine = ranked[index];
      final rank = index + 1;
      if (rank == 1) {
        title = 'Rank #1 · ${_valueLabel(mine)}';
        subtitle = 'You lead the monthly board.';
      } else {
        final ahead = ranked[index - 1];
        title = 'Rank #$rank · ${_valueLabel(mine)}';
        subtitle = '${_gapLabel(ahead, mine)} behind ${ahead.displayName}';
      }
    }
    return Card(
      color: index == -1 ? null : lime.withValues(alpha: 0.2),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Icon(
              index == -1 ? Icons.flag_outlined : Icons.emoji_events_outlined,
              color: isDark ? Colors.white : navy,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    index == -1 ? 'Your standing' : 'Your standing · $title',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      color: isDark ? Colors.white : navy,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    index == -1 ? '$title. $subtitle' : subtitle,
                    style: TextStyle(
                      color: isDark ? const Color(0xFF78909C) : muted,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _valueLabel(LeaderboardRow row) {
    if (metric == 'Elevation') {
      return '${row.monthlyElevationM.toStringAsFixed(0)} m';
    }
    return '${row.monthlyTss} TSS';
  }

  String _gapLabel(LeaderboardRow ahead, LeaderboardRow mine) {
    if (metric == 'Elevation') {
      final gap = ahead.monthlyElevationM - mine.monthlyElevationM;
      return '${gap.toStringAsFixed(0)} m';
    }
    return '${ahead.monthlyTss - mine.monthlyTss} TSS';
  }
}

class _Podium extends StatelessWidget {
  final List<LeaderboardRow> top3;
  final String metric;
  final ValueChanged<String> onTap;

  const _Podium({
    required this.top3,
    required this.metric,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (top3.isEmpty) return const SizedBox.shrink();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // Gold / silver / bronze order: display 2nd, 1st, 3rd when 3 exist.
    final order = <int>[];
    if (top3.length == 1) {
      order.add(0);
    } else if (top3.length == 2) {
      order.addAll([1, 0]);
    } else {
      order.addAll([1, 0, 2]);
    }
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: order.map((i) {
            final row = top3[i];
            final rank = i + 1;
            final height = rank == 1 ? 88.0 : (rank == 2 ? 68.0 : 56.0);
            final color = rank == 1
                ? const Color(0xFFFBBF24)
                : (rank == 2 ? Colors.grey.shade400 : const Color(0xFFCD7F32));
            return Expanded(
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => onTap(row.userId),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: rank == 1 ? 28 : 22,
                      backgroundColor: navy,
                      backgroundImage:
                          row.photoUrl != null && row.photoUrl!.isNotEmpty
                          ? NetworkImage(row.photoUrl!)
                          : null,
                      child: row.photoUrl == null || row.photoUrl!.isEmpty
                          ? Text(
                              _initials(row.displayName),
                              style: const TextStyle(
                                color: lime,
                                fontWeight: FontWeight.w900,
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      row.displayName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        color: isDark ? Colors.white : navy,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      _valueLabel(row),
                      style: TextStyle(
                        color: isDark ? const Color(0xFF78909C) : muted,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      height: height,
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: color),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '#$rank',
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 18,
                          color: isDark ? Colors.white : navy,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  String _valueLabel(LeaderboardRow row) {
    if (metric == 'Elevation') {
      return '${row.monthlyElevationM.toStringAsFixed(0)} m';
    }
    return '${row.monthlyTss} TSS';
  }

  String _initials(String name) {
    final parts = name.split(' ').where((w) => w.isNotEmpty).take(2);
    final value = parts.map((w) => w[0]).join().toUpperCase();
    return value.isNotEmpty ? value : 'A';
  }
}

class _BoardRow extends StatelessWidget {
  final int rank;
  final LeaderboardRow row;
  final String metric;
  final double leaderValue;
  final bool isSelf;
  final VoidCallback onTap;

  const _BoardRow({
    required this.rank,
    required this.row,
    required this.metric,
    required this.leaderValue,
    required this.isSelf,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final value = metric == 'Elevation'
        ? row.monthlyElevationM
        : row.monthlyTss.toDouble();
    final fraction = leaderValue > 0
        ? (value / leaderValue).clamp(0.0, 1.0)
        : 0.0;
    final valueLabel = metric == 'Elevation'
        ? '${row.monthlyElevationM.toStringAsFixed(0)} m'
        : '${row.monthlyTss} TSS';
    return Card(
      color: isSelf ? lime.withValues(alpha: 0.2) : null,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              SizedBox(
                width: 36,
                child: Text(
                  '#$rank',
                  style: TextStyle(
                    color: isDark ? Colors.white : navy,
                    fontWeight: FontWeight.w900,
                    fontSize: 13,
                  ),
                ),
              ),
              CircleAvatar(
                radius: 16,
                backgroundColor: navy,
                backgroundImage:
                    row.photoUrl != null && row.photoUrl!.isNotEmpty
                    ? NetworkImage(row.photoUrl!)
                    : null,
                child: row.photoUrl == null || row.photoUrl!.isEmpty
                    ? Text(
                        row.displayName.isNotEmpty
                            ? row.displayName[0].toUpperCase()
                            : 'A',
                        style: const TextStyle(color: lime, fontSize: 13),
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
                        color: isDark ? Colors.white : navy,
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                      ),
                    ),
                    if (row.handle.isNotEmpty)
                      Text(
                        row.handle,
                        style: TextStyle(
                          color: isDark ? const Color(0xFF78909C) : muted,
                          fontSize: 11,
                        ),
                      ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: fraction,
                        backgroundColor: (isDark ? Colors.white : navy)
                            .withValues(alpha: 0.08),
                        valueColor: const AlwaysStoppedAnimation(navy),
                        minHeight: 6,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Text(
                valueLabel,
                style: TextStyle(
                  color: isDark ? Colors.white : navy,
                  fontWeight: FontWeight.w900,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BoardError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _BoardError({required this.message, required this.onRetry});

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

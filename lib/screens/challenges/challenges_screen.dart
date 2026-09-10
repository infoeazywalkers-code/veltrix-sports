import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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
              children: [_ChallengesList(), _LeaderboardList()],
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

class _LeaderboardList extends StatelessWidget {
  final List<_MockLeader> leaders = const [
    _MockLeader(
      rank: 1,
      name: 'Elena Vos',
      flag: '🇪🇸',
      tss: 3120,
      elevation: 38400,
      km: 1845,
      isPro: true,
    ),
    _MockLeader(
      rank: 2,
      name: 'Marcus Lindqvist',
      flag: '🇳🇴',
      tss: 2940,
      elevation: 31200,
      km: 1620,
      isPro: true,
    ),
    _MockLeader(
      rank: 3,
      name: 'Kilian Jornet',
      flag: '🇫🇷',
      tss: 2780,
      elevation: 46200,
      km: 780,
      isPro: true,
    ),
    _MockLeader(
      rank: 4,
      name: 'Mateo Rossi',
      flag: '🇮🇹',
      tss: 2650,
      elevation: 42100,
      km: 1380,
      isPro: true,
    ),
    _MockLeader(
      rank: 5,
      name: 'Sarah Jenkins',
      flag: '🇺🇸',
      tss: 2510,
      elevation: 22400,
      km: 940,
      isPro: true,
    ),
    _MockLeader(
      rank: 6,
      name: 'You',
      flag: '🇺🇸',
      tss: 2240,
      elevation: 28900,
      km: 1180,
      isPro: true,
      isCurrentUser: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: leaders.length,
      itemBuilder: (context, index) {
        final l = leaders[index];
        final isTop3 = l.rank <= 3;
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color:
                l.isCurrentUser
                    ? const Color(0xFFF97316).withValues(alpha: 0.1)
                    : const Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color:
                  l.isCurrentUser
                      ? const Color(0xFFF97316).withValues(alpha: 0.3)
                      : Colors.white.withValues(alpha: 0.06),
            ),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 30,
                child: Text(
                  isTop3 ? ['🥇', '🥈', '🥉'][l.rank - 1] : '#${l.rank}',
                  style: TextStyle(
                    color: isTop3 ? null : Colors.white54,
                    fontSize: isTop3 ? 20 : 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              CircleAvatar(
                radius: 16,
                backgroundColor: const Color(0xFFF97316).withValues(alpha: 0.2),
                child: Text(
                  l.name[0],
                  style: const TextStyle(
                    color: Color(0xFFF97316),
                    fontSize: 13,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          l.name,
                          style: TextStyle(
                            color:
                                l.isCurrentUser
                                    ? const Color(0xFFF97316)
                                    : Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                        if (l.isPro) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 5,
                              vertical: 1,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(
                                0xFFFBBF24,
                              ).withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'PRO',
                              style: TextStyle(
                                color: Color(0xFFFBBF24),
                                fontSize: 8,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(width: 4),
                        Text(l.flag, style: const TextStyle(fontSize: 12)),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${l.tss} TSS · +${(l.elevation / 1000).toStringAsFixed(1)}k m · ${l.km} km',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.4),
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
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

class _MockLeader {
  final int rank;
  final String name;
  final String flag;
  final int tss;
  final int elevation;
  final int km;
  final bool isPro;
  final bool isCurrentUser;

  const _MockLeader({
    required this.rank,
    required this.name,
    required this.flag,
    required this.tss,
    required this.elevation,
    required this.km,
    this.isPro = false,
    this.isCurrentUser = false,
  });
}

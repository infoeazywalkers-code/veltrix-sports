import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants.dart';
import '../../core/errors/error_handler.dart';
import '../../models/social/athlete_card.dart';
import '../../providers.dart';
import '../../services/auth/auth_service.dart';
import 'athlete_profile_screen.dart';

const List<String> _kSportFilter = <String>[
  'All',
  'run',
  'bike',
  'swim',
  'strength',
];

/// Find-athletes discovery (Phase 1).
///
/// Reads `athlete_directory` (limit 50), excludes cards with
/// `showOnLeaderboards == false`, and filters client-side by search
/// text (name/handle/team/location) and sport.
class AthleteDiscoveryScreen extends ConsumerStatefulWidget {
  const AthleteDiscoveryScreen({super.key});

  @override
  ConsumerState<AthleteDiscoveryScreen> createState() =>
      _AthleteDiscoveryScreenState();
}

class _AthleteDiscoveryScreenState
    extends ConsumerState<AthleteDiscoveryScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  String _sport = 'All';

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
        appBar: AppBar(title: const Text('Find Athletes')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.people_outline,
                  size: 64,
                  color: isDark ? Colors.white : navy,
                ),
                const SizedBox(height: 16),
                Text(
                  'Sign in to discover athletes',
                  style: TextStyle(
                    color: isDark ? Colors.white : navy,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Athlete discovery is available to signed-in members.',
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

    final directoryAsync = ref.watch(athleteDirectoryProvider(50));

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Find Athletes',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          TextField(
            controller: _searchController,
            onChanged: (val) => setState(() => _query = val.trim()),
            decoration: InputDecoration(
              hintText: 'Search name, handle, team, location',
              prefixIcon: const Icon(Icons.search),
              suffixIcon:
                  _query.isNotEmpty
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
                items:
                    _kSportFilter
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
          directoryAsync.when(
            loading:
                () => const Padding(
                  padding: EdgeInsets.symmetric(vertical: 48),
                  child: Center(child: CircularProgressIndicator(color: navy)),
                ),
            error:
                (e, _) => _DiscoveryError(
                  message: ErrorHandler.getUserMessage(e),
                  onRetry: () => ref.invalidate(athleteDirectoryProvider(50)),
                ),
            data: (cards) {
              final filtered = _filter(cards);
              if (filtered.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 48),
                  child: Center(
                    child: Text(
                      cards.isEmpty
                          ? 'No athletes have published their card yet.'
                          : 'No athletes match your search.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: isDark ? const Color(0xFF78909C) : muted,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                );
              }
              return Column(
                children:
                    filtered
                        .map(
                          (card) => Padding(
                            padding: const EdgeInsets.only(bottom: 9),
                            child: _AthleteRow(
                              card: card,
                              onTap:
                                  () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (_) => AthleteProfileScreen(
                                            uid: card.uid,
                                          ),
                                    ),
                                  ),
                            ),
                          ),
                        )
                        .toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  List<AthleteCard> _filter(List<AthleteCard> cards) {
    final q = _query.toLowerCase();
    return cards.where((card) {
      if (!card.showOnLeaderboards) return false;
      if (_sport != 'All' && !card.sports.contains(_sport)) return false;
      if (q.isEmpty) return true;
      return card.displayName.toLowerCase().contains(q) ||
          card.handle.toLowerCase().contains(q) ||
          card.team.toLowerCase().contains(q) ||
          card.location.toLowerCase().contains(q);
    }).toList();
  }
}

class _AthleteRow extends StatelessWidget {
  final AthleteCard card;
  final VoidCallback onTap;

  const _AthleteRow({required this.card, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final initials =
        card.displayName
            .split(' ')
            .map((w) => w.isNotEmpty ? w[0] : '')
            .take(2)
            .join()
            .toUpperCase();
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: navy,
                backgroundImage:
                    card.photoUrl != null && card.photoUrl!.isNotEmpty
                        ? NetworkImage(card.photoUrl!)
                        : null,
                child:
                    card.photoUrl == null || card.photoUrl!.isEmpty
                        ? Text(
                          initials.isNotEmpty ? initials : 'A',
                          style: const TextStyle(
                            color: lime,
                            fontWeight: FontWeight.w900,
                          ),
                        )
                        : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      card.displayName.isNotEmpty
                          ? card.displayName
                          : 'Athlete',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        color: isDark ? Colors.white : navy,
                      ),
                    ),
                    if (card.handle.isNotEmpty || card.location.isNotEmpty)
                      Text(
                        [
                          if (card.handle.isNotEmpty) card.handle,
                          if (card.location.isNotEmpty) card.location,
                        ].join('  •  '),
                        style: TextStyle(
                          color: isDark ? const Color(0xFF78909C) : muted,
                          fontSize: 12,
                        ),
                      ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: isDark ? const Color(0xFF78909C) : muted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DiscoveryError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _DiscoveryError({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Center(
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

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants.dart';
import '../../core/errors/error_handler.dart';
import '../../models/user/user_preferences.dart';
import '../../providers.dart';
import 'account_deletion_screen.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = ref.watch(userPreferencesProvider).valueOrNull;

    // Scaffold + AppBar so pushed routes (e.g. from Profile) get system
    // back and an in-app back button. When hosted in the shell, the
    // AppBar back button auto-hides (nothing to pop) and only the title
    // shows.
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(
            'Settings',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color:
                  (Theme.of(context).brightness == Brightness.dark
                      ? Colors.white
                      : navy),
            ),
          ),
          const SizedBox(height: 24),

          // Appearance
          _SettingsSection(
            title: 'Appearance',
            child: _ThemeToggle(
              current: prefs?.theme.mode ?? ThemeModePreference.system,
              onChanged: (mode) => _updateTheme(context, ref, mode),
            ),
          ),
          const SizedBox(height: 16),

          // Units
          _SettingsSection(
            title: 'Units',
            child: _UnitToggle(
              current: prefs?.display.unitSystem ?? UnitSystem.metric,
              onChanged: (unit) => _updateUnit(context, ref, unit),
            ),
          ),
          const SizedBox(height: 16),

          // Training Zones
          _SettingsSection(
            title: 'Training Zones',
            child: _ZoneSummary(
              zones: prefs?.heartRateZones,
              maxHr: prefs?.physical.calculatedMaxHr ?? 190,
            ),
          ),
          const SizedBox(height: 16),

          // Notifications
          _SettingsSection(
            title: 'Notifications',
            child: _NotificationToggles(
              prefs: prefs?.notifications,
              onChanged: (n) => _updateNotifications(context, ref, n),
            ),
          ),
          const SizedBox(height: 16),

          // Schedule
          _SettingsSection(
            title: 'Schedule',
            child: _ScheduleEditor(
              schedule: prefs?.schedule,
              onChanged: (s) => _updateSchedule(context, ref, s),
            ),
          ),
          const SizedBox(height: 16),

          // Privacy
          _SettingsSection(
            title: 'Privacy',
            child: _PrivacyToggles(
              privacy: prefs?.privacy,
              onChanged: (p) => _updatePrivacy(context, ref, p),
            ),
          ),
          const SizedBox(height: 16),

          // Account
          _SettingsSection(
            title: 'Account',
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(
                Icons.delete_forever_outlined,
                color: Colors.red,
              ),
              title: const Text(
                'Delete account',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Colors.red,
                ),
              ),
              trailing: Icon(
                Icons.chevron_right,
                color:
                    (Theme.of(context).brightness == Brightness.dark
                        ? const Color(0xFF78909C)
                        : muted),
              ),
              onTap:
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AccountDeletionScreen(),
                    ),
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _updateTheme(
    BuildContext context,
    WidgetRef ref,
    ThemeModePreference mode,
  ) async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;
    try {
      await ref.read(preferencesServiceProvider).update(user.uid, {
        'theme.mode': mode.name,
      });
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(ErrorHandler.getUserMessage(e))));
      }
    }
  }

  Future<void> _updateUnit(
    BuildContext context,
    WidgetRef ref,
    UnitSystem unit,
  ) async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;
    try {
      await ref.read(preferencesServiceProvider).update(user.uid, {
        'display.unitSystem': unit.name,
      });
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(ErrorHandler.getUserMessage(e))));
      }
    }
  }

  Future<void> _updateNotifications(
    BuildContext context,
    WidgetRef ref,
    NotificationPreferences n,
  ) async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;
    try {
      await ref.read(preferencesServiceProvider).update(user.uid, {
        'notifications': n.toMap(),
      });
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(ErrorHandler.getUserMessage(e))));
      }
    }
  }

  Future<void> _updateSchedule(
    BuildContext context,
    WidgetRef ref,
    SchedulePreferences s,
  ) async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;
    try {
      await ref.read(preferencesServiceProvider).update(user.uid, {
        'schedule': s.toMap(),
      });
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(ErrorHandler.getUserMessage(e))));
      }
    }
  }

  Future<void> _updatePrivacy(
    BuildContext context,
    WidgetRef ref,
    PrivacyPreferences p,
  ) async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;
    try {
      await ref.read(preferencesServiceProvider).update(user.uid, {
        'privacy': p.toMap(),
      });
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(ErrorHandler.getUserMessage(e))));
      }
    }
  }
}

// ---------------------------------------------------------------------------
// Private widgets
// ---------------------------------------------------------------------------

class _SettingsSection extends StatelessWidget {
  final String title;
  final Widget child;

  const _SettingsSection({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color:
                    (Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : navy),
              ),
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}

class _ThemeToggle extends StatelessWidget {
  final ThemeModePreference current;
  final ValueChanged<ThemeModePreference> onChanged;

  const _ThemeToggle({required this.current, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<ThemeModePreference>(
      segments: const [
        ButtonSegment(value: ThemeModePreference.system, label: Text('System')),
        ButtonSegment(value: ThemeModePreference.light, label: Text('Light')),
        ButtonSegment(value: ThemeModePreference.dark, label: Text('Dark')),
      ],
      selected: {current},
      onSelectionChanged: (v) => onChanged(v.first),
    );
  }
}

class _UnitToggle extends StatelessWidget {
  final UnitSystem current;
  final ValueChanged<UnitSystem> onChanged;

  const _UnitToggle({required this.current, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<UnitSystem>(
      segments: const [
        ButtonSegment(value: UnitSystem.metric, label: Text('Metric')),
        ButtonSegment(value: UnitSystem.imperial, label: Text('Imperial')),
      ],
      selected: {current},
      onSelectionChanged: (v) => onChanged(v.first),
    );
  }
}

class _ZoneSummary extends StatelessWidget {
  final HeartRateZones? zones;
  final int maxHr;

  const _ZoneSummary({this.zones, required this.maxHr});

  @override
  Widget build(BuildContext context) {
    final z = zones ?? HeartRateZones.autoFromMaxHr(maxHr);
    return Column(
      children:
          z.zones
              .map(
                (zone) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 100,
                        child: Text(
                          zone.label,
                          style: const TextStyle(fontSize: 13),
                        ),
                      ),
                      Expanded(
                        child: LinearProgressIndicator(
                          value: zone.max / maxHr,
                          backgroundColor: Colors.grey[200],
                          color: _zoneColor(z.zones.indexOf(zone)),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${zone.min}-${zone.max}',
                        style: TextStyle(
                          fontSize: 13,
                          color:
                              (Theme.of(context).brightness == Brightness.dark
                                  ? const Color(0xFF78909C)
                                  : muted),
                        ),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
    );
  }

  Color _zoneColor(int index) {
    const colors = [
      Colors.green,
      Colors.blue,
      Colors.orange,
      Colors.red,
      Colors.purple,
    ];
    return colors[index % colors.length];
  }
}

class _NotificationToggles extends StatelessWidget {
  final NotificationPreferences? prefs;
  final ValueChanged<NotificationPreferences> onChanged;

  const _NotificationToggles({this.prefs, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final n = prefs ?? const NotificationPreferences();
    return Column(
      children: [
        SwitchListTile(
          title: const Text('Workout Reminders'),
          value: n.workoutReminders,
          onChanged: (v) => onChanged(n.copyWith(workoutReminders: v)),
          contentPadding: EdgeInsets.zero,
        ),
        SwitchListTile(
          title: const Text('Coach Messages'),
          value: n.coachMessages,
          onChanged: (v) => onChanged(n.copyWith(coachMessages: v)),
          contentPadding: EdgeInsets.zero,
        ),
        SwitchListTile(
          title: const Text('Weekly Summary'),
          value: n.weeklySummary,
          onChanged: (v) => onChanged(n.copyWith(weeklySummary: v)),
          contentPadding: EdgeInsets.zero,
        ),
        SwitchListTile(
          title: const Text('Achievements'),
          value: n.achievements,
          onChanged: (v) => onChanged(n.copyWith(achievements: v)),
          contentPadding: EdgeInsets.zero,
        ),
      ],
    );
  }
}

class _ScheduleEditor extends StatelessWidget {
  final SchedulePreferences? schedule;
  final ValueChanged<SchedulePreferences> onChanged;

  const _ScheduleEditor({this.schedule, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final s = schedule ?? const SchedulePreferences();
    final dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Available Days',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: List.generate(7, (i) {
            final day = i + 1;
            final selected = s.availableDays.contains(day);
            return FilterChip(
              label: Text(dayNames[i]),
              selected: selected,
              onSelected: (isSelected) {
                final newDays = List<int>.from(s.availableDays);
                if (isSelected) {
                  newDays.add(day);
                } else {
                  newDays.remove(day);
                }
                onChanged(s.copyWith(availableDays: newDays..sort()));
              },
            );
          }),
        ),
        const SizedBox(height: 16),
        const Text('Rest Days', style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: List.generate(7, (i) {
            final day = i + 1;
            final selected = s.restDays.contains(day);
            return FilterChip(
              label: Text(dayNames[i]),
              selected: selected,
              onSelected: (isSelected) {
                final newDays = List<int>.from(s.restDays);
                if (isSelected) {
                  newDays.add(day);
                } else {
                  newDays.remove(day);
                }
                onChanged(s.copyWith(restDays: newDays..sort()));
              },
            );
          }),
        ),
      ],
    );
  }
}

class _PrivacyToggles extends StatelessWidget {
  final PrivacyPreferences? privacy;
  final ValueChanged<PrivacyPreferences> onChanged;

  const _PrivacyToggles({this.privacy, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final p = privacy ?? const PrivacyPreferences();
    return Column(
      children: [
        SwitchListTile(
          title: const Text('Profile Visible to Coaches'),
          value: p.profileVisibleToCoaches,
          onChanged: (v) => onChanged(p.copyWith(profileVisibleToCoaches: v)),
          contentPadding: EdgeInsets.zero,
        ),
        SwitchListTile(
          title: const Text('Activity Feed Visible'),
          value: p.activityFeedVisible,
          onChanged: (v) => onChanged(p.copyWith(activityFeedVisible: v)),
          contentPadding: EdgeInsets.zero,
        ),
        SwitchListTile(
          title: const Text('Share Location in Workouts'),
          value: p.shareLocationInWorkouts,
          onChanged: (v) => onChanged(p.copyWith(shareLocationInWorkouts: v)),
          contentPadding: EdgeInsets.zero,
        ),
        SwitchListTile(
          title: const Text('Show on Leaderboards'),
          value: p.showOnLeaderboards,
          onChanged: (v) => onChanged(p.copyWith(showOnLeaderboards: v)),
          contentPadding: EdgeInsets.zero,
        ),
        SwitchListTile(
          title: const Text('Allow Coach Data Access'),
          value: p.allowCoachDataAccess,
          onChanged: (v) => onChanged(p.copyWith(allowCoachDataAccess: v)),
          contentPadding: EdgeInsets.zero,
        ),
        SwitchListTile(
          title: const Text('Analytics Enabled'),
          value: p.analyticsEnabled,
          onChanged: (v) => onChanged(p.copyWith(analyticsEnabled: v)),
          contentPadding: EdgeInsets.zero,
        ),
      ],
    );
  }
}

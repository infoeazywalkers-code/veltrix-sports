import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/user/user_preferences.dart';
import '../../providers.dart';
import '../../core/errors/error_handler.dart';
import '../theme.dart';
import '../widgets/mobile_card.dart';

class MobileSettingsScreen extends ConsumerWidget {
  const MobileSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = ref.watch(userPreferencesProvider).valueOrNull;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Theme
          MCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Appearance', style: M.adaptiveTitle(context)),
                const SizedBox(height: 12),
                SegmentedButton<ThemeModePreference>(
                  segments: const [
                    ButtonSegment(
                      value: ThemeModePreference.system,
                      label: Text('System'),
                    ),
                    ButtonSegment(
                      value: ThemeModePreference.light,
                      label: Text('Light'),
                    ),
                    ButtonSegment(
                      value: ThemeModePreference.dark,
                      label: Text('Dark'),
                    ),
                  ],
                  selected: {prefs?.theme.mode ?? ThemeModePreference.system},
                  onSelectionChanged:
                      (v) => _updateField(
                        context,
                        ref,
                        'theme.mode',
                        v.first.name,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Units
          MCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Units', style: M.adaptiveTitle(context)),
                const SizedBox(height: 12),
                SegmentedButton<UnitSystem>(
                  segments: const [
                    ButtonSegment(
                      value: UnitSystem.metric,
                      label: Text('Metric'),
                    ),
                    ButtonSegment(
                      value: UnitSystem.imperial,
                      label: Text('Imperial'),
                    ),
                  ],
                  selected: {prefs?.display.unitSystem ?? UnitSystem.metric},
                  onSelectionChanged:
                      (v) => _updateField(
                        context,
                        ref,
                        'display.unitSystem',
                        v.first.name,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Notifications
          MCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Notifications', style: M.adaptiveTitle(context)),
                const SizedBox(height: 8),
                SwitchListTile(
                  title: const Text('Workout Reminders'),
                  value: prefs?.notifications.workoutReminders ?? true,
                  onChanged:
                      (v) => _updateField(
                        context,
                        ref,
                        'notifications.workoutReminders',
                        v,
                      ),
                  contentPadding: EdgeInsets.zero,
                ),
                SwitchListTile(
                  title: const Text('Coach Messages'),
                  value: prefs?.notifications.coachMessages ?? true,
                  onChanged:
                      (v) => _updateField(
                        context,
                        ref,
                        'notifications.coachMessages',
                        v,
                      ),
                  contentPadding: EdgeInsets.zero,
                ),
                SwitchListTile(
                  title: const Text('Weekly Summary'),
                  value: prefs?.notifications.weeklySummary ?? true,
                  onChanged:
                      (v) => _updateField(
                        context,
                        ref,
                        'notifications.weeklySummary',
                        v,
                      ),
                  contentPadding: EdgeInsets.zero,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Schedule
          MCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Rest Days', style: M.adaptiveTitle(context)),
                const SizedBox(height: 8),
                _RestDayChips(
                  restDays: prefs?.schedule.restDays ?? const [7],
                  onChanged: (days) => _updateSchedule(context, ref, days),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Privacy
          MCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Privacy', style: M.adaptiveTitle(context)),
                const SizedBox(height: 8),
                SwitchListTile(
                  title: const Text('Profile Visible to Coaches'),
                  value: prefs?.privacy.profileVisibleToCoaches ?? true,
                  onChanged:
                      (v) => _updateField(
                        context,
                        ref,
                        'privacy.profileVisibleToCoaches',
                        v,
                      ),
                  contentPadding: EdgeInsets.zero,
                ),
                SwitchListTile(
                  title: const Text('Activity Feed Visible'),
                  value: prefs?.privacy.activityFeedVisible ?? true,
                  onChanged:
                      (v) => _updateField(
                        context,
                        ref,
                        'privacy.activityFeedVisible',
                        v,
                      ),
                  contentPadding: EdgeInsets.zero,
                ),
                SwitchListTile(
                  title: const Text('Share Location in Workouts'),
                  value: prefs?.privacy.shareLocationInWorkouts ?? true,
                  onChanged:
                      (v) => _updateField(
                        context,
                        ref,
                        'privacy.shareLocationInWorkouts',
                        v,
                      ),
                  contentPadding: EdgeInsets.zero,
                ),
                SwitchListTile(
                  title: const Text('Show on Leaderboards'),
                  value: prefs?.privacy.showOnLeaderboards ?? true,
                  onChanged:
                      (v) => _updateField(
                        context,
                        ref,
                        'privacy.showOnLeaderboards',
                        v,
                      ),
                  contentPadding: EdgeInsets.zero,
                ),
                SwitchListTile(
                  title: const Text('Allow Coach Data Access'),
                  value: prefs?.privacy.allowCoachDataAccess ?? true,
                  onChanged:
                      (v) => _updateField(
                        context,
                        ref,
                        'privacy.allowCoachDataAccess',
                        v,
                      ),
                  contentPadding: EdgeInsets.zero,
                ),
                SwitchListTile(
                  title: const Text('Analytics Enabled'),
                  value: prefs?.privacy.analyticsEnabled ?? true,
                  onChanged:
                      (v) => _updateField(
                        context,
                        ref,
                        'privacy.analyticsEnabled',
                        v,
                      ),
                  contentPadding: EdgeInsets.zero,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _updateField(
    BuildContext context,
    WidgetRef ref,
    String path,
    dynamic value,
  ) async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;
    try {
      await ref
          .read(preferencesServiceProvider)
          .updateField(user.uid, path, value);
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
    List<int> restDays,
  ) async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;
    try {
      await ref.read(preferencesServiceProvider).update(user.uid, {
        'schedule.restDays': restDays,
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

class _RestDayChips extends StatelessWidget {
  final List<int> restDays;
  final ValueChanged<List<int>> onChanged;

  const _RestDayChips({required this.restDays, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return Wrap(
      spacing: 8,
      children: List.generate(7, (i) {
        final day = i + 1;
        final selected = restDays.contains(day);
        return FilterChip(
          label: Text(dayNames[i]),
          selected: selected,
          onSelected: (isSelected) {
            final newDays = List<int>.from(restDays);
            if (isSelected) {
              newDays.add(day);
            } else {
              newDays.remove(day);
            }
            onChanged(newDays..sort());
          },
        );
      }),
    );
  }
}

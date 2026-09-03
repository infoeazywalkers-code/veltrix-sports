import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets/mobile_card.dart';
import '../widgets/mobile_section.dart';

class MobileWorkoutDetailScreen extends StatelessWidget {
  const MobileWorkoutDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Workout details'),
        actions: [
          IconButton(onPressed: () => _showWorkoutMenu(context), icon: const Icon(Icons.more_horiz)),
        ],
      ),
      body: ListView(
        padding: M.pagePadding(context),
        children: [
          MBanner(
            backgroundColor: M.navy,
            padding: const EdgeInsets.all(M.base),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('RUN • TODAY',
                    style: TextStyle(
                      color: M.lime,
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                    )),
                SizedBox(height: M.md),
                Text('Aerobic endurance',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                    )),
                SizedBox(height: M.xs),
                Text('Stay relaxed and keep your effort in Zone 2.',
                    style: TextStyle(color: Colors.white70)),
              ],
            ),
          ),
          const SizedBox(height: M.base),
          MCard(
            child: Column(
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _Metric('45m', 'Duration'),
                    _Metric('7.2 km', 'Distance'),
                    _Metric('62', 'TSS'),
                  ],
                ),
                const SizedBox(height: M.base),
                const Divider(),
                const ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.speed, color: M.blue),
                  title: Text('Target pace'),
                  trailing: Text('5:55–6:15 /km',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        color: M.navy,
                      )),
                ),
              ],
            ),
          ),
          const SizedBox(height: M.lg),
          MSection(
            title: 'Workout structure',
            child: Column(
              children: [
                for (final step in [
                  'Warm up • 10 min',
                  'Aerobic run • 30 min',
                  'Cool down • 5 min',
                ])
                  Padding(
                    padding: const EdgeInsets.only(bottom: M.sm),
                    child: MCard(
                      child: Row(
                        children: [
                          const Icon(Icons.drag_handle,
                              color: M.blue, size: M.iconMd),
                          const SizedBox(width: M.md),
                          Text(step,
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                              )),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: M.base),
          FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: M.lime,
              foregroundColor: M.navy,
              minimumSize: const Size.fromHeight(52),
            ),
            onPressed: () => showDialog<void>(
              context: context,
              builder: (dialogContext) => AlertDialog(
                title: const Text('Workout started'),
                content: const Text('Your timer is ready. Stay relaxed and enjoy the session.'),
                actions: [FilledButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Done'))],
              ),
            ),
            icon: const Icon(Icons.play_arrow),
            label: const Text('Start workout',
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
          ),
          const SizedBox(height: M.xxl),
        ],
      ),
    );
  }
}

void _showWorkoutMenu(BuildContext context) {
  showModalBottomSheet<void>(
    context: context,
    builder: (sheetContext) => SafeArea(
      child: Wrap(children: [
        ListTile(leading: const Icon(Icons.edit), title: const Text('Edit workout'), onTap: () => Navigator.pop(sheetContext)),
        ListTile(leading: const Icon(Icons.delete_outline), title: const Text('Remove workout'), onTap: () => Navigator.pop(sheetContext)),
      ]),
    ),
  );
}

void main() => runApp(MaterialApp(
  theme: M.theme,
  home: const MobileWorkoutDetailScreen(),
));

class _Metric extends StatelessWidget {
  final String value;
  final String label;
  const _Metric(this.value, this.label);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: M.statBig),
        Text(label, style: M.statLabel),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import '../constants.dart';
import '../widgets/heading.dart';

class ExploreScreen extends StatelessWidget {
  final ValueChanged<int>? onNavigate;
  const ExploreScreen({super.key, this.onNavigate});

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(18),
    children: [
      TextField(
        decoration: InputDecoration(
          hintText: 'Search plans, events, coaches',
          prefixIcon: const Icon(Icons.search),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
        ),
      ),
      const SizedBox(height: 22),
      const SectionHeading('Browse Veltrix'),
      const SizedBox(height: 10),
      Row(
        children: [
          Expanded(
            child: _ExploreTile('Training plans', Icons.event_note, blue, onTap: () => showFeatureMessage(context, 'Training plans are ready to explore.')),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _ExploreTile('Find a coach', Icons.groups, purple, onTap: () => onNavigate?.call(6)),
          ),
        ],
      ),
      const SizedBox(height: 10),
      Row(
        children: [
          Expanded(
            child: _ExploreTile('Sports events', Icons.emoji_events, orange, onTap: () => showFeatureMessage(context, 'Events are coming to your calendar soon.')),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _ExploreTile('My tickets', Icons.confirmation_number, teal, onTap: () => showFeatureMessage(context, 'Your event tickets will appear here.')),
          ),
        ],
      ),
      const SizedBox(height: 10),
      Row(
        children: [
          Expanded(
            child: _ExploreTile('Premium', Icons.workspace_premium, navy, onTap: () => onNavigate?.call(5)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _ExploreTile('Devices', Icons.devices_other, blue, onTap: () => onNavigate?.call(7)),
          ),
        ],
      ),
      const SizedBox(height: 24),
      const SectionHeading('Recommended plan', action: 'See plans'),
      const SizedBox(height: 10),
      Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: navy, borderRadius: BorderRadius.circular(20)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.directions_run, color: lime),
            const SizedBox(height: 22),
            const Text(
              'Marathon Training Pro',
              style: TextStyle(color: Colors.white, fontSize: 21, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 6),
            const Text(
              'Build endurance, speed and race-day confidence with a structured 16-week plan.',
              style: TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 15),
            const Text('16 weeks  \u2022  Coach Amit', style: TextStyle(color: Colors.white70)),
            const SizedBox(height: 15),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: lime, foregroundColor: navy),
              onPressed: () => showFeatureMessage(context, 'Marathon Training Pro has been added to your plans.'),
              child: const Text('View plan', style: TextStyle(fontWeight: FontWeight.w900)),
            ),
          ],
        ),
      ),
      const SizedBox(height: 24),
      const SectionHeading('Upcoming events', action: 'See all'),
      const SizedBox(height: 10),
      const _EventRow('25', 'OCT', 'Mumbai Half Marathon', 'Mumbai \u2022 Running'),
      const SizedBox(height: 9),
      const _EventRow('20', 'NOV', 'Delhi Cycling Grand Prix', 'New Delhi \u2022 Cycling'),
    ],
  );
}

void main() => runApp(MaterialApp(
  theme: ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: bg,
    colorScheme: ColorScheme.fromSeed(seedColor: navy),
  ),
  home: const Scaffold(body: ExploreScreen()),
));

class _ExploreTile extends StatelessWidget {
  final String text;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;
  const _ExploreTile(this.text, this.icon, this.color, {this.onTap});
  @override
  Widget build(BuildContext context) => Card(
    child: InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: color.withValues(alpha: .12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(height: 15),
            Text(text, style: const TextStyle(fontWeight: FontWeight.w900, color: navy)),
            const Icon(Icons.arrow_forward, size: 16, color: muted),
          ],
        ),
      ),
    ),
  );
}

class _EventRow extends StatelessWidget {
  final String d, m, title, sub;
  const _EventRow(this.d, this.m, this.title, this.sub);
  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 50,
            padding: const EdgeInsets.symmetric(vertical: 6),
            decoration: BoxDecoration(color: navy, borderRadius: BorderRadius.circular(12)),
            child: Column(
              children: [
                Text(d, style: const TextStyle(color: Colors.white, fontSize: 19, fontWeight: FontWeight.w900)),
                Text(m, style: const TextStyle(color: lime, fontSize: 9, fontWeight: FontWeight.w900)),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w900, color: navy)),
                Text(sub, style: const TextStyle(color: muted, fontSize: 11)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: muted),
        ],
      ),
    ),
  );
}

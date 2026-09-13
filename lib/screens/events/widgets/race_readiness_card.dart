import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/constants.dart';
import '../../../services/performance/race_readiness_service.dart';

/// Displays one event's [RaceReadiness]: title/date/countdown header,
/// score ring, four component mini-bars, verdict and taper advice.
///
/// Pure display widget — loading/error/empty states are handled by the
/// parent section. When [onRegister] is non-null a
/// 'Register to track readiness' CTA is shown; otherwise the card assumes
/// the event is already registered.
class RaceReadinessCard extends StatelessWidget {
  final String eventTitle;
  final DateTime eventDate;
  final RaceReadiness readiness;
  final VoidCallback? onRegister;
  final bool registering;

  const RaceReadinessCard({
    super.key,
    required this.eventTitle,
    required this.eventDate,
    required this.readiness,
    this.onRegister,
    this.registering = false,
  });

  @override
  Widget build(BuildContext context) {
    final bool dark = Theme.of(context).brightness == Brightness.dark;
    final Color titleColor = dark ? Colors.white : navy;
    final Color subColor = dark ? const Color(0xFF78909C) : muted;
    final String countdown = _countdownLabel(readiness.daysOut);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.emoji_events_rounded, color: orange, size: 26),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        eventTitle,
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                          color: titleColor,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _dateLabel(eventDate),
                        style: TextStyle(color: subColor, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: navy,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    countdown,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _ScoreRing(score: readiness.score, verdict: readiness.verdict),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    children: [
                      _ComponentBar(
                        label: 'Fitness',
                        points: readiness.fitnessPts,
                        max: 40,
                        color: blue,
                      ),
                      const SizedBox(height: 8),
                      _ComponentBar(
                        label: 'Freshness',
                        points: readiness.freshnessPts,
                        max: 25,
                        color: teal,
                      ),
                      const SizedBox(height: 8),
                      _ComponentBar(
                        label: 'Consistency',
                        points: readiness.consistencyPts,
                        max: 20,
                        color: purple,
                      ),
                      const SizedBox(height: 8),
                      _ComponentBar(
                        label: 'Taper',
                        points: readiness.taperPts,
                        max: 15,
                        color: orange,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Icon(
                  _verdictIcon(readiness.verdict),
                  color: _verdictColor(readiness.verdict),
                  size: 18,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    readiness.verdict,
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 15,
                      color: titleColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              readiness.taperAdvice,
              style: TextStyle(color: subColor, height: 1.45, fontSize: 13),
            ),
            if (onRegister != null) ...[
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: lime,
                    foregroundColor: navy,
                  ),
                  onPressed: registering ? null : onRegister,
                  child:
                      registering
                          ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: navy,
                            ),
                          )
                          : const Text(
                            'Register to track readiness',
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

String _countdownLabel(int daysOut) {
  if (daysOut <= 0) return 'Race day';
  if (daysOut == 1) return '1 day out';
  return '$daysOut days out';
}

String _dateLabel(DateTime date) {
  const List<String> months = <String>[
    '',
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  final String month = months[date.month.clamp(1, 12)];
  return '$month ${date.day}, ${date.year}';
}

IconData _verdictIcon(String verdict) {
  switch (verdict) {
    case 'Race ready':
      return Icons.verified_rounded;
    case 'On track':
      return Icons.trending_up_rounded;
    case 'Needs work':
      return Icons.construction_rounded;
    default:
      return Icons.warning_amber_rounded;
  }
}

Color _verdictColor(String verdict) {
  switch (verdict) {
    case 'Race ready':
      return successGreen;
    case 'On track':
      return blue;
    case 'Needs work':
      return orange;
    default:
      return Colors.redAccent;
  }
}

class _ScoreRing extends StatelessWidget {
  final int score;
  final String verdict;

  const _ScoreRing({required this.score, required this.verdict});

  @override
  Widget build(BuildContext context) {
    final bool dark = Theme.of(context).brightness == Brightness.dark;
    return SizedBox(
      width: 96,
      height: 96,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: const Size(96, 96),
            painter: _RingPainter(
              fraction: score / 100,
              color: _verdictColor(verdict),
              trackColor:
                  dark
                      ? Colors.white.withValues(alpha: 0.12)
                      : navy.withValues(alpha: 0.10),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$score',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  color: dark ? Colors.white : navy,
                ),
              ),
              Text(
                '/ 100',
                style: TextStyle(
                  fontSize: 10,
                  color: dark ? const Color(0xFF78909C) : muted,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double fraction;
  final Color color;
  final Color trackColor;

  _RingPainter({
    required this.fraction,
    required this.color,
    required this.trackColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = Offset(size.width / 2, size.height / 2);
    final double radius = (size.width - 12) / 2;
    final Paint track =
        Paint()
          ..color = trackColor
          ..strokeWidth = 10
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, track);
    final Paint progress =
        Paint()
          ..color = color
          ..strokeWidth = 10
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      (fraction.clamp(0.0, 1.0)) * math.pi * 2,
      false,
      progress,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) =>
      oldDelegate.fraction != fraction ||
      oldDelegate.color != color ||
      oldDelegate.trackColor != trackColor;
}

class _ComponentBar extends StatelessWidget {
  final String label;
  final int points;
  final int max;
  final Color color;

  const _ComponentBar({
    required this.label,
    required this.points,
    required this.max,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final bool dark = Theme.of(context).brightness == Brightness.dark;
    final double fraction = max <= 0 ? 0 : (points / max).clamp(0.0, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: dark ? const Color(0xFFB0BEC5) : muted,
                ),
              ),
            ),
            Text(
              '$points/$max',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w900,
                color: dark ? Colors.white : navy,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: fraction,
            minHeight: 7,
            backgroundColor:
                dark
                    ? Colors.white.withValues(alpha: 0.12)
                    : navy.withValues(alpha: 0.10),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}

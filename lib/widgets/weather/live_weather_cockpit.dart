import 'package:flutter/material.dart';

class LiveWeatherCockpit extends StatelessWidget {
  final String location;
  final double temperatureC;
  final String condition;
  final int humidityPct;
  final double windSpeedKmh;
  final String windDirection;
  final double feelsLikeC;
  final double uvIndex;
  final double? dewPointC;
  final double? visibilityKm;
  final double? pressureMb;

  const LiveWeatherCockpit({
    super.key,
    required this.location,
    required this.temperatureC,
    required this.condition,
    required this.humidityPct,
    required this.windSpeedKmh,
    required this.windDirection,
    required this.feelsLikeC,
    required this.uvIndex,
    this.dewPointC,
    this.visibilityKm,
    this.pressureMb,
  });

  String _conditionEmoji(String condition) {
    final c = condition.toLowerCase();
    if (c.contains('sun') || c.contains('clear')) return '☀️';
    if (c.contains('partly')) return '⛅';
    if (c.contains('cloud')) return '☁️';
    if (c.contains('rain') || c.contains('drizzle')) return '🌧️';
    if (c.contains('thunder')) return '⛈️';
    if (c.contains('snow')) return '❄️';
    if (c.contains('fog') || c.contains('mist')) return '🌫️';
    if (c.contains('wind')) return '💨';
    return '🌤️';
  }

  Color _uvColor(double uv) {
    if (uv >= 11) return const Color(0xFFA855F7);
    if (uv >= 8) return const Color(0xFFEF4444);
    if (uv >= 6) return const Color(0xFFF97316);
    if (uv >= 3) return const Color(0xFFFBBF24);
    return const Color(0xFF10B981);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [const Color(0xFF1E3A5F), const Color(0xFF0F2035)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Location & condition
          Row(
            children: [
              Text(
                _conditionEmoji(condition),
                style: const TextStyle(fontSize: 28),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      location,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      condition,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.6),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${temperatureC.round()}°C',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    'Feels ${feelsLikeC.round()}°C',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.5),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Key metrics row
          Row(
            children: [
              _weatherMetric(
                '💨',
                'Wind',
                '${windSpeedKmh.round()} km/h $windDirection',
              ),
              const SizedBox(width: 12),
              _weatherMetric('💧', 'Humidity', '$humidityPct%'),
              const SizedBox(width: 12),
              _weatherMetric(
                '☀️',
                'UV',
                '${uvIndex.round()}',
                color: _uvColor(uvIndex),
              ),
            ],
          ),

          if (dewPointC != null ||
              visibilityKm != null ||
              pressureMb != null) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                if (dewPointC != null)
                  _weatherMetric('🌡️', 'Dew Point', '${dewPointC!.round()}°C'),
                if (dewPointC != null && visibilityKm != null)
                  const SizedBox(width: 12),
                if (visibilityKm != null)
                  _weatherMetric(
                    '👁️',
                    'Visibility',
                    '${visibilityKm!.round()} km',
                  ),
                if (visibilityKm != null && pressureMb != null)
                  const SizedBox(width: 12),
                if (pressureMb != null)
                  _weatherMetric('📊', 'Pressure', '${pressureMb!.round()} mb'),
              ],
            ),
          ],

          const SizedBox(height: 12),

          // Training recommendation
          _trainingRecommendation(),
        ],
      ),
    );
  }

  Widget _weatherMetric(
    String emoji,
    String label,
    String value, {
    Color? color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(emoji, style: const TextStyle(fontSize: 10)),
                const SizedBox(width: 4),
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.5),
                    fontSize: 9,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: TextStyle(
                color: color ?? Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _trainingRecommendation() {
    String recommendation;
    Color recColor;

    if (temperatureC > 30) {
      recommendation = '⚠️ High heat — hydrate heavily, reduce intensity';
      recColor = const Color(0xFFEF4444);
    } else if (temperatureC < 0) {
      recommendation = '⚠️ Sub-zero — layer up, protect extremities';
      recColor = const Color(0xFF3B82F6);
    } else if (windSpeedKmh > 40) {
      recommendation = '⚠️ Strong winds — consider sheltered route';
      recColor = const Color(0xFFF59E0B);
    } else if (uvIndex >= 8) {
      recommendation = '⚠️ High UV — sunscreen and sunglasses essential';
      recColor = const Color(0xFFF97316);
    } else if (condition.toLowerCase().contains('rain')) {
      recommendation = '🌧️ Wet conditions — waterproof layers,小心 descents';
      recColor = const Color(0xFF6366F1);
    } else {
      recommendation = '✅ Great conditions for outdoor training';
      recColor = const Color(0xFF10B981);
    }

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: recColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: recColor.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(Icons.eco, color: recColor, size: 14),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              recommendation,
              style: TextStyle(color: recColor, fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }
}

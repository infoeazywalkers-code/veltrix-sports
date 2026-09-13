import 'package:flutter/material.dart';
import '../../models/health/health_biometric.dart';

class HealthBiometricsScreen extends StatelessWidget {
  final HealthBiometricDay? latest;
  final WearableDeviceStatus? device;

  const HealthBiometricsScreen({super.key, this.latest, this.device});

  @override
  Widget build(BuildContext context) {
    final b =
        latest ??
        const HealthBiometricDay(
          date: '2026-01-15',
          recoveryScore: 82,
          hrvRmssd: 42,
          hrvBaseline: 38,
          restingHr: 52,
          sleepHours: 7.5,
          sleepQualityScore: 84,
          deepSleepPct: 16,
          remSleepPct: 19,
          spo2Pct: 98,
          respiratoryRate: 14,
          skinTempDeviationCelsius: 0.2,
          subjectiveSoreness: 2,
          subjectiveStress: 'low',
          hydrationLitres: 2.8,
          weightKg: 72.4,
          readinessRecommendation: 'Good to train',
        );

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildRecoverySection(b),
            const SizedBox(height: 20),
            _buildReadinessCard(b),
            const SizedBox(height: 20),
            _buildSleepSection(b),
            const SizedBox(height: 20),
            _buildHRVSection(b),
            const SizedBox(height: 20),
            _buildVitalSigns(b),
            const SizedBox(height: 20),
            _buildSubjectiveSection(b),
            const SizedBox(height: 20),
            _buildDeviceStatus(),
          ],
        ),
      ),
    );
  }

  Widget _buildRecoverySection(HealthBiometricDay b) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF10B981), Color(0xFF14B8A6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'RECOVERY STATUS',
            style: TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                '${b.recoveryScore}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 48,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Recovery Score',
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                  Text(
                    b.recoveryLabel,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            b.readinessRecommendation,
            style: const TextStyle(color: Colors.white60, fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _buildReadinessCard(HealthBiometricDay b) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'TODAY\'S READINESS',
            style: TextStyle(
              color: Colors.white54,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _readinessGauge(b.recoveryScore),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _readinessItem(
                      'Sleep Quality',
                      b.sleepQualityScore,
                      const Color(0xFF6366F1),
                    ),
                    _readinessItem(
                      'HRV Balance',
                      (b.hrvRmssd / b.hrvBaseline * 50).round().clamp(0, 100),
                      const Color(0xFF3B82F6),
                    ),
                    _readinessItem(
                      'Hydration',
                      (b.hydrationLitres / 3.5 * 100).round().clamp(0, 100),
                      const Color(0xFF14B8A6),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _readinessGauge(int score) {
    return SizedBox(
      width: 80,
      height: 80,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 80,
            height: 80,
            child: CircularProgressIndicator(
              value: score / 100,
              strokeWidth: 8,
              backgroundColor: Colors.white.withValues(alpha: 0.06),
              valueColor: AlwaysStoppedAnimation(
                score >= 80
                    ? const Color(0xFF10B981)
                    : score >= 60
                    ? const Color(0xFFF59E0B)
                    : const Color(0xFFEF4444),
              ),
            ),
          ),
          Text(
            '$score',
            style: TextStyle(
              color:
                  score >= 80
                      ? const Color(0xFF10B981)
                      : score >= 60
                      ? const Color(0xFFF59E0B)
                      : const Color(0xFFEF4444),
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _readinessItem(String label, int value, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.5),
              fontSize: 11,
            ),
          ),
          const Spacer(),
          Text(
            '$value',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSleepSection(HealthBiometricDay b) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
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
              const Text('🌙', style: TextStyle(fontSize: 14)),
              const SizedBox(width: 8),
              const Text(
                'SLEEP ANALYSIS',
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1,
                ),
              ),
              const Spacer(),
              Text(
                '${b.sleepHours.toStringAsFixed(1)}h total',
                style: const TextStyle(
                  color: Color(0xFF6366F1),
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _sleepPhase('Deep', b.deepSleepPct, const Color(0xFF4F46E5)),
              const SizedBox(width: 6),
              _sleepPhase('REM', b.remSleepPct, const Color(0xFF8B5CF6)),
              const SizedBox(width: 6),
              _sleepPhase(
                'Light',
                100 - b.deepSleepPct - b.remSleepPct,
                const Color(0xFFA78BFA),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _sleepMetric(
                'Score',
                '${b.sleepQualityScore}',
                const Color(0xFF6366F1),
              ),
              _sleepMetric(
                'Deep',
                '${b.deepSleepPct}%',
                const Color(0xFF4F46E5),
              ),
              _sleepMetric('REM', '${b.remSleepPct}%', const Color(0xFF8B5CF6)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _sleepPhase(String label, int pct, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(
                color: color.withValues(alpha: 0.7),
                fontSize: 10,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '$pct%',
              style: TextStyle(
                color: color,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sleepMetric(String label, String value, Color color) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.4),
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHRVSection(HealthBiometricDay b) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'HEART RATE VARIABILITY',
            style: TextStyle(
              color: Colors.white54,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${b.hrvRmssd} ms',
                    style: const TextStyle(
                      color: Color(0xFF3B82F6),
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const Text(
                    'HRV (RMSSD)',
                    style: TextStyle(color: Colors.white38, fontSize: 10),
                  ),
                ],
              ),
              const SizedBox(width: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${b.restingHr} bpm',
                    style: const TextStyle(
                      color: Color(0xFFEF4444),
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Text(
                    'Resting HR',
                    style: TextStyle(color: Colors.white38, fontSize: 10),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _hrvInsight('Overnight', '${b.hrvRmssd} ms', true),
              const SizedBox(width: 10),
              _hrvInsight('Baseline', '${b.hrvBaseline} ms', false),
            ],
          ),
        ],
      ),
    );
  }

  Widget _hrvInsight(String label, String value, bool isOvernight) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color:
              isOvernight
                  ? const Color(0xFF3B82F6).withValues(alpha: 0.1)
                  : Colors.white.withValues(alpha: 0.03),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.5),
                fontSize: 10,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                color: isOvernight ? const Color(0xFF3B82F6) : Colors.white70,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVitalSigns(HealthBiometricDay b) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'VITAL SIGNS',
            style: TextStyle(
              color: Colors.white54,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _vitalTile(
                'SpO₂',
                '${b.spo2Pct.round()}%',
                'Blood Oxygen',
                const Color(0xFF14B8A6),
              ),
              _vitalTile(
                'Temp',
                '${b.skinTempDeviationCelsius > 0 ? '+' : ''}${b.skinTempDeviationCelsius}°C',
                'Deviation',
                const Color(0xFFF59E0B),
              ),
              _vitalTile(
                'Resp',
                '${b.respiratoryRate}/min',
                'Resp Rate',
                const Color(0xFF8B5CF6),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _vitalTile(String label, String value, String subtitle, Color color) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 3),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                color: color.withValues(alpha: 0.7),
                fontSize: 9,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.3),
                fontSize: 8,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubjectiveSection(HealthBiometricDay b) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'SUBJECTIVE WELLNESS',
            style: TextStyle(
              color: Colors.white54,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _subjectiveTile(
                'Soreness',
                '${b.subjectiveSoreness}/5',
                const Color(0xFFEF4444),
              ),
              const SizedBox(width: 10),
              _subjectiveTile(
                'Stress',
                b.subjectiveStress,
                const Color(0xFFF59E0B),
              ),
              const SizedBox(width: 10),
              _subjectiveTile(
                'Hydration',
                '${b.hydrationLitres}L',
                const Color(0xFF3B82F6),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _subjectiveTile(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                color: color.withValues(alpha: 0.7),
                fontSize: 10,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeviceStatus() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'WEARABLE STATUS',
            style: TextStyle(
              color: Colors.white54,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 12),
          _deviceRow(
            'Coros Pace 3',
            'Connected',
            '🔋 84%',
            '⏱ Synced 2m ago',
            const Color(0xFF10B981),
          ),
          const SizedBox(height: 8),
          _deviceRow(
            'Whoop 4.0',
            'Connected',
            '🔋 72%',
            '⏱ Synced 5m ago',
            const Color(0xFF10B981),
          ),
          const SizedBox(height: 8),
          _deviceRow(
            'Apple Watch Ultra',
            'Sleep mode',
            '🔋 45%',
            '⏱ Synced 15m ago',
            const Color(0xFFF59E0B),
          ),
        ],
      ),
    );
  }

  Widget _deviceRow(
    String name,
    String status,
    String battery,
    String sync,
    Color color,
  ) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
              Text(status, style: TextStyle(color: color, fontSize: 10)),
            ],
          ),
        ),
        Text(
          battery,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.5),
            fontSize: 10,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          sync,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.3),
            fontSize: 9,
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants.dart';
import '../../models/activity/activity.dart';
import '../../models/training/training_plan.dart';
import '../../providers.dart';
import '../../services/training/ai_plan_service.dart';
import '../../services/training/plan_materializer.dart';
import '../../services/training/plan_templates.dart' show nextMonday;
import 'plan_detail_screen.dart';

class AiPlanGeneratorScreen extends ConsumerStatefulWidget {
  const AiPlanGeneratorScreen({super.key});

  @override
  ConsumerState<AiPlanGeneratorScreen> createState() =>
      _AiPlanGeneratorScreenState();
}

class _AiPlanGeneratorScreenState extends ConsumerState<AiPlanGeneratorScreen> {
  String _selectedGoal = 'Gran Fondo';
  String _selectedSport = 'Cycling';
  int _weeks = 12;
  double _hoursPerWeek = 10;
  String _fitnessLevel = 'Intermediate';
  String _experience = '2-5 years';

  bool _isGenerating = false;
  bool _planGenerated = false;
  bool _isStarting = false;
  Map<String, dynamic>? _basePlan;

  /// Maps the UI sport label onto [SportType].
  ///
  /// Triathlon has no [SportType] equivalent, so it falls back to cycling
  /// (the dominant discipline for workout scheduling).
  SportType _mapSport(String sport) {
    switch (sport) {
      case 'Running':
        return SportType.running;
      case 'Swimming':
        return SportType.swimming;
      case 'Rowing':
        return SportType.rowing;
      default:
        return SportType.cycling;
    }
  }

  void _generatePlan() {
    setState(() => _isGenerating = true);
    // Generated synchronously from the physiological model; the loading
    // state is kept so the UI transition stays perceptible.
    Future(() {
      // TODO: wire ftpWatts/lthrBpm/weightKg from the user profile instead
      // of these defaults.
      final plan = AIPlanService().generateBasePlan(
        sport: _mapSport(_selectedSport),
        philosophy: 'balanced',
        level: _fitnessLevel,
        totalWeeks: _weeks,
        targetWeeklyHours: _hoursPerWeek,
        ftpWatts: 200,
        lthrBpm: 160,
        weightKg: 75,
      );
      if (mounted) {
        setState(() {
          _basePlan = plan;
          _isGenerating = false;
          _planGenerated = true;
        });
      }
    });
  }

  Future<void> _startTraining() async {
    final basePlan = _basePlan;
    if (basePlan == null) return;
    final user = ref.read(currentUserProvider);
    if (user == null) {
      if (mounted) {
        showFeatureMessage(context, 'Sign in to start training');
      }
      return;
    }
    setState(() => _isStarting = true);
    try {
      final startMonday = nextMonday(DateTime.now());
      final planId = 'ai_${DateTime.now().millisecondsSinceEpoch}';
      final weeks = (basePlan['weeks'] as List? ?? const []).length;
      final totalWeeks = weeks == 0 ? _weeks : weeks;
      await ref
          .read(trainingPlanServiceProvider)
          .create(
            TrainingPlan(
              id: planId,
              userId: user.uid,
              name: '$_selectedGoal · AI Plan',
              description:
                  'AI-generated $_selectedSport plan: $_weeks weeks at ${_hoursPerWeek.toStringAsFixed(1)}h/week.',
              sport: _selectedSport,
              durationWeeks: totalWeeks,
              difficulty: _fitnessLevel,
              targetGoal: _selectedGoal,
              price: 0,
              status: 'active',
              startDate: startMonday,
              endDate: startMonday.add(Duration(days: totalWeeks * 7)),
              createdAt: DateTime.now(),
            ),
          );
      await PlanMaterializer().materializeAiBasePlan(
        userId: user.uid,
        planId: planId,
        basePlanMap: basePlan,
        startMonday: startMonday,
        sport: _selectedSport,
      );
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => PlanDetailScreen(planId: planId)),
        );
      }
    } catch (_) {
      if (mounted) {
        showFeatureMessage(
          context,
          'Could not start training. Please try again.',
        );
      }
    } finally {
      if (mounted) setState(() => _isStarting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: _planGenerated ? _buildPlanView() : _buildFormView(),
    );
  }

  Widget _buildFormView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF8B5CF6), Color(0xFF6366F1)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AI PLAN GENERATOR',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Your Personalized Training Blueprint',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'AI analyzes your fatigue curve, training load, and recovery patterns to build the perfect periodized plan.',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Goal selection
          _sectionTitle('YOUR GOAL'),
          const SizedBox(height: 10),
          _goalSelector(),

          const SizedBox(height: 20),

          // Sport selection
          _sectionTitle('SPORT'),
          const SizedBox(height: 10),
          _sportSelector(),

          const SizedBox(height: 20),

          // Duration
          _sectionTitle('DURATION: $_weeks WEEKS'),
          const SizedBox(height: 8),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: const Color(0xFF8B5CF6),
              thumbColor: const Color(0xFF8B5CF6),
              inactiveTrackColor: Colors.white.withValues(alpha: 0.06),
              trackHeight: 6,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
            ),
            child: Slider(
              value: _weeks.toDouble(),
              min: 4,
              max: 24,
              divisions: 20,
              onChanged: (v) => setState(() => _weeks = v.round()),
            ),
          ),

          const SizedBox(height: 20),

          // Hours per week
          _sectionTitle('HOURS PER WEEK: ${_hoursPerWeek.toStringAsFixed(1)}'),
          const SizedBox(height: 8),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: const Color(0xFF8B5CF6),
              thumbColor: const Color(0xFF8B5CF6),
              inactiveTrackColor: Colors.white.withValues(alpha: 0.06),
              trackHeight: 6,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
            ),
            child: Slider(
              value: _hoursPerWeek,
              min: 3,
              max: 25,
              divisions: 22,
              onChanged: (v) => setState(() => _hoursPerWeek = v),
            ),
          ),

          const SizedBox(height: 20),

          // Fitness level
          _sectionTitle('FITNESS LEVEL'),
          const SizedBox(height: 10),
          _levelSelector(),

          const SizedBox(height: 20),

          // Experience
          _sectionTitle('EXPERIENCE'),
          const SizedBox(height: 10),
          _experienceSelector(),

          const SizedBox(height: 24),

          // Generate button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _isGenerating ? null : _generatePlan,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8B5CF6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child:
                  _isGenerating
                      ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                      : const Text(
                        'Generate AI Plan',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanView() {
    final basePlan = _basePlan;
    final weeks =
        basePlan == null
            ? const <Map<String, dynamic>>[]
            : (basePlan['weeks'] as List? ?? const [])
                .whereType<Map>()
                .map((w) => Map<String, dynamic>.from(w))
                .toList();
    final tssProgression =
        basePlan == null
            ? const <int>[]
            : (basePlan['weeklyTSSProgression'] as List? ?? const [])
                .whereType<num>()
                .map((t) => t.toInt())
                .toList();
    final maxTss =
        tssProgression.isEmpty
            ? 1
            : tssProgression.reduce((a, b) => a > b ? a : b);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Success banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF10B981), Color(0xFF14B8A6)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Text('✅', style: TextStyle(fontSize: 24)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Plan Generated Successfully',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '$_selectedGoal · $_selectedSport · $_weeks weeks · ${_hoursPerWeek.toStringAsFixed(1)}h/week',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          const Text(
            'WEEKLY TSS PROGRESSION',
            style: TextStyle(
              color: Colors.white54,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 12),

          // One row per generated week: real TSS progression data.
          for (var i = 0; i < tssProgression.length; i++)
            Container(
              margin: const EdgeInsets.only(bottom: 6),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 56,
                    child: Text(
                      'Week ${i + 1}',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(3),
                      child: LinearProgressIndicator(
                        value: tssProgression[i] / maxTss,
                        minHeight: 6,
                        color: const Color(0xFF8B5CF6),
                        backgroundColor: Colors.white.withValues(alpha: 0.06),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    width: 64,
                    child: Text(
                      '${tssProgression[i]} TSS',
                      textAlign: TextAlign.end,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 24),

          const Text(
            'PLAN OVERVIEW',
            style: TextStyle(
              color: Colors.white54,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 12),

          // Per-week theme/focus from the generated base plan.
          for (final week in weeks)
            _periodCard(
              (week['theme'] as String? ?? ''),
              'Week ${week['weekNumber']} · ${week['targetWeeklyTSS']} TSS',
              (week['focus'] as String? ?? ''),
              week['isRecoveryWeek'] == true
                  ? const Color(0xFF10B981)
                  : const Color(0xFF8B5CF6),
              0.15,
            ),

          const SizedBox(height: 24),

          // Sample structure
          const Text(
            'SAMPLE STRUCTURE (WEEK 1)',
            style: TextStyle(
              color: Colors.white54,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 12),

          _weekDayRow(
            'Monday',
            'Rest Day',
            'Recovery & mobility',
            Icons.bed,
            Colors.white24,
          ),
          _weekDayRow(
            'Tuesday',
            'Interval Session',
            '4x8min Sweet Spot @ 88-92% FTP',
            Icons.speed,
            const Color(0xFFF97316),
          ),
          _weekDayRow(
            'Wednesday',
            'Endurance Ride',
            '2h Z2 Aerobic @ 65-75% FTP',
            Icons.park,
            const Color(0xFF10B981),
          ),
          _weekDayRow(
            'Thursday',
            'Strength Training',
            'Gym session: Squats, Deadlifts, Core',
            Icons.fitness_center,
            const Color(0xFF6366F1),
          ),
          _weekDayRow(
            'Friday',
            'Rest Day',
            'Active recovery: Yoga, stretching',
            Icons.self_improvement,
            Colors.white24,
          ),
          _weekDayRow(
            'Saturday',
            'Long Ride',
            '4h Z2 with 3x10min threshold @ 95-100% FTP',
            Icons.terrain,
            const Color(0xFFF59E0B),
          ),
          _weekDayRow(
            'Sunday',
            'Recovery Ride',
            '1h easy spin Z1 @ <65% FTP',
            Icons.directions_bike,
            const Color(0xFF3B82F6),
          ),

          const SizedBox(height: 24),

          // Key workouts
          const Text(
            'KEY WORKOUTS THIS WEEK',
            style: TextStyle(
              color: Colors.white54,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 12),

          _workoutCard(
            'Sweet Spot Intervals',
            'Tuesday',
            '4 × 8 min @ 88-92% FTP',
            '3 min recovery between intervals',
            const Color(0xFFF97316),
          ),
          _workoutCard(
            'Long Endurance Ride',
            'Saturday',
            '4 hours @ Z2 with tempo blocks',
            'Last 30 min @ 95-100% FTP',
            const Color(0xFFF59E0B),
          ),

          const SizedBox(height: 24),

          // Actions
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => setState(() => _planGenerated = false),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.white24),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text(
                    'Modify',
                    style: TextStyle(color: Colors.white54),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _isStarting ? null : _startTraining,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child:
                      _isStarting
                          ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                          : const Text(
                            'Start Training',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.white54,
        fontSize: 10,
        fontWeight: FontWeight.w700,
        letterSpacing: 1,
      ),
    );
  }

  Widget _goalSelector() {
    final goals = [
      'Gran Fondo',
      'Marathon',
      'Century Ride',
      'Triathlon',
      'Trail Ultra',
      'FTP Increase',
    ];
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children:
          goals.map((goal) {
            final isSelected = goal == _selectedGoal;
            return GestureDetector(
              onTap: () => setState(() => _selectedGoal = goal),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color:
                      isSelected
                          ? const Color(0xFF8B5CF6).withValues(alpha: 0.15)
                          : Colors.white.withValues(alpha: 0.03),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color:
                        isSelected
                            ? const Color(0xFF8B5CF6)
                            : Colors.white.withValues(alpha: 0.06),
                  ),
                ),
                child: Text(
                  goal,
                  style: TextStyle(
                    color:
                        isSelected ? const Color(0xFF8B5CF6) : Colors.white54,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            );
          }).toList(),
    );
  }

  Widget _sportSelector() {
    final sports = ['Cycling', 'Running', 'Triathlon', 'Swimming', 'Rowing'];
    return Row(
      children:
          sports.map((sport) {
            final isSelected = sport == _selectedSport;
            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _selectedSport = sport),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color:
                        isSelected
                            ? const Color(0xFF8B5CF6)
                            : Colors.white.withValues(alpha: 0.03),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    sport,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.white54,
                      fontWeight: FontWeight.w600,
                      fontSize: 11,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
    );
  }

  Widget _levelSelector() {
    final levels = ['Beginner', 'Intermediate', 'Advanced', 'Elite'];
    return Row(
      children:
          levels.map((level) {
            final isSelected = level == _fitnessLevel;
            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _fitnessLevel = level),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color:
                        isSelected
                            ? const Color(0xFF8B5CF6)
                            : Colors.white.withValues(alpha: 0.03),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    level,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.white54,
                      fontWeight: FontWeight.w600,
                      fontSize: 11,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
    );
  }

  Widget _experienceSelector() {
    final options = ['< 1 year', '1-2 years', '2-5 years', '5+ years'];
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children:
          options.map((opt) {
            final isSelected = opt == _experience;
            return GestureDetector(
              onTap: () => setState(() => _experience = opt),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color:
                      isSelected
                          ? const Color(0xFF8B5CF6).withValues(alpha: 0.15)
                          : Colors.white.withValues(alpha: 0.03),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color:
                        isSelected
                            ? const Color(0xFF8B5CF6)
                            : Colors.white.withValues(alpha: 0.06),
                  ),
                ),
                child: Text(
                  opt,
                  style: TextStyle(
                    color:
                        isSelected ? const Color(0xFF8B5CF6) : Colors.white54,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            );
          }).toList(),
    );
  }

  Widget _periodCard(
    String title,
    String weeks,
    String description,
    Color color,
    double opacity,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: opacity),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 40,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      weeks,
                      style: TextStyle(
                        color: color.withValues(alpha: 0.6),
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.5),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _weekDayRow(
    String day,
    String title,
    String subtitle,
    IconData icon,
    Color color,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 10),
          SizedBox(
            width: 70,
            child: Text(
              day,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.5),
                fontSize: 11,
              ),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
                Text(
                  subtitle,
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
  }

  Widget _workoutCard(
    String title,
    String day,
    String description,
    String details,
    Color color,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                title,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  day,
                  style: TextStyle(
                    color: color,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            description,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            details,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.5),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

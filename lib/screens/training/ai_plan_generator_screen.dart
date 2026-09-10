import 'package:flutter/material.dart';

class AiPlanGeneratorScreen extends StatefulWidget {
  const AiPlanGeneratorScreen({super.key});

  @override
  State<AiPlanGeneratorScreen> createState() => _AiPlanGeneratorScreenState();
}

class _AiPlanGeneratorScreenState extends State<AiPlanGeneratorScreen> {
  String _selectedGoal = 'Gran Fondo';
  String _selectedSport = 'Cycling';
  int _weeks = 12;
  double _hoursPerWeek = 10;
  String _fitnessLevel = 'Intermediate';
  String _experience = '2-5 years';

  bool _isGenerating = false;
  bool _planGenerated = false;

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
              onPressed:
                  _isGenerating
                      ? null
                      : () {
                        setState(() => _isGenerating = true);
                        Future.delayed(const Duration(seconds: 3), () {
                          setState(() {
                            _isGenerating = false;
                            _planGenerated = true;
                          });
                        });
                      },
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
            'PLAN OVERVIEW',
            style: TextStyle(
              color: Colors.white54,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 12),

          // Period breakdown
          _periodCard(
            'Base Building',
            'Weeks 1-4',
            'Aerobic foundation, technique drills, 80/20 intensity distribution',
            const Color(0xFF3B82F6),
            0.15,
          ),
          _periodCard(
            'Build Phase',
            'Weeks 5-8',
            'Progressive overload, sweet spot intervals, race-specific preparation',
            const Color(0xFFF97316),
            0.15,
          ),
          _periodCard(
            'Peak Phase',
            'Weeks 9-10',
            'Race simulation, VO2max work, sharpening',
            const Color(0xFFEF4444),
            0.15,
          ),
          _periodCard(
            'Taper',
            'Weeks 11-12',
            'Volume reduction, intensity maintenance, recovery focus',
            const Color(0xFF10B981),
            0.15,
          ),

          const SizedBox(height: 24),

          // Weekly structure
          const Text(
            'SAMPLE WEEK STRUCTURE',
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
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text(
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

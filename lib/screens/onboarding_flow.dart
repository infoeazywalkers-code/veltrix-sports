import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants.dart';
import '../errors/error_handler.dart';
import '../models/user_profile.dart';
import '../models/user_preferences.dart';
import '../providers.dart';
import '../services/onboarding_service.dart';

class OnboardingFlow extends ConsumerStatefulWidget {
  const OnboardingFlow({super.key});

  @override
  ConsumerState<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends ConsumerState<OnboardingFlow> {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  static const int _totalSteps = 6;

  UserRole? _selectedRole;

  String _primarySport = 'Run';
  String _experienceLevel = 'Intermediate';
  double _weeklyHours = 8;

  DateTime? _dateOfBirth;
  double _weightKg = 70;
  double _heightCm = 170;

  String _primaryGoal = 'Improve Endurance';
  String _targetEvent = '';
  List<String> _selectedDays = ['Mon', 'Wed', 'Fri'];

  bool _workoutReminders = true;
  bool _progressUpdates = true;
  bool _coachMessages = true;

  void _nextStep() {
    if (_currentStep < _totalSteps - 1) {
      setState(() => _currentStep++);
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  String _formatDate(DateTime date) {
    const months = [
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
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  ExperienceLevel _mapExperienceLevel(String level) {
    switch (level) {
      case 'Beginner':
        return ExperienceLevel.beginner;
      case 'Intermediate':
        return ExperienceLevel.intermediate;
      case 'Advanced':
        return ExperienceLevel.advanced;
      case 'Elite':
        return ExperienceLevel.elite;
      default:
        return ExperienceLevel.intermediate;
    }
  }

  List<int> _mapDaysToIndices(List<String> days) {
    const dayMap = {
      'Mon': 1,
      'Tue': 2,
      'Wed': 3,
      'Thu': 4,
      'Fri': 5,
      'Sat': 6,
      'Sun': 7,
    };
    return days.map((d) => dayMap[d] ?? 1).toList();
  }

  List<int> _getRestDayIndices() {
    const allDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final restDays = allDays.where((d) => !_selectedDays.contains(d)).toList();
    return _mapDaysToIndices(restDays);
  }

  Future<void> _completeOnboarding() async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    try {
      final availableDays = _mapDaysToIndices(_selectedDays);
      final restDayIndices = _getRestDayIndices();

      final preferences = UserPreferences(
        physical: PhysicalProfile(
          dateOfBirth: _dateOfBirth,
          weightKg: _weightKg,
          heightCm: _heightCm,
        ),
        sport: SportProfile(
          primarySport: _primarySport,
          experienceLevel: _mapExperienceLevel(_experienceLevel),
        ),
        goals: TrainingGoals(weeklyHoursTarget: _weeklyHours.round()),
        schedule: SchedulePreferences(
          availableDays: availableDays,
          restDays: restDayIndices,
        ),
        notifications: NotificationPreferences(
          workoutReminders: _workoutReminders,
          weeklySummary: _progressUpdates,
          coachMessages: _coachMessages,
        ),
      );

      final prefs = ref.read(preferencesServiceProvider);
      await prefs.update(user.uid, preferences.toMap());

      await OnboardingService().saveProgress(
        sports: [_primarySport],
        experienceLevel: _experienceLevel,
        mainGoal: _primaryGoal,
        weeklyHours: _weeklyHours.round(),
        goalRace: _targetEvent.isNotEmpty ? _targetEvent : null,
        complete: true,
      );

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({
            'role': _selectedRole == UserRole.coach ? 'coach' : 'athlete',
            'onboardingStatus': 'completed',
          });

      if (mounted) {
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(ErrorHandler.getUserMessage(e))));
      }
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  bool _canProceed() {
    switch (_currentStep) {
      case 0:
        return _selectedRole != null;
      case 2:
        return _dateOfBirth != null;
      case 3:
        return _selectedDays.isNotEmpty;
      default:
        return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: navy,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: List.generate(
                  _totalSteps,
                  (i) => Expanded(
                    child: Container(
                      height: 4,
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      decoration: BoxDecoration(
                        color: i <= _currentStep ? blue : Colors.white24,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Step ${_currentStep + 1} of $_totalSteps',
                style: const TextStyle(color: Colors.white54, fontSize: 12),
              ),
            ),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildRoleStep(),
                  _buildSportStep(),
                  _buildPhysicalStep(),
                  _buildGoalsStep(),
                  _buildNotificationsStep(),
                  _buildSummaryStep(),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  if (_currentStep > 0)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _prevStep,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Colors.white24),
                        ),
                        child: const Text('Back'),
                      ),
                    ),
                  if (_currentStep > 0) const SizedBox(width: 16),
                  Expanded(
                    child: FilledButton(
                      onPressed:
                          _currentStep == _totalSteps - 1
                              ? _completeOnboarding
                              : _canProceed()
                              ? _nextStep
                              : null,
                      style: FilledButton.styleFrom(backgroundColor: blue),
                      child: Text(
                        _currentStep == _totalSteps - 1
                            ? 'Get Started'
                            : 'Next',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepTitle(String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: const TextStyle(color: Colors.white54, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepTitle(
            'Welcome to Veltrix',
            'Tell us how you\'ll use the app',
          ),
          const SizedBox(height: 24),
          _buildRoleCard(
            role: UserRole.athlete,
            icon: Icons.directions_run,
            title: 'I\'m an Athlete',
            subtitle: 'Track workouts, follow plans, and improve performance',
          ),
          const SizedBox(height: 16),
          _buildRoleCard(
            role: UserRole.coach,
            icon: Icons.groups,
            title: 'I\'m a Coach',
            subtitle: 'Manage athletes, create plans, and track progress',
          ),
        ],
      ),
    );
  }

  Widget _buildRoleCard({
    required UserRole role,
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    final isSelected = _selectedRole == role;
    return GestureDetector(
      onTap: () => setState(() => _selectedRole = role),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? blue.withValues(alpha: 0.15)
                  : Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? blue : Colors.white24,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, size: 40, color: isSelected ? blue : Colors.white54),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(color: Colors.white54, fontSize: 13),
                  ),
                ],
              ),
            ),
            if (isSelected) const Icon(Icons.check_circle, color: blue),
          ],
        ),
      ),
    );
  }

  Widget _buildSportStep() {
    final sports = ['Run', 'Cycle', 'Swim', 'Triathlon', 'Strength', 'Other'];
    final levels = ['Beginner', 'Intermediate', 'Advanced', 'Elite'];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepTitle('Sport Profile', 'What do you train for?'),
          const SizedBox(height: 16),
          const Text('Primary Sport', style: TextStyle(color: Colors.white70)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children:
                sports
                    .map(
                      (sport) => ChoiceChip(
                        label: Text(sport),
                        selected: _primarySport == sport,
                        onSelected:
                            (_) => setState(() => _primarySport = sport),
                        selectedColor: blue,
                        backgroundColor: Colors.white10,
                        labelStyle: TextStyle(
                          color:
                              _primarySport == sport
                                  ? Colors.white
                                  : Colors.white70,
                        ),
                      ),
                    )
                    .toList(),
          ),
          const SizedBox(height: 24),
          const Text(
            'Experience Level',
            style: TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children:
                levels
                    .map(
                      (level) => ChoiceChip(
                        label: Text(level),
                        selected: _experienceLevel == level,
                        onSelected:
                            (_) => setState(() => _experienceLevel = level),
                        selectedColor: blue,
                        backgroundColor: Colors.white10,
                        labelStyle: TextStyle(
                          color:
                              _experienceLevel == level
                                  ? Colors.white
                                  : Colors.white70,
                        ),
                      ),
                    )
                    .toList(),
          ),
          const SizedBox(height: 24),
          Text(
            'Weekly Training Hours: ${_weeklyHours.round()}h',
            style: const TextStyle(color: Colors.white70),
          ),
          Slider(
            value: _weeklyHours,
            min: 3,
            max: 20,
            divisions: 17,
            activeColor: blue,
            onChanged: (v) => setState(() => _weeklyHours = v),
          ),
        ],
      ),
    );
  }

  Widget _buildPhysicalStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepTitle(
            'Physical Profile',
            'Help us personalize your experience',
          ),
          const SizedBox(height: 16),
          const Text('Date of Birth', style: TextStyle(color: Colors.white70)),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: _dateOfBirth ?? DateTime(1995),
                firstDate: DateTime(1940),
                lastDate: DateTime.now().subtract(
                  const Duration(days: 365 * 13),
                ),
              );
              if (date != null) setState(() => _dateOfBirth = date);
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white10,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today, color: Colors.white54),
                  const SizedBox(width: 12),
                  Text(
                    _dateOfBirth != null
                        ? _formatDate(_dateOfBirth!)
                        : 'Select date',
                    style: TextStyle(
                      color:
                          _dateOfBirth != null ? Colors.white : Colors.white54,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'This helps calculate your heart rate zones',
            style: TextStyle(color: Colors.white38, fontSize: 12),
          ),
          const SizedBox(height: 24),
          Text(
            'Weight: ${_weightKg.round()} kg',
            style: const TextStyle(color: Colors.white70),
          ),
          Slider(
            value: _weightKg,
            min: 30,
            max: 150,
            divisions: 120,
            activeColor: blue,
            onChanged: (v) => setState(() => _weightKg = v),
          ),
          const SizedBox(height: 16),
          Text(
            'Height: ${_heightCm.round()} cm',
            style: const TextStyle(color: Colors.white70),
          ),
          Slider(
            value: _heightCm,
            min: 120,
            max: 220,
            divisions: 100,
            activeColor: blue,
            onChanged: (v) => setState(() => _heightCm = v),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalsStep() {
    const goals = [
      'Improve Endurance',
      'Lose Weight',
      'Build Strength',
      'Race Preparation',
      'General Fitness',
    ];
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepTitle('Training Goals', 'What are you working towards?'),
          const SizedBox(height: 16),
          const Text('Primary Goal', style: TextStyle(color: Colors.white70)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children:
                goals
                    .map(
                      (goal) => ChoiceChip(
                        label: Text(goal),
                        selected: _primaryGoal == goal,
                        onSelected: (_) => setState(() => _primaryGoal = goal),
                        selectedColor: blue,
                        backgroundColor: Colors.white10,
                        labelStyle: TextStyle(
                          color:
                              _primaryGoal == goal
                                  ? Colors.white
                                  : Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    )
                    .toList(),
          ),
          const SizedBox(height: 24),
          const Text(
            'Target Event (optional)',
            style: TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 8),
          TextField(
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'e.g., Mumbai Marathon 2026',
              hintStyle: const TextStyle(color: Colors.white30),
              filled: true,
              fillColor: Colors.white10,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
            onChanged: (v) => setState(() => _targetEvent = v),
          ),
          const SizedBox(height: 24),
          const Text('Training Days', style: TextStyle(color: Colors.white70)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children:
                days
                    .map(
                      (day) => GestureDetector(
                        onTap: () {
                          setState(() {
                            if (_selectedDays.contains(day)) {
                              _selectedDays.remove(day);
                            } else {
                              _selectedDays = [..._selectedDays, day];
                            }
                          });
                        },
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color:
                                _selectedDays.contains(day)
                                    ? blue
                                    : Colors.white10,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            day.substring(0, 2),
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight:
                                  _selectedDays.contains(day)
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                            ),
                          ),
                        ),
                      ),
                    )
                    .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationsStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepTitle('Notifications', 'Stay on top of your training'),
          const SizedBox(height: 8),
          const Text(
            'You can change these anytime in Settings',
            style: TextStyle(color: Colors.white38, fontSize: 13),
          ),
          const SizedBox(height: 24),
          _buildNotificationToggle(
            title: 'Workout Reminders',
            subtitle: 'Daily reminders for scheduled workouts',
            value: _workoutReminders,
            onChanged: (v) => setState(() => _workoutReminders = v),
          ),
          _buildNotificationToggle(
            title: 'Progress Updates',
            subtitle: 'Weekly summaries and milestone alerts',
            value: _progressUpdates,
            onChanged: (v) => setState(() => _progressUpdates = v),
          ),
          _buildNotificationToggle(
            title: 'Coach Messages',
            subtitle: 'Notifications when your coach messages you',
            value: _coachMessages,
            onChanged: (v) => setState(() => _coachMessages = v),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationToggle({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(color: Colors.white54, fontSize: 13),
                ),
              ],
            ),
          ),
          Switch(value: value, onChanged: onChanged, activeColor: blue),
        ],
      ),
    );
  }

  Widget _buildSummaryStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepTitle('You\'re All Set!', 'Here\'s your profile summary'),
          const SizedBox(height: 24),
          _buildSummaryRow(
            'Role',
            _selectedRole == UserRole.coach ? 'Coach' : 'Athlete',
          ),
          _buildSummaryRow('Sport', _primarySport),
          _buildSummaryRow('Experience', _experienceLevel),
          _buildSummaryRow('Weekly Hours', '${_weeklyHours.round()}h'),
          if (_dateOfBirth != null)
            _buildSummaryRow('Date of Birth', _formatDate(_dateOfBirth!)),
          _buildSummaryRow('Weight', '${_weightKg.round()} kg'),
          _buildSummaryRow('Height', '${_heightCm.round()} cm'),
          _buildSummaryRow('Goal', _primaryGoal),
          if (_targetEvent.isNotEmpty)
            _buildSummaryRow('Target Event', _targetEvent),
          _buildSummaryRow('Training Days', _selectedDays.join(', ')),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white54)),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

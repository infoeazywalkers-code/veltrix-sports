import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants.dart';
import '../../core/errors/error_handler.dart';
import '../../models/user/user_profile.dart';
import '../../models/user/user_preferences.dart';
import '../../providers.dart';
import '../../services/user_service.dart';
import '../../services/core/preferences_service.dart';

class ProfileEditScreen extends ConsumerStatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  ConsumerState<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends ConsumerState<ProfileEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _targetEventController;
  bool _saving = false;

  String _selectedPrimarySport = '';
  ExperienceLevel _selectedExperienceLevel = ExperienceLevel.beginner;
  double _weeklyHours = 5;
  DateTime? _dateOfBirth;
  double _weightKg = 70;
  double _heightCm = 170;
  String _selectedGoal = '';
  String _originalEmail = '';

  final List<String> _sports = [
    'Running',
    'Cycling',
    'Swimming',
    'Triathlon',
    'Strength',
    'Other',
  ];

  final List<String> _goals = [
    'Lose weight',
    'Build muscle',
    'Improve endurance',
    'Race preparation',
    'General fitness',
    'Recovery',
  ];

  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _targetEventController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _targetEventController.dispose();
    super.dispose();
  }

  void _initFromData(UserProfile? profile, UserPreferences? prefs) {
    if (_initialized) return;
    _initialized = true;

    // Fall back to the Firebase Auth identity so the form never shows
    // dummy defaults when the Firestore doc is missing.
    final authUser = FirebaseAuth.instance.currentUser;
    _nameController.text = profile?.displayName.isNotEmpty == true
        ? profile!.displayName
        : (authUser?.displayName ?? '');
    _originalEmail = profile?.email ?? authUser?.email ?? '';
    _selectedPrimarySport = (profile != null && profile.sports.isNotEmpty)
        ? profile.sports.first
        : 'Running';
    _selectedExperienceLevel =
        prefs?.sport.experienceLevel ?? ExperienceLevel.beginner;
    _weeklyHours = (prefs?.goals.weeklyHoursTarget ?? 5).toDouble();
    _dateOfBirth = prefs?.physical.dateOfBirth;
    _weightKg = prefs?.physical.weightKg ?? 70;
    _heightCm = prefs?.physical.heightCm ?? 170;
    _selectedGoal = prefs?.goals.performanceGoals.isNotEmpty == true
        ? prefs!.goals.performanceGoals.first
        : 'General fitness';
    _targetEventController.text = prefs?.goals.targetEvents.isNotEmpty == true
        ? prefs!.goals.targetEvents.first.name
        : '';
  }

  Future<void> _pickDateOfBirth() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _dateOfBirth ?? DateTime(1995, 1, 1),
      firstDate: DateTime(1930),
      lastDate: now,
      builder: (dialogContext, child) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Theme(
          data: Theme.of(dialogContext).copyWith(
            colorScheme: isDark
                ? const ColorScheme.dark(primary: lime)
                : const ColorScheme.light(primary: navy),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _dateOfBirth = picked);
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day} ${monthName(date.month)} ${date.year}';
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please sign in to update your profile.')),
      );
      return;
    }

    setState(() => _saving = true);

    try {
      final profileAsync = ref.read(userProfileProvider);
      final currentProfile = profileAsync.valueOrNull;

      final updatedProfile = UserProfile(
        id: user.uid,
        email: user.email ?? currentProfile?.email ?? _originalEmail,
        displayName: _nameController.text.trim(),
        photoUrl: user.photoURL ?? currentProfile?.photoUrl,
        sports: [_selectedPrimarySport],
        role: currentProfile?.role ?? UserRole.athlete,
        experienceLevel: _selectedExperienceLevel.name,
        mainGoal: _selectedGoal,
        onboardingStatus: currentProfile?.onboardingStatus,
        isPremium: currentProfile?.isPremium ?? false,
        subscriptionTier: currentProfile?.subscriptionTier,
        subscriptionRenewsAt: currentProfile?.subscriptionRenewsAt,
        deviceIds: currentProfile?.deviceIds ?? [],
        createdAt: currentProfile?.createdAt ?? DateTime.now(),
      );

      await UserService().upsert(updatedProfile);

      final targetEventName = _targetEventController.text.trim();
      final targetEvents = targetEventName.isNotEmpty
          ? [
              TargetEvent(
                name: targetEventName,
                date: DateTime.now().add(const Duration(days: 90)),
              ),
            ]
          : <TargetEvent>[];

      final updatedPrefs = {
        'physical': PhysicalProfile(
          dateOfBirth: _dateOfBirth,
          weightKg: _weightKg,
          heightCm: _heightCm,
        ).toMap(),
        'sport': SportProfile(
          primarySport: _selectedPrimarySport,
          experienceLevel: _selectedExperienceLevel,
        ).toMap(),
        'goals': TrainingGoals(
          targetEvents: targetEvents,
          performanceGoals: [_selectedGoal],
          weeklyHoursTarget: _weeklyHours.round(),
        ).toMap(),
      };

      await PreferencesService().update(user.uid, updatedPrefs);

      ref.invalidate(userProfileProvider);
      ref.invalidate(userPreferencesProvider);

      if (mounted) {
        final messenger = ScaffoldMessenger.of(context);
        Navigator.pop(context);
        messenger.showSnackBar(
          const SnackBar(content: Text('Profile updated successfully.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(ErrorHandler.getUserMessage(e))));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(userProfileProvider);
    final profile = profileAsync.valueOrNull;
    final prefsAsync = ref.watch(userPreferencesProvider);
    final prefs = prefsAsync.valueOrNull;

    _initFromData(profile, prefs);

    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? darkNavy
          : bg,
      appBar: AppBar(
        backgroundColor: navy,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Edit Profile',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(18),
          children: [
            _buildSectionHeader('Basic Info'),
            const SizedBox(height: 12),
            _buildCard([
              TextFormField(
                controller: _nameController,
                decoration: _inputDecoration(
                  context,
                  'Display Name',
                  Icons.person_outline,
                ),
                style: const TextStyle(fontWeight: FontWeight.w600),
                validator: (val) => val == null || val.trim().isEmpty
                    ? 'Enter your name'
                    : null,
              ),
              const SizedBox(height: 14),
              TextFormField(
                initialValue: _originalEmail,
                readOnly: true,
                decoration:
                    _inputDecoration(
                      context,
                      'Email',
                      Icons.email_outlined,
                    ).copyWith(
                      fillColor: Theme.of(context).brightness == Brightness.dark
                          ? const Color(0xFF0F2030)
                          : const Color(0xffeef1f5),
                      filled: true,
                    ),
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? const Color(0xFF78909C)
                      : muted,
                ),
              ),
            ]),
            const SizedBox(height: 28),
            _buildSectionHeader('Sport Profile'),
            const SizedBox(height: 12),
            _buildCard([
              _buildDropdown<String>(
                value: _selectedPrimarySport,
                label: 'Primary Sport',
                icon: Icons.sports_outlined,
                items: _sports,
                onChanged: (val) {
                  if (val != null) setState(() => _selectedPrimarySport = val);
                },
              ),
              const SizedBox(height: 14),
              _buildDropdown<ExperienceLevel>(
                value: _selectedExperienceLevel,
                label: 'Experience Level',
                icon: Icons.trending_up_outlined,
                items: ExperienceLevel.values.map((e) => e.name).toList(),
                displayNames: const [
                  'Beginner',
                  'Intermediate',
                  'Advanced',
                  'Elite',
                ],
                onChanged: (val) {
                  if (val != null)
                    setState(() => _selectedExperienceLevel = val);
                },
              ),
              const SizedBox(height: 14),
              _buildSliderSection(
                label: 'Weekly Training Hours',
                value: _weeklyHours,
                min: 1,
                max: 30,
                divisions: 29,
                suffix: '${_weeklyHours.round()} hrs',
                onChanged: (val) => setState(() => _weeklyHours = val),
              ),
            ]),
            const SizedBox(height: 28),
            _buildSectionHeader('Physical Profile'),
            const SizedBox(height: 12),
            _buildCard([
              GestureDetector(
                onTap: _pickDateOfBirth,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? const Color(0xFF1A3040)
                          : const Color(0xffd5dbe3),
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.cake_outlined,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white
                            : navy,
                        size: 22,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Date of Birth',
                              style: TextStyle(
                                color:
                                    Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? const Color(0xFF78909C)
                                    : muted,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _dateOfBirth != null
                                  ? _formatDate(_dateOfBirth!)
                                  : 'Tap to select',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: _dateOfBirth != null
                                    ? (Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? Colors.white
                                          : navy)
                                    : (Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? const Color(0xFF78909C)
                                          : muted),
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.chevron_right,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? const Color(0xFF78909C)
                            : muted,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),
              _buildSliderSection(
                label: 'Weight',
                value: _weightKg,
                min: 30,
                max: 200,
                divisions: 170,
                suffix: '${_weightKg.round()} kg',
                onChanged: (val) => setState(() => _weightKg = val),
              ),
              const SizedBox(height: 14),
              _buildSliderSection(
                label: 'Height',
                value: _heightCm,
                min: 100,
                max: 220,
                divisions: 120,
                suffix: '${_heightCm.round()} cm',
                onChanged: (val) => setState(() => _heightCm = val),
              ),
            ]),
            const SizedBox(height: 28),
            _buildSectionHeader('Training Goals'),
            const SizedBox(height: 12),
            _buildCard([
              _buildDropdown<String>(
                value: _selectedGoal,
                label: 'Primary Goal',
                icon: Icons.flag_outlined,
                items: _goals,
                onChanged: (val) {
                  if (val != null) setState(() => _selectedGoal = val);
                },
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _targetEventController,
                decoration: _inputDecoration(
                  context,
                  'Target Event (optional)',
                  Icons.event_outlined,
                ),
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ]),
            const SizedBox(height: 36),
            SizedBox(
              height: 54,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: lime,
                  foregroundColor: navy,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: _saving ? null : _save,
                child: _saving
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: navy,
                        ),
                      )
                    : const Text(
                        'Save Changes',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: TextStyle(
        color: (Theme.of(context).brightness == Brightness.dark
            ? Colors.white
            : navy),
        fontSize: 17,
        fontWeight: FontWeight.w900,
      ),
    );
  }

  Widget _buildCard(List<Widget> children) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F2030) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: navy.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  InputDecoration _inputDecoration(
    BuildContext context,
    String label,
    IconData icon,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: isDark ? const Color(0xFF78909C) : muted),
      prefixIcon: Icon(icon, color: isDark ? Colors.white : navy, size: 22),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: isDark ? const Color(0xFF1A3040) : const Color(0xffd5dbe3),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: isDark ? const Color(0xFF1A3040) : const Color(0xffd5dbe3),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: isDark ? lime : navy, width: 2),
      ),
      filled: true,
      fillColor: isDark ? const Color(0xFF0F2030) : Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
    );
  }

  Widget _buildDropdown<T>({
    required T value,
    required String label,
    required IconData icon,
    required List<String> items,
    required ValueChanged<T?> onChanged,
    List<String>? displayNames,
  }) {
    return DropdownButtonFormField<T>(
      initialValue: value,
      decoration: _inputDecoration(context, label, icon),
      style: TextStyle(
        fontWeight: FontWeight.w600,
        color: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFFE0E6ED)
            : ink,
        fontSize: 15,
      ),
      borderRadius: BorderRadius.circular(12),
      items: List.generate(items.length, (i) {
        final itemValue = items[i];
        final displayName = displayNames != null ? displayNames[i] : itemValue;
        return DropdownMenuItem<T>(
          value: T == ExperienceLevel
              ? ExperienceLevel.values[i] as T
              : itemValue as T,
          child: Text(displayName),
        );
      }),
      onChanged: onChanged,
    );
  }

  Widget _buildSliderSection({
    required String label,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required String suffix,
    required ValueChanged<double> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                color: Theme.of(context).brightness == Brightness.dark
                    ? const Color(0xFF78909C)
                    : muted,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: navy.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                suffix,
                style: TextStyle(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white
                      : navy,
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: navy,
            inactiveTrackColor: const Color(0xffd5dbe3),
            thumbColor: navy,
            overlayColor: navy.withValues(alpha: 0.1),
            trackHeight: 4,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
          ),
          child: Slider(
            value: value,
            min: min,
            max: max,
            divisions: divisions,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}

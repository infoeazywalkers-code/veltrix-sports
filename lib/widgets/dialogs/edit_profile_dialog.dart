import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/constants.dart';
import '../../models/user/user_profile.dart';
import '../../services/user_service.dart';

class EditProfileDialog extends StatefulWidget {
  final UserProfile? currentProfile;
  const EditProfileDialog({super.key, this.currentProfile});

  @override
  State<EditProfileDialog> createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends State<EditProfileDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late List<String> _selectedSports;
  bool _saving = false;

  final List<String> _availableSports = [
    'Running',
    'Cycling',
    'Swimming',
    'Strength',
    'Triathlon',
    'Trail Running',
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text:
          widget.currentProfile?.displayName ??
          FirebaseAuth.instance.currentUser?.displayName ??
          '',
    );
    _selectedSports = List<String>.from(
      widget.currentProfile?.sports ?? ['Running', 'Cycling'],
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedSports.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one primary sport.'),
        ),
      );
      return;
    }
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please sign in to update your profile.')),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      final updatedProfile = UserProfile(
        id: user.uid,
        email: user.email ?? widget.currentProfile?.email ?? '',
        displayName: _nameController.text.trim(),
        photoUrl: user.photoURL ?? widget.currentProfile?.photoUrl,
        sports: _selectedSports,
        role: widget.currentProfile?.role ?? UserRole.athlete,
        isPremium: widget.currentProfile?.isPremium ?? false,
        subscriptionTier: widget.currentProfile?.subscriptionTier,
        subscriptionRenewsAt: widget.currentProfile?.subscriptionRenewsAt,
        createdAt: widget.currentProfile?.createdAt ?? DateTime.now(),
      );

      await UserService().upsert(updatedProfile);

      if (mounted) {
        final messenger = ScaffoldMessenger.of(context);
        Navigator.pop(context, true);
        messenger.showSnackBar(
          const SnackBar(content: Text('Profile updated successfully.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to update profile: $e')));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(
            Icons.edit,
            color:
                (Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : navy),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Edit Profile',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                color:
                    (Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : navy),
              ),
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Display Name',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                validator:
                    (val) =>
                        val == null || val.trim().isEmpty
                            ? 'Enter your name'
                            : null,
              ),
              const SizedBox(height: 18),
              Text(
                'Primary Sports',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color:
                      (Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : navy),
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children:
                    _availableSports.map((sport) {
                      final isSelected = _selectedSports.contains(sport);
                      return FilterChip(
                        label: Text(sport),
                        selected: isSelected,
                        selectedColor: lime,
                        checkmarkColor: navy,
                        labelStyle: TextStyle(
                          color:
                              isSelected
                                  ? (Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? Colors.white
                                      : navy)
                                  : (Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? const Color(0xFFB0BEC5)
                                      : ink),
                          fontWeight:
                              isSelected ? FontWeight.w900 : FontWeight.w600,
                        ),
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _selectedSports.add(sport);
                            } else {
                              _selectedSports.remove(sport);
                            }
                          });
                        },
                      );
                    }).toList(),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: lime,
            foregroundColor: navy,
          ),
          onPressed: _saving ? null : _save,
          child:
              _saving
                  ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                  : const Text(
                    'Save Changes',
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
        ),
      ],
    );
  }
}

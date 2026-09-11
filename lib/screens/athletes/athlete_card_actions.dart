import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/errors/error_handler.dart';
import '../../providers.dart';
import 'athlete_profile_screen.dart';

/// Publishes the caller's own athlete card ([ensureMyDirectory]) and then
/// pushes their [AthleteProfileScreen]. Used by the desktop and mobile
/// profile "Athlete card" rows — the single seed path for directory docs.
Future<void> publishAndOpenAthleteCard(
  BuildContext context,
  WidgetRef ref,
) async {
  final uid = ref.read(currentUserProvider)?.uid;
  if (uid == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Sign in to publish your athlete card.')),
    );
    return;
  }
  try {
    await ref.read(athleteDirectoryServiceProvider).ensureMyDirectory(uid);
    if (context.mounted) {
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => AthleteProfileScreen(uid: uid)),
      );
    }
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(ErrorHandler.getUserMessage(e))));
    }
  }
}

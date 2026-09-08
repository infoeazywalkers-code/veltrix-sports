import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_profile.dart';
import '../providers.dart';

class RoleGate extends ConsumerWidget {
  final UserRole requiredRole;
  final Widget child;
  final Widget? fallback;

  const RoleGate({
    super.key,
    required this.requiredRole,
    required this.child,
    this.fallback,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(userProfileProvider);
    return profileAsync.when(
      data: (profile) {
        if (profile == null) return fallback ?? const SizedBox.shrink();
        if (profile.role == requiredRole) return child;
        return fallback ?? const SizedBox.shrink();
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => fallback ?? const SizedBox.shrink(),
    );
  }
}

class AthleteOnly extends RoleGate {
  const AthleteOnly({super.key, required super.child, super.fallback})
    : super(requiredRole: UserRole.athlete);
}

class CoachOnly extends RoleGate {
  const CoachOnly({super.key, required super.child, super.fallback})
    : super(requiredRole: UserRole.coach);
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers.dart';
import '../constants.dart';
import '../auth_service.dart';

class AuthWrapper extends ConsumerWidget {
  final Widget child;
  const AuthWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return authState.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator(color: navy)),
      ),
      error: (e, _) => Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline_rounded, color: Colors.redAccent, size: 48),
                const SizedBox(height: 12),
                Text(
                  AuthService.getHumanReadableAuthError(e),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.w700, color: navy),
                ),
              ],
            ),
          ),
        ),
      ),
      data: (user) {
        if (user == null) return const SignInPrompt();
        return child;
      },
    );
  }
}

class SignInPrompt extends StatelessWidget {
  const SignInPrompt({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.sports_handball, size: 64, color: navy),
              const SizedBox(height: 24),
              const Text(
                'Welcome to Veltrix',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: navy),
              ),
              const SizedBox(height: 8),
              const Text(
                'Sign in to access your training',
                style: TextStyle(color: muted),
              ),
              const SizedBox(height: 32),
              FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: navy,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                ),
                onPressed: () async {
                  final authService = AuthService();
                  await authService.signInWithGoogle();
                },
                icon: const Icon(Icons.g_mobiledata, size: 24),
                label: const Text('Sign in with Google', style: TextStyle(fontWeight: FontWeight.w900)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

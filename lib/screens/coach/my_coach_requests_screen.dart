import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../core/constants.dart';
import '../../services/social/coach_request_service.dart';
import '../../models/user/coach_request.dart';

/// Read-only list of the current user's coach match requests.
class MyCoachRequestsScreen extends StatefulWidget {
  const MyCoachRequestsScreen({super.key});

  @override
  State<MyCoachRequestsScreen> createState() => _MyCoachRequestsScreenState();
}

class _MyCoachRequestsScreenState extends State<MyCoachRequestsScreen> {
  final CoachRequestService _service = CoachRequestService();
  Future<List<CoachRequest>>? _future;

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _future = _service.getByUserId(user.uid);
    }
  }

  void _retry() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    setState(() => _future = _service.getByUserId(user.uid));
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('My requests')),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.lock_outline, size: 48, color: muted),
              const SizedBox(height: 12),
              const Text(
                'Sign in to view your coach requests.',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Back'),
              ),
            ],
          ),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(title: const Text('My requests')),
      body: FutureBuilder<List<CoachRequest>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: orange),
                  const SizedBox(height: 12),
                  const Text('Could not load your requests.'),
                  const SizedBox(height: 12),
                  FilledButton(onPressed: _retry, child: const Text('Retry')),
                ],
              ),
            );
          }
          final requests = snapshot.data ?? [];
          if (requests.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'No coach requests yet. Tell us what you need and we will match you.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: requests.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final request = requests[index];
              return Card(
                child: ListTile(
                  leading: const Icon(Icons.groups_outlined, color: navy),
                  title: Text(
                    '${request.sport} • ${request.goal}',
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  subtitle: Text(
                    request.notes.isEmpty
                        ? request.experience
                        : '${request.experience}\n${request.notes}',
                  ),
                  trailing: _StatusChip(status: request.status),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String status;
  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final Color color =
        status == 'matched'
            ? Colors.green
            : status == 'pending'
            ? orange
            : muted;
    return Chip(
      label: Text(
        status,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: Colors.white,
        ),
      ),
      backgroundColor: color,
      padding: EdgeInsets.zero,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}

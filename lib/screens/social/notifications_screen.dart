import 'package:flutter/material.dart';
import '../../core/constants.dart';
import '../../services/core/notification_repository.dart';
import '../../models/social/notification_record.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final desktop = MediaQuery.sizeOf(context).width >= 850;
    final repo = NotificationRepository();
    return StreamBuilder<List<NotificationRecord>>(
      stream: repo.watch(),
      builder: (context, snapshot) {
        final notifications = snapshot.data ?? const <NotificationRecord>[];
        final hasUnread = notifications.any((n) => !n.read);
        return RefreshIndicator(
          onRefresh: () async {},
          child: ListView(
            padding: EdgeInsets.fromLTRB(
              desktop ? 40 : 18,
              desktop ? 38 : 22,
              desktop ? 40 : 18,
              64,
            ),
            children: [
              _Header(
                hasUnread: hasUnread,
                onMarkAllRead: () async {
                  for (final n in notifications) {
                    if (!n.read) await repo.markRead(n.id);
                  }
                },
              ),
              const SizedBox(height: 24),
              if (snapshot.hasError)
                const _EmptyState(
                  message: 'Sign in to view your notifications.',
                )
              else if (notifications.isEmpty)
                const _EmptyState(
                  message: 'Your training and coach updates will appear here.',
                ),
              ...notifications.map(
                (notification) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: GestureDetector(
                    onTap: notification.read
                        ? null
                        : () => repo.markRead(notification.id),
                    child: _NotificationCard(
                      icon: notification.type == 'coach'
                          ? Icons.chat_bubble_outline
                          : Icons.notifications_outlined,
                      color: notification.type == 'coach' ? purple : blue,
                      title: notification.title,
                      body: notification.body,
                      meta: _formatDate(notification.createdAt),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatDate(DateTime date) => '${date.day}/${date.month}/${date.year}';
}

class _EmptyState extends StatelessWidget {
  final String message;
  const _EmptyState({required this.message});

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Center(child: Text(message, textAlign: TextAlign.center)),
    ),
  );
}

class _Header extends StatelessWidget {
  final bool hasUnread;
  final VoidCallback onMarkAllRead;
  const _Header({required this.hasUnread, required this.onMarkAllRead});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      color: navy,
      borderRadius: BorderRadius.circular(22),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.notifications_active_outlined,
              color: lime,
              size: 34,
            ),
            const Spacer(),
            if (hasUnread)
              TextButton(
                onPressed: onMarkAllRead,
                style: TextButton.styleFrom(
                  backgroundColor: lime.withValues(alpha: .15),
                  foregroundColor: lime,
                ),
                child: const Text(
                  'Mark all read',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
          ],
        ),
        const SizedBox(height: 18),
        const Text(
          'Notifications',
          style: TextStyle(
            color: Colors.white,
            fontSize: 32,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Training reminders, coach updates, device sync, and race alerts.',
          style: TextStyle(color: Colors.white70, height: 1.45),
        ),
      ],
    ),
  );
}

class _NotificationCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String body;
  final String meta;

  const _NotificationCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.body,
    required this.meta,
  });

  @override
  Widget build(BuildContext context) => Card(
    child: ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: color.withValues(alpha: .12),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(icon, color: color),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w900,
          color: (Theme.of(context).brightness == Brightness.dark
              ? Colors.white
              : navy),
        ),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Text(body),
      ),
      trailing: Text(
        meta,
        style: TextStyle(
          color: (Theme.of(context).brightness == Brightness.dark
              ? const Color(0xFF78909C)
              : muted),
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    ),
  );
}

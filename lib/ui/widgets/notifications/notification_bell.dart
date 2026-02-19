import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../providers/book_providers.dart';

/// Notification bell icon button with unread count badge
class NotificationBell extends ConsumerWidget {
  const NotificationBell({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncCount = ref.watch(unreadNotificationCountProvider);

    return asyncCount.when(
      data: (count) {
        final displayCount = count > 999 ? 999 : count;
        final icon = Icon(
          count > 0
              ? Icons.notifications_active_outlined
              : Icons.notifications_none_outlined,
        );

        return Tooltip(
          message:
              count > 0 ? 'Tienes $count notificaciones' : 'Notificaciones',
          child: IconButton(
            onPressed: onPressed,
            icon: count > 0
                ? Badge.count(
                    count: displayCount,
                    child: icon,
                  )
                : icon,
          ),
        );
      },
      loading: () => const SizedBox(
        width: 36,
        height: 36,
        child: Padding(
          padding: EdgeInsets.all(8),
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
      error: (_, __) => IconButton(
        onPressed: onPressed,
        icon: const Icon(Icons.notifications_off_outlined),
        tooltip: 'Notificaciones',
      ),
    );
  }
}

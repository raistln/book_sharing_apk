import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../data/local/database.dart';
import '../../../../data/models/in_app_notification_status.dart';
import '../../../../providers/book_providers.dart';
import 'notification_visuals.dart';

/// In-app notification banner widget
class InAppNotificationBanner extends ConsumerWidget {
  const InAppNotificationBanner({super.key, required this.notification});

  final InAppNotification notification;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repository = ref.read(notificationRepositoryProvider);
    final visuals = NotificationVisuals.fromNotification(context, notification);
    final isUnread = notification.status == InAppNotificationStatus.unread;

    Future<void> markRead() async {
      await repository.markAs(
        uuid: notification.uuid,
        status: InAppNotificationStatus.read,
      );
    }

    Future<void> dismiss() async {
      await repository.softDelete(uuid: notification.uuid);
    }

    return Material(
      color: visuals.background,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(visuals.icon, color: visuals.iconColor),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        notification.title ?? visuals.defaultTitle,
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(color: visuals.textColor),
                      ),
                      if ((notification.message ?? '').isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text(
                          notification.message!,
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(color: visuals.secondaryTextColor),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: [
                if (isUnread)
                  TextButton.icon(
                    onPressed: markRead,
                    icon: const Icon(Icons.mark_email_read_outlined),
                    label: const Text('Marcar como leído'),
                    style: TextButton.styleFrom(
                        foregroundColor: visuals.textColor),
                  ),
                TextButton.icon(
                  onPressed: dismiss,
                  icon: const Icon(Icons.close),
                  label: const Text('Descartar'),
                  style:
                      TextButton.styleFrom(foregroundColor: visuals.textColor),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../providers/book_providers.dart';
import '../empty_state.dart';
import 'notification_list_tile.dart';
import '../../../../l10n/generated/app_localizations.dart';

/// Bottom sheet displaying in-app notifications
class NotificationsSheet extends ConsumerWidget {
  const NotificationsSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(inAppNotificationsProvider);
    final activeUser = ref.read(activeUserProvider).value;
    final repository = ref.read(notificationRepositoryProvider);
    final theme = Theme.of(context);
    final hasNotifications = notificationsAsync.maybeWhen(
      data: (notifications) => notifications.isNotEmpty,
      orElse: () => false,
    );

    void showSnack(String message) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }

    Future<void> clearAll() async {
      if (!hasNotifications) {
        showSnack(S.of(context).noNotificationsToClear);
        return;
      }
      if (activeUser == null) {
        showSnack(S.of(context).errorNoUserToClearNotifications);
        return;
      }
      try {
        await repository.clearAllForUser(activeUser.id);
        if (!context.mounted) return;
        showSnack(S.of(context).successNotificationsCleared);
      } catch (error) {
        if (!context.mounted) return;
        showSnack(S.of(context).errorClearingNotifications(error.toString()));
      }
    }

    return DraggableScrollableSheet(
      expand: false,
      minChildSize: 0.25,
      initialChildSize: 0.6,
      builder: (context, controller) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      S.of(context).notificationsTitle,
                      style: theme.textTheme.titleLarge,
                    ),
                  ),
                  if (hasNotifications)
                    TextButton.icon(
                      onPressed: () => unawaited(clearAll()),
                      icon: const Icon(Icons.delete_sweep_outlined),
                      label: Text(S.of(context).actionClearAll),
                      style: TextButton.styleFrom(
                        foregroundColor: theme.colorScheme.error,
                      ),
                    ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    tooltip: S.of(context).actionClose,
                    onPressed: () => Navigator.of(context).maybePop(),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: notificationsAsync.when(
                data: (notifications) {
                  if (notifications.isEmpty) {
                    return EmptyState(
                      icon: Icons.notifications_none_outlined,
                      title: S.of(context).noNotificationsTitle,
                      message:
                          S.of(context).noNotificationsMessage,
                    );
                  }

                  return ListView.separated(
                    controller: controller,
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
                    itemBuilder: (context, index) {
                      final notification = notifications[index];
                      return NotificationListTile(notification: notification);
                    },
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemCount: notifications.length,
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _) => EmptyState(
                  icon: Icons.error_outline,
                  title: S.of(context).errorLoadingNotifications,
                  message: '$error',
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

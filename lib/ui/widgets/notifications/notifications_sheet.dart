import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../providers/book_providers.dart';
import '../empty_state.dart';
import 'notification_list_tile.dart';

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
        showSnack('No hay notificaciones para limpiar.');
        return;
      }
      if (activeUser == null) {
        showSnack('Configura un usuario activo antes de limpiar.');
        return;
      }
      try {
        await repository.clearAllForUser(activeUser.id);
        if (!context.mounted) return;
        showSnack('Notificaciones borradas.');
      } catch (error) {
        if (!context.mounted) return;
        showSnack('No se pudieron borrar las notificaciones: $error');
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
                      'Notificaciones',
                      style: theme.textTheme.titleLarge,
                    ),
                  ),
                  if (hasNotifications)
                    TextButton.icon(
                      onPressed: () => unawaited(clearAll()),
                      icon: const Icon(Icons.delete_sweep_outlined),
                      label: const Text('Vaciar'),
                      style: TextButton.styleFrom(
                        foregroundColor: theme.colorScheme.error,
                      ),
                    ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    tooltip: 'Cerrar',
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
                    return const EmptyState(
                      icon: Icons.notifications_none_outlined,
                      title: 'Sin notificaciones',
                      message:
                          'Aquí verás las novedades sobre tus préstamos y solicitudes.',
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
                  title: 'No se pudieron cargar',
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

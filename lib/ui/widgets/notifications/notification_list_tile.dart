import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../data/local/database.dart';
import '../../../../data/models/in_app_notification_status.dart';
import '../../../../data/models/in_app_notification_type.dart';
import '../../../../providers/book_providers.dart';
import 'notification_visuals.dart';

/// Individual notification list tile with action buttons
class NotificationListTile extends ConsumerWidget {
  const NotificationListTile({super.key, required this.notification});

  final InAppNotification notification;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repository = ref.read(notificationRepositoryProvider);
    final loanController = ref.read(loanControllerProvider.notifier);
    final loanState = ref.watch(loanControllerProvider);
    final loanRepository = ref.read(loanRepositoryProvider);
    final activeUser = ref.watch(activeUserProvider).value;
    final visuals = NotificationVisuals.fromNotification(context, notification);
    final type = InAppNotificationType.fromValue(notification.type);

    final isUnread = notification.status == InAppNotificationStatus.unread;
    final createdAt = DateFormat.yMMMd().add_Hm().format(notification.createdAt);
    final isLoanBusy = loanState.isLoading;

    Future<void> markRead() async {
      await repository.markAs(
        uuid: notification.uuid,
        status: InAppNotificationStatus.read,
      );
    }

    Future<void> dismiss() async {
      await repository.softDelete(uuid: notification.uuid);
    }

    void showSnack(String message, {bool isError = false}) {
      final theme = Theme.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isError ? theme.colorScheme.errorContainer : null,
        ),
      );
    }

    Future<void> handleLoanDecision({required bool accept}) async {
      final owner = activeUser;
      final loanId = notification.loanId;
      if (owner == null) {
        showSnack('Necesitas un usuario activo para gestionar el préstamo.', isError: true);
        return;
      }
      if (loanId == null) {
        showSnack('No se encontró el préstamo asociado.', isError: true);
        return;
      }

      final loan = await loanRepository.findLoanById(loanId);
      if (loan == null) {
        if (!context.mounted) return;
        showSnack('El préstamo ya no está disponible.', isError: true);
        return;
      }

      try {
        if (accept) {
          await loanController.acceptLoan(loan: loan, owner: owner);
        } else {
          await loanController.rejectLoan(loan: loan, owner: owner);
        }
        if (!context.mounted) return;
        await markRead();
        if (!context.mounted) return;
        showSnack(accept ? 'Solicitud aceptada.' : 'Solicitud rechazada.');
      } catch (error) {
        if (!context.mounted) return;
        showSnack('No se pudo completar la acción: $error', isError: true);
      }
    }

    final canHandleLoanRequest =
        type == InAppNotificationType.loanRequested && activeUser?.id == notification.targetUserId;

    return Card(
      color: visuals.background,
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
                      const SizedBox(height: 8),
                      Text(
                        createdAt,
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: visuals.secondaryTextColor),
                      ),
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
                if (canHandleLoanRequest && notification.loanId != null) ...[
                  FilledButton.icon(
                    onPressed: isLoanBusy ? null : () => handleLoanDecision(accept: true),
                    icon: const Icon(Icons.check_circle_outline),
                    label: const Text('Aceptar'),
                  ),
                  OutlinedButton.icon(
                    onPressed: isLoanBusy ? null : () => handleLoanDecision(accept: false),
                    icon: const Icon(Icons.cancel_outlined),
                    label: const Text('Rechazar'),
                  ),
                ],
                if (isUnread)
                  TextButton.icon(
                    onPressed: markRead,
                    icon: const Icon(Icons.mark_email_read_outlined),
                    label: const Text('Marcar como leído'),
                  ),
                TextButton.icon(
                  onPressed: dismiss,
                  icon: const Icon(Icons.close),
                  label: const Text('Descartar'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../../../data/local/database.dart';
import '../../../../data/models/in_app_notification_type.dart';

/// Helper class for notification visual styling
class NotificationVisuals {
  NotificationVisuals({
    required this.icon,
    required this.background,
    required this.iconColor,
    required this.textColor,
    required this.secondaryTextColor,
    required this.defaultTitle,
  });

  final IconData icon;
  final Color background;
  final Color iconColor;
  final Color textColor;
  final Color secondaryTextColor;
  final String defaultTitle;

  static NotificationVisuals fromNotification(
    BuildContext context,
    InAppNotification notification,
  ) {
    final scheme = Theme.of(context).colorScheme;
    final type = InAppNotificationType.fromValue(notification.type);

    Color background;
    Color iconColor;
    Color textColor;
    Color secondaryTextColor;
    IconData icon;
    String defaultTitle;

    switch (type) {
      case InAppNotificationType.loanAccepted:
        background = scheme.primaryContainer;
        iconColor = scheme.onPrimaryContainer;
        textColor = scheme.onPrimaryContainer;
        secondaryTextColor = scheme.onPrimaryContainer.withValues(alpha: 0.8);
        icon = Icons.check_circle_outline;
        defaultTitle = 'Préstamo aceptado';
        break;
      case InAppNotificationType.loanRejected:
        background = scheme.errorContainer;
        iconColor = scheme.onErrorContainer;
        textColor = scheme.onErrorContainer;
        secondaryTextColor = scheme.onErrorContainer.withValues(alpha: 0.8);
        icon = Icons.cancel_outlined;
        defaultTitle = 'Solicitud rechazada';
        break;
      case InAppNotificationType.loanCancelled:
        background = scheme.surfaceContainerHigh;
        iconColor = scheme.onSurface;
        textColor = scheme.onSurface;
        secondaryTextColor = scheme.onSurfaceVariant;
        icon = Icons.remove_circle_outline;
        defaultTitle = 'Solicitud cancelada';
        break;
      case InAppNotificationType.loanReturned:
        background = scheme.secondaryContainer;
        iconColor = scheme.onSecondaryContainer;
        textColor = scheme.onSecondaryContainer;
        secondaryTextColor = scheme.onSecondaryContainer.withValues(alpha: 0.8);
        icon = Icons.assignment_turned_in_outlined;
        defaultTitle = 'Préstamo devuelto';
        break;
      case InAppNotificationType.loanExpired:
        background = scheme.tertiaryContainer;
        iconColor = scheme.onTertiaryContainer;
        textColor = scheme.onTertiaryContainer;
        secondaryTextColor = scheme.onTertiaryContainer.withValues(alpha: 0.8);
        icon = Icons.schedule_outlined;
        defaultTitle = 'Préstamo vencido';
        break;
      case InAppNotificationType.loanRequest:
      default:
        background = scheme.surfaceContainerHighest;
        iconColor = scheme.primary;
        textColor = scheme.onSurface;
        secondaryTextColor = scheme.onSurfaceVariant;
        icon = Icons.mark_email_unread_outlined;
        defaultTitle = 'Nueva solicitud de préstamo';
        break;
    }

    return NotificationVisuals(
      icon: icon,
      background: background,
      iconColor: iconColor,
      textColor: textColor,
      secondaryTextColor: secondaryTextColor,
      defaultTitle: defaultTitle,
    );
  }
}

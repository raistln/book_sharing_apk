import 'package:flutter/material.dart';
import '../../../../l10n/generated/app_localizations.dart';

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
      case InAppNotificationType.loanApproved:
        background = scheme.primaryContainer;
        iconColor = scheme.onPrimaryContainer;
        textColor = scheme.onPrimaryContainer;
        secondaryTextColor = scheme.onPrimaryContainer.withValues(alpha: 0.8);
        icon = Icons.check_circle_outline;
        defaultTitle = S.of(context).notificationLoanApproved;
        break;
      case InAppNotificationType.loanRejected:
        background = scheme.errorContainer;
        iconColor = scheme.onErrorContainer;
        textColor = scheme.onErrorContainer;
        secondaryTextColor = scheme.onErrorContainer.withValues(alpha: 0.8);
        icon = Icons.cancel_outlined;
        defaultTitle = S.of(context).notificationLoanRejected;
        break;
      case InAppNotificationType.loanCancelled:
        background = scheme.surfaceContainerHigh;
        iconColor = scheme.onSurface;
        textColor = scheme.onSurface;
        secondaryTextColor = scheme.onSurfaceVariant;
        icon = Icons.remove_circle_outline;
        defaultTitle = S.of(context).notificationLoanCancelled;
        break;
      case InAppNotificationType.loanReturned:
        background = scheme.secondaryContainer;
        iconColor = scheme.onSecondaryContainer;
        textColor = scheme.onSecondaryContainer;
        secondaryTextColor = scheme.onSecondaryContainer.withValues(alpha: 0.8);
        icon = Icons.assignment_turned_in_outlined;
        defaultTitle = S.of(context).notificationLoanReturned;
        break;
      case InAppNotificationType.loanExpired:
        background = scheme.tertiaryContainer;
        iconColor = scheme.onTertiaryContainer;
        textColor = scheme.onTertiaryContainer;
        secondaryTextColor = scheme.onTertiaryContainer.withValues(alpha: 0.8);
        icon = Icons.schedule_outlined;
        defaultTitle = S.of(context).notificationLoanExpired;
        break;
      case InAppNotificationType.loanDueSoon:
        background = scheme.tertiaryContainer;
        iconColor = scheme.onTertiaryContainer;
        textColor = scheme.onTertiaryContainer;
        secondaryTextColor = scheme.onTertiaryContainer.withValues(alpha: 0.8);
        icon = Icons.notification_important_outlined;
        defaultTitle = S.of(context).notificationLoanDueSoon;
        break;
      case InAppNotificationType.groupMemberJoined:
        background = scheme.primaryContainer;
        iconColor = scheme.onPrimaryContainer;
        textColor = scheme.onPrimaryContainer;
        secondaryTextColor = scheme.onPrimaryContainer.withValues(alpha: 0.8);
        icon = Icons.person_add_outlined;
        defaultTitle = S.of(context).notificationMemberJoined;
        break;
      case InAppNotificationType.groupMemberLeft:
        background = scheme.surfaceContainerHigh;
        iconColor = scheme.onSurface;
        textColor = scheme.onSurface;
        secondaryTextColor = scheme.onSurfaceVariant;
        icon = Icons.person_remove_outlined;
        defaultTitle = S.of(context).notificationMemberLeft;
        break;
      case InAppNotificationType.groupUpdated:
        background = scheme.secondaryContainer;
        iconColor = scheme.onSecondaryContainer;
        textColor = scheme.onSecondaryContainer;
        secondaryTextColor = scheme.onSecondaryContainer.withValues(alpha: 0.8);
        icon = Icons.info_outline;
        defaultTitle = S.of(context).notificationGroupUpdated;
        break;
      case InAppNotificationType.groupDeleted:
        background = scheme.errorContainer;
        iconColor = scheme.onErrorContainer;
        textColor = scheme.onErrorContainer;
        secondaryTextColor = scheme.onErrorContainer.withValues(alpha: 0.8);
        icon = Icons.delete_forever_outlined;
        defaultTitle = S.of(context).notificationGroupDeleted;
        break;
      case InAppNotificationType.loanRequested:
      default:
        background = scheme.surfaceContainerHighest;
        iconColor = scheme.primary;
        textColor = scheme.onSurface;
        secondaryTextColor = scheme.onSurfaceVariant;
        icon = Icons.mark_email_unread_outlined;
        defaultTitle = S.of(context).notificationLoanRequested;
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

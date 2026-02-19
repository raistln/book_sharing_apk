import 'dart:async';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/notification_service.dart';

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService.instance;
});

enum NotificationIntentOrigin {
  initialLaunch,
  notificationTap,
  actionTap,
}

class NotificationIntent {
  NotificationIntent({
    required this.type,
    this.action,
    this.loanId,
    this.groupId,
    this.invitationId,
    required this.origin,
    required this.receivedAt,
  });

  final NotificationType type;
  final NotificationActionType? action;
  final String? loanId;
  final String? groupId;
  final String? invitationId;
  final NotificationIntentOrigin origin;
  final DateTime receivedAt;

  bool get isAction => action != null;
}

class NotificationIntentNotifier extends StateNotifier<NotificationIntent?> {
  NotificationIntentNotifier(this._service) : super(null) {
    _subscription = _service.responses.listen(
      (response) => _emitIntent(
        response,
        NotificationIntentOrigin.notificationTap,
      ),
    );
    _init();
  }

  final NotificationService _service;
  StreamSubscription<NotificationResponse>? _subscription;

  Future<void> _init() async {
    final initial = await _service.getInitialResponse();
    if (initial != null) {
      _emitIntent(initial, NotificationIntentOrigin.initialLaunch);
    }
  }

  void clear() {
    state = null;
  }

  void _emitIntent(
    NotificationResponse response,
    NotificationIntentOrigin origin,
  ) {
    final payloadMap = _service.decodePayload(response.payload);
    final typeName = payloadMap[NotificationPayloadKeys.type];
    if (typeName == null) {
      return;
    }

    final type = _parseType(typeName);
    if (type == null) {
      return;
    }

    final actionName = payloadMap[NotificationPayloadKeys.action];
    final action = _parseAction(actionName);

    final originOverride = response.notificationResponseType ==
            NotificationResponseType.selectedNotificationAction
        ? NotificationIntentOrigin.actionTap
        : origin;

    state = NotificationIntent(
      type: type,
      action: action,
      loanId: payloadMap[NotificationPayloadKeys.loanId],
      groupId: payloadMap[NotificationPayloadKeys.groupId],
      invitationId: payloadMap[NotificationPayloadKeys.invitationId],
      origin: originOverride,
      receivedAt: DateTime.now(),
    );
  }

  NotificationType? _parseType(String typeName) {
    for (final value in NotificationType.values) {
      if (value.name == typeName) {
        return value;
      }
    }
    return null;
  }

  NotificationActionType? _parseAction(String? actionName) {
    if (actionName == null) {
      return null;
    }
    for (final value in NotificationActionType.values) {
      if (value.name == actionName) {
        return value;
      }
    }
    return null;
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

final notificationIntentProvider =
    StateNotifierProvider<NotificationIntentNotifier, NotificationIntent?>(
        (ref) {
  final service = ref.watch(notificationServiceProvider);
  return NotificationIntentNotifier(service);
});

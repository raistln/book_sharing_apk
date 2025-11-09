import 'dart:async';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

abstract class NotificationClient {
  Future<void> showImmediate({
    required int id,
    required NotificationType type,
    required String title,
    required String body,
    Map<String, String>? payload,
    List<AndroidNotificationAction>? androidActions,
  });

  Future<void> schedule({
    required int id,
    required NotificationType type,
    required String title,
    required String body,
    required DateTime scheduledAt,
    Map<String, String>? payload,
  });

  Future<void> cancel(int id);

  Future<void> cancelMany(Iterable<int> ids);
}

/// Identifiers for different notification channels and payload keys.
class NotificationChannels {
  NotificationChannels._();

  static const String generalId = 'book_sharing_general';
  static const String generalName = 'Book Sharing';
  static const String generalDescription =
      'Notificaciones sobre préstamos e invitaciones.';
}

class NotificationPayloadKeys {
  NotificationPayloadKeys._();

  static const String type = 'type';
  static const String loanId = 'loanId';
  static const String sharedBookId = 'sharedBookId';
  static const String groupId = 'groupId';
  static const String invitationId = 'invitationId';
  static const String action = 'action';
}

enum NotificationType {
  loanDueSoon,
  loanExpired,
  groupInvitation,
}

enum NotificationActionType {
  open,
  invitationAccept,
  invitationReject,
}

/// Wrapper around [FlutterLocalNotificationsPlugin] to centralize initialization
/// and display logic for the app.
class NotificationService implements NotificationClient {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  final _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;
  bool _timezoneInitialized = false;

  final _responseController = StreamController<NotificationResponse>.broadcast();

  Stream<NotificationResponse> get responses => _responseController.stream;

  Future<void> init() async {
    if (_initialized) return;

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initializationSettings = InitializationSettings(android: androidSettings);

    await _plugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _handleResponse,
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );

    if (!_timezoneInitialized) {
      tzdata.initializeTimeZones();
      _timezoneInitialized = true;
    }

    const androidChannel = AndroidNotificationChannel(
      NotificationChannels.generalId,
      NotificationChannels.generalName,
      description: NotificationChannels.generalDescription,
      importance: Importance.high,
    );

    await _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);

    _initialized = true;
  }

  Future<bool> requestPermissions() async {
    final androidImpl = _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    if (androidImpl == null) {
      return false;
    }
    final granted = await androidImpl.requestNotificationsPermission();
    return granted ?? false;
  }

  @override
  Future<void> showImmediate({
    required int id,
    required NotificationType type,
    required String title,
    required String body,
    Map<String, String>? payload,
    List<AndroidNotificationAction>? androidActions,
  }) async {
    await init();

    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        NotificationChannels.generalId,
        NotificationChannels.generalName,
        channelDescription: NotificationChannels.generalDescription,
        importance: Importance.high,
        priority: Priority.high,
        ticker: title,
        actions: androidActions,
      ),
    );

    await _plugin.show(
      id,
      title,
      body,
      details,
      payload: _encodePayload(type, payload),
    );
  }

  @override
  Future<void> schedule({
    required int id,
    required NotificationType type,
    required String title,
    required String body,
    required DateTime scheduledAt,
    Map<String, String>? payload,
  }) async {
    await init();

    final scheduledInstant = scheduledAt.isUtc ? scheduledAt : scheduledAt.toUtc();
    final tzDateTime = tz.TZDateTime.from(scheduledInstant, tz.UTC);

    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        NotificationChannels.generalId,
        NotificationChannels.generalName,
        channelDescription: NotificationChannels.generalDescription,
        importance: Importance.high,
        priority: Priority.high,
      ),
    );

    await _plugin.zonedSchedule(
      id,
      title,
      body,
      tzDateTime,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: _encodePayload(type, payload),
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: null,
    );
  }

  @override
  Future<void> cancel(int id) async {
    await init();
    await _plugin.cancel(id);
  }

  @override
  Future<void> cancelMany(Iterable<int> ids) async {
    if (ids.isEmpty) {
      return;
    }
    await init();
    for (final id in ids) {
      await _plugin.cancel(id);
    }
  }

  Future<NotificationResponse?> getInitialResponse() async {
    await init();
    final details = await _plugin.getNotificationAppLaunchDetails();
    return details?.notificationResponse;
  }

  Future<List<PendingNotificationRequest>> getPendingNotificationRequests() async {
    await init();
    return _plugin.pendingNotificationRequests();
  }

  Map<String, String> decodePayload(String? payload) {
    if (payload == null || payload.isEmpty) {
      return const {};
    }
    final pairs = payload.split('&');
    final map = <String, String>{};
    for (final pair in pairs) {
      final idx = pair.indexOf('=');
      if (idx <= 0) continue;
      final key = Uri.decodeComponent(pair.substring(0, idx));
      final value = Uri.decodeComponent(pair.substring(idx + 1));
      map[key] = value;
    }
    return map;
  }

  void _handleResponse(NotificationResponse response) {
    _responseController.add(response);
  }

  String _encodePayload(NotificationType type, Map<String, String>? payload) {
    final map = <String, String>{
      NotificationPayloadKeys.type: type.name,
      if (payload != null) ...payload,
    };
    return map.entries
        .map((entry) =>
            '${Uri.encodeComponent(entry.key)}=${Uri.encodeComponent(entry.value)}')
        .join('&');
  }
}

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse response) {
  NotificationService.instance._handleResponse(response);
}

class NotificationIds {
  NotificationIds._();

  static int loanDueSoon(String loanUuid) => _hash('loanDueSoon::$loanUuid');

  static int loanExpired(String loanUuid) => _hash('loanExpired::$loanUuid');

  static int groupInvitation(String invitationUuid) =>
      _hash('groupInvitation::$invitationUuid');

  static int _hash(String value) => value.hashCode & 0x7fffffff;
}

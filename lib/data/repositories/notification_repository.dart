import 'dart:async';
import 'dart:developer' as developer;

import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../../services/sync_service.dart';
import '../local/database.dart';
import '../local/notification_dao.dart';
import '../models/in_app_notification_status.dart';
import '../models/in_app_notification_type.dart';

class NotificationRepository {
  NotificationRepository({
    required NotificationDao notificationDao,
    SyncController? notificationSyncController,
    Uuid? uuid,
  })  : _notificationDao = notificationDao,
        _notificationSyncController = notificationSyncController,
        _uuid = uuid ?? const Uuid();

  final NotificationDao _notificationDao;
  final SyncController? _notificationSyncController;
  final Uuid _uuid;
  bool _isDisposed = false;

  void dispose() {
    _isDisposed = true;
  }

  void _scheduleSync() {
    if (_isDisposed) {
      return;
    }
    final controller = _notificationSyncController;
    if (controller == null) {
      developer.log('[_scheduleSync] No sync controller available', name: 'NotificationRepository');
      return;
    }

    if (!controller.mounted) {
      developer.log('[_scheduleSync] Controller not mounted', name: 'NotificationRepository');
      return;
    }

    try {
      controller.markPendingChanges();
      developer.log('[_scheduleSync] Marked pending changes', name: 'NotificationRepository');
    } on StateError catch (error) {
      if (controller.mounted) {
        rethrow;
      }
      debugPrint('NotificationRepository: pending changes skipped after dispose — $error');
      return;
    }

    unawaited(Future<void>(() async {
      if (_isDisposed) {
        return;
      }
      if (!controller.mounted) {
        return;
      }
      try {
        developer.log('[_scheduleSync] Starting sync...', name: 'NotificationRepository');
        await controller.sync();
        developer.log('[_scheduleSync] Sync completed', name: 'NotificationRepository');
      } on StateError catch (error) {
        if (controller.mounted) {
          rethrow;
        }
        debugPrint('NotificationRepository: sync skipped after dispose — $error');
      } catch (error, stackTrace) {
        developer.log(
          '[_scheduleSync] Sync failed: $error',
          name: 'NotificationRepository',
          error: error,
          stackTrace: stackTrace,
          level: 1000,
        );
      }
    }));
  }

  Future<int> createNotification({
    required InAppNotificationType type,
    required int targetUserId,
    int? actorUserId,
    int? loanId,
    String? loanUuid,
    int? sharedBookId,
    String? sharedBookUuid,
    String? title,
    String? message,
    String status = InAppNotificationStatus.unread,
  }) async {
    developer.log(
      '[createNotification] Creating notification: type=${type.value}, targetUserId=$targetUserId, actorUserId=$actorUserId, loanId=$loanId',
      name: 'NotificationRepository',
    );
    
    final now = DateTime.now();
    final entry = InAppNotificationsCompanion(
      uuid: Value(_uuid.v4()),
      type: Value(type.value),
      targetUserId: Value(targetUserId),
      actorUserId: actorUserId != null ? Value(actorUserId) : const Value.absent(),
      loanId: loanId != null ? Value(loanId) : const Value.absent(),
      loanUuid: loanUuid != null ? Value(loanUuid) : const Value.absent(),
      sharedBookId: sharedBookId != null ? Value(sharedBookId) : const Value.absent(),
      sharedBookUuid:
          sharedBookUuid != null ? Value(sharedBookUuid) : const Value.absent(),
      title: title != null ? Value(title) : const Value.absent(),
      message: message != null ? Value(message) : const Value.absent(),
      status: Value(status),
      isDirty: const Value(true),
      isDeleted: const Value(false),
      syncedAt: const Value(null),
      createdAt: Value(now),
      updatedAt: Value(now),
    );
    final id = await _notificationDao.insert(entry);
    developer.log(
      '[createNotification] Notification created with id=$id, scheduling sync...',
      name: 'NotificationRepository',
    );
    _scheduleSync();
    return id;
  }

  Future<int> createLoanNotification({
    required InAppNotificationType type,
    required Loan loan,
    required int targetUserId,
    int? actorUserId,
    String? title,
    String? message,
    String status = InAppNotificationStatus.unread,
  }) {
    return createNotification(
      type: type,
      targetUserId: targetUserId,
      actorUserId: actorUserId,
      loanId: loan.id,
      loanUuid: loan.uuid,
      sharedBookId: loan.sharedBookId,
      sharedBookUuid: loan.sharedBookUuid,
      title: title,
      message: message,
      status: status,
    );
  }

  Future<void> markLoanNotifications({
    required int loanId,
    required String status,
  }) {
    final now = DateTime.now();
    return _notificationDao.markAllForLoan(
      loanId: loanId,
      status: status,
      timestamp: now,
    ).then((_) => _scheduleSync());
  }

  Future<void> markAs({
    required String uuid,
    required String status,
  }) {
    final now = DateTime.now();
    return _notificationDao
        .markStatusByUuid(
      uuid: uuid,
      status: status,
      timestamp: now,
    )
        .then((_) => _scheduleSync());
  }

  Future<void> softDelete({required String uuid}) {
    final now = DateTime.now();
    return _notificationDao
        .softDeleteByUuid(uuid: uuid, timestamp: now)
        .then((_) => _scheduleSync());
  }

  Future<void> clearAllForUser(int userId) {
    final now = DateTime.now();
    return _notificationDao
        .softDeleteAllForUser(userId: userId, timestamp: now)
        .then((_) => _scheduleSync());
  }

  Stream<List<InAppNotification>> watchForUser(int userId) {
    return _notificationDao.watchForUser(userId);
  }

  Stream<int> watchUnreadCount(int userId) {
    return _notificationDao.watchUnreadCount(userId);
  }

  Future<int> countUnread(int userId) {
    return _notificationDao.countUnread(userId);
  }

  Future<int> purgeExpired({
    Duration readRetention = const Duration(days: 15),
    Duration othersRetention = const Duration(days: 30),
  }) {
    final now = DateTime.now();
    return _notificationDao.purgeExpired(
      readThreshold: now.subtract(readRetention),
      othersThreshold: now.subtract(othersRetention),
    );
  }
}

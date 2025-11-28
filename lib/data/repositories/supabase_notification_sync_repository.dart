import 'dart:developer' as developer;

import 'package:drift/drift.dart';

import '../local/database.dart';
import '../local/group_dao.dart';
import '../local/notification_dao.dart';
import '../local/user_dao.dart';
import '../../services/supabase_notification_service.dart';

class SupabaseNotificationSyncRepository {
  SupabaseNotificationSyncRepository({
    required NotificationDao notificationDao,
    required UserDao userDao,
    required GroupDao groupDao,
    SupabaseNotificationService? notificationService,
  })  : _notificationDao = notificationDao,
        _userDao = userDao,
        _groupDao = groupDao,
        _notificationService = notificationService ?? SupabaseNotificationService();

  final NotificationDao _notificationDao;
  final UserDao _userDao;
  final GroupDao _groupDao;
  final SupabaseNotificationService _notificationService;

  Future<void> syncFromRemote({
    required LocalUser target,
    String? accessToken,
  }) async {
    final targetRemoteId = target.remoteId;
    if (targetRemoteId == null || targetRemoteId.isEmpty) {
      developer.log(
        'No se pueden descargar notificaciones: el usuario ${target.username} no tiene remoteId.',
        name: 'SupabaseNotificationSyncRepository',
        level: 900,
      );
      return;
    }

    developer.log(
      'Descargando notificaciones remotas para ${target.username} ($targetRemoteId).',
      name: 'SupabaseNotificationSyncRepository',
    );

    final remoteNotifications = await _notificationService.fetchNotifications(
      targetUserId: targetRemoteId,
      accessToken: accessToken,
      includeDeleted: true,
    );

    if (remoteNotifications.isEmpty) {
      developer.log(
        'No se encontraron notificaciones remotas para $targetRemoteId.',
        name: 'SupabaseNotificationSyncRepository',
      );
      return;
    }

    final db = _notificationDao.attachedDatabase;
    final syncTime = DateTime.now();

    await db.transaction(() async {
      for (final remote in remoteNotifications) {
        final existing = await _notificationDao.findByUuid(remote.id);

        if (existing != null && existing.isDirty) {
          developer.log(
            'Omitiendo notificación ${remote.id} durante fetch: cambios locales pendientes.',
            name: 'SupabaseNotificationSyncRepository',
          );
          continue;
        }

        final resolvedLoan = await _resolveLoan(remote.loanId);

        final companion = InAppNotificationsCompanion(
          type: Value(remote.type),
          targetUserId: Value(target.id),
          loanId: resolvedLoan != null
              ? Value(resolvedLoan.id)
              : const Value<int?>.absent(),
          loanUuid: Value(remote.loanId),
          title: Value(remote.title),
          message: Value(remote.message),
          status: Value(remote.status),
          isDeleted: const Value(false), // loan_notifications doesn't have is_deleted
          isDirty: const Value(false),
          syncedAt: Value(syncTime),
          createdAt: Value(remote.createdAt),
        );

        if (existing != null) {
          await _notificationDao.updateFields(
            notificationId: existing.id,
            entry: companion,
          );
          continue;
        }

        await _notificationDao.insert(
          InAppNotificationsCompanion.insert(
            uuid: remote.id,
            type: remote.type,
            targetUserId: target.id,
            loanId: resolvedLoan != null
                ? Value(resolvedLoan.id)
                : const Value<int?>.absent(),
            loanUuid: Value(remote.loanId),
            title: Value(remote.title),
            message: Value(remote.message),
            status: Value(remote.status),
            isDirty: const Value(false),
            syncedAt: Value(syncTime),
            createdAt: Value(remote.createdAt),
          ),
        );
      }
    });
  }

  Future<void> pushLocalChanges({
    required LocalUser target,
    String? accessToken,
  }) async {
    final dirtyNotifications = await _notificationDao.getDirtyNotifications();
    if (dirtyNotifications.isEmpty) {
      developer.log(
        'No hay notificaciones locales pendientes para ${target.username}.',
        name: 'SupabaseNotificationSyncRepository',
      );
      return;
    }

    developer.log(
      'Sincronizando ${dirtyNotifications.length} notificación(es) locales de ${target.username}.',
      name: 'SupabaseNotificationSyncRepository',
    );

    final syncTime = DateTime.now();

    for (final local in dirtyNotifications) {
      try {
        final loanRemoteId = await _resolveLoanRemoteId(local.loanId, local.loanUuid);

        final targetUser = await _userDao.getById(local.targetUserId);
        final targetUserRemoteId = targetUser?.remoteId;
        if (targetUserRemoteId == null || targetUserRemoteId.isEmpty) {
          developer.log(
            'No se puede subir la notificación ${local.uuid}: el usuario objetivo ${local.targetUserId} no tiene remoteId registrado.',
            name: 'SupabaseNotificationSyncRepository',
            level: 900,
          );
          continue;
        }

        developer.log(
          'Subiendo notificación ${local.uuid} (tipo=${local.type}) para usuario remoto $targetUserRemoteId.',
          name: 'SupabaseNotificationSyncRepository',
        );

        final input = SupabaseNotificationUpsert(
          id: local.uuid,
          loanId: loanRemoteId ?? '',
          userId: targetUserRemoteId,
          type: local.type,
          title: local.title ?? '',
          message: local.message ?? '',
          status: local.status,
          createdAt: local.createdAt,
        );

        final remote = await _notificationService.upsertNotification(
          input: input,
          accessToken: accessToken,
        );

        developer.log(
          'Notificación ${local.uuid} sincronizada correctamente con id remoto ${remote.id}.',
          name: 'SupabaseNotificationSyncRepository',
        );

        final resolvedLoan = await _resolveLoan(remote.loanId);

        await _notificationDao.updateFields(
          notificationId: local.id,
          entry: InAppNotificationsCompanion(
            loanId: resolvedLoan != null
                ? Value(resolvedLoan.id)
                : const Value<int?>.absent(),
            status: Value(remote.status),
            isDeleted: const Value(false), // loan_notifications doesn't have is_deleted
            isDirty: const Value(false),
            syncedAt: Value(syncTime),
          ),
        );
      } catch (error, stackTrace) {
        developer.log(
          'Error al sincronizar notificación ${local.uuid}: $error',
          name: 'SupabaseNotificationSyncRepository',
          error: error,
          stackTrace: stackTrace,
          level: 1000,
        );
        rethrow;
      }
    }
  }

  
  Future<_LoanResolution?> _resolveLoan(String? remoteIdOrUuid) async {
    if (remoteIdOrUuid == null || remoteIdOrUuid.isEmpty) {
      return null;
    }

    final byRemote = await _groupDao.findLoanByRemoteId(remoteIdOrUuid);
    if (byRemote != null) {
      return _LoanResolution(id: byRemote.id, uuid: byRemote.uuid, remoteId: byRemote.remoteId);
    }

    final byUuid = await _groupDao.findLoanByUuid(remoteIdOrUuid);
    if (byUuid != null) {
      return _LoanResolution(id: byUuid.id, uuid: byUuid.uuid, remoteId: byUuid.remoteId);
    }

    developer.log(
      'No encontramos préstamo con identificador $remoteIdOrUuid para enlazar notificación.',
      name: 'SupabaseNotificationSyncRepository',
      level: 800,
    );
    return null;
  }

  Future<String?> _resolveLoanRemoteId(int? loanId, String? loanUuid) async {
    if (loanUuid != null && loanUuid.isNotEmpty) {
      return loanUuid;
    }

    if (loanId == null) {
      return null;
    }

    final loan = await _groupDao.findLoanById(loanId);
    if (loan == null) {
      return null;
    }

    final remoteId = loan.remoteId;
    if (remoteId != null && remoteId.isNotEmpty) {
      return remoteId;
    }

    developer.log(
      'Usando uuid local ${loan.uuid} como identificador remoto de préstamo para notificación.',
      name: 'SupabaseNotificationSyncRepository',
    );

    return loan.uuid;
  }
}

class _LoanResolution {
  const _LoanResolution({
    required this.id,
    required this.uuid,
    this.remoteId,
  });

  final int id;
  final String uuid;
  final String? remoteId;
}

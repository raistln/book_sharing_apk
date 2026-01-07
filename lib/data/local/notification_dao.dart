import 'package:drift/drift.dart';

import 'database.dart';

part 'notification_dao.g.dart';

@DriftAccessor(tables: [InAppNotifications])
class NotificationDao extends DatabaseAccessor<AppDatabase>
    with _$NotificationDaoMixin {
  NotificationDao(super.db);

  Future<int> insert(InAppNotificationsCompanion entry) {
    return into(inAppNotifications).insert(entry);
  }

  Future<InAppNotification?> findById(int id) {
    return (select(inAppNotifications)..where((tbl) => tbl.id.equals(id)))
        .getSingleOrNull();
  }

  Future<InAppNotification?> findByUuid(String uuid) {
    return (select(inAppNotifications)..where((tbl) => tbl.uuid.equals(uuid)))
        .getSingleOrNull();
  }

  Future<int> updateFields({
    required int notificationId,
    required InAppNotificationsCompanion entry,
  }) {
    return (update(inAppNotifications)
          ..where((tbl) => tbl.id.equals(notificationId)))
        .write(entry);
  }

  Future<void> markStatus({
    required int notificationId,
    required String status,
    required DateTime timestamp,
  }) {
    return updateFields(
      notificationId: notificationId,
      entry: InAppNotificationsCompanion(
        status: Value(status),
        updatedAt: Value(timestamp),
        isDirty: const Value(true),
        syncedAt: const Value(null),
      ),
    ).then((_) => null);
  }

  Future<void> markStatusByUuid({
    required String uuid,
    required String status,
    required DateTime timestamp,
  }) async {
    final existing = await findByUuid(uuid);
    if (existing != null) {
      await markStatus(
        notificationId: existing.id,
        status: status,
        timestamp: timestamp,
      );
    }
  }

  Future<void> softDeleteByUuid({
    required String uuid,
    required DateTime timestamp,
  }) {
    return (update(inAppNotifications)..where((tbl) => tbl.uuid.equals(uuid)))
        .write(
      InAppNotificationsCompanion(
        isDeleted: const Value(true),
        updatedAt: Value(timestamp),
        isDirty: const Value(true),
        syncedAt: const Value(null),
      ),
    );
  }

  Future<void> softDeleteAllForUser({
    required int userId,
    required DateTime timestamp,
  }) {
    return (update(inAppNotifications)
          ..where((tbl) => tbl.targetUserId.equals(userId)))
        .write(
      InAppNotificationsCompanion(
        isDeleted: const Value(true),
        updatedAt: Value(timestamp),
        isDirty: const Value(true),
        syncedAt: const Value(null),
        status: const Value('dismissed'),
      ),
    );
  }

  Future<int> purgeExpired({
    required DateTime readThreshold,
    required DateTime othersThreshold,
  }) {
    return (delete(inAppNotifications)
          ..where((tbl) {
            final readStatuses = <String>{'read', 'dismissed'};

            final readCondition = tbl.status.isIn(readStatuses) &
                tbl.updatedAt.isSmallerThanValue(readThreshold);

            final otherCondition = tbl.status.isNotIn(readStatuses) &
                tbl.updatedAt.isSmallerThanValue(othersThreshold);

            final isClean = tbl.isDirty.equals(false) | tbl.isDirty.isNull();

            return (readCondition | otherCondition) & isClean;
          }))
        .go();
  }

  Future<List<InAppNotification>> getDirtyNotifications() {
    return (select(inAppNotifications)
          ..where((tbl) => tbl.isDirty.equals(true)))
        .get();
  }

  Future<void> markClean({
    required int notificationId,
    required DateTime syncedAt,
    bool? isDeleted,
    String? status,
    int? actorUserId,
    int? loanId,
    String? loanUuid,
    int? sharedBookId,
  }) {
    return updateFields(
      notificationId: notificationId,
      entry: InAppNotificationsCompanion(
        isDirty: const Value(false),
        syncedAt: Value(syncedAt),
        updatedAt: Value(syncedAt),
        isDeleted: isDeleted != null ? Value(isDeleted) : const Value.absent(),
        status: status != null ? Value(status) : const Value.absent(),
        actorUserId: actorUserId != null
            ? Value(actorUserId)
            : const Value<int?>.absent(),
        loanId: loanId != null ? Value(loanId) : const Value<int?>.absent(),
        loanUuid:
            loanUuid != null ? Value(loanUuid) : const Value<String?>.absent(),
        sharedBookId: sharedBookId != null
            ? Value(sharedBookId)
            : const Value<int?>.absent(),
      ),
    );
  }

  Stream<List<InAppNotification>> watchForUser(int userId) {
    final query = select(inAppNotifications)
      ..where(
        (tbl) =>
            tbl.targetUserId.equals(userId) &
            (tbl.isDeleted.equals(false) | tbl.isDeleted.isNull()),
      )
      ..orderBy([
        (tbl) =>
            OrderingTerm(expression: tbl.createdAt, mode: OrderingMode.desc),
      ]);
    return query.watch();
  }

  Stream<int> watchUnreadCount(int userId) {
    final unreadQuery = select(inAppNotifications).join([])
      ..where(
        inAppNotifications.targetUserId.equals(userId) &
            inAppNotifications.status.equals('unread') &
            (inAppNotifications.isDeleted.equals(false) |
                inAppNotifications.isDeleted.isNull()),
      );
    return unreadQuery.watch().map((rows) => rows.length);
  }

  Future<int> countUnread(int userId) async {
    final countExp = inAppNotifications.id.count();
    final result = await (selectOnly(inAppNotifications)
          ..addColumns([countExp])
          ..where(
            inAppNotifications.targetUserId.equals(userId) &
                inAppNotifications.status.equals('unread') &
                (inAppNotifications.isDeleted.equals(false) |
                    inAppNotifications.isDeleted.isNull()),
          ))
        .getSingle();
    return result.read(countExp) ?? 0;
  }

  Future<void> markAllForLoan({
    required int loanId,
    required String status,
    required DateTime timestamp,
  }) {
    return (update(inAppNotifications)
          ..where((tbl) => tbl.loanId.equals(loanId)))
        .write(
      InAppNotificationsCompanion(
        status: Value(status),
        updatedAt: Value(timestamp),
        isDirty: const Value(true),
        syncedAt: const Value(null),
      ),
    );
  }

  Future<InAppNotification?> findRecentByType({
    required String type,
    required int loanId,
    required DateTime since,
  }) {
    return (select(inAppNotifications)
          ..where((tbl) =>
              tbl.type.equals(type) &
              tbl.loanId.equals(loanId) &
              tbl.createdAt.isBiggerOrEqualValue(since) &
              (tbl.isDeleted.equals(false) | tbl.isDeleted.isNull())))
        .getSingleOrNull();
  }
}

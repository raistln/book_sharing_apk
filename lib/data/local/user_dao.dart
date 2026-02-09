import 'package:drift/drift.dart';

import 'database.dart';

part 'user_dao.g.dart';

@DriftAccessor(tables: [LocalUsers])
class UserDao extends DatabaseAccessor<AppDatabase> with _$UserDaoMixin {
  UserDao(super.db);

  Stream<LocalUser?> watchActiveUser() {
    final query = (select(localUsers)
      ..where((tbl) => tbl.isDeleted.equals(false))
      ..limit(1));

    return query.watchSingleOrNull();
  }

  Future<LocalUser?> getActiveUser() {
    final query = (select(localUsers)
      ..where((tbl) => tbl.isDeleted.equals(false))
      ..limit(1));

    return query.getSingleOrNull();
  }

  Future<LocalUser?> getById(int id) {
    return (select(localUsers)..where((tbl) => tbl.id.equals(id)))
        .getSingleOrNull();
  }

  Future<int> insertUser(LocalUsersCompanion entry) =>
      into(localUsers).insert(entry);

  Future<LocalUser?> findByRemoteId(String remoteId) {
    return (select(localUsers)..where((tbl) => tbl.remoteId.equals(remoteId)))
        .getSingleOrNull();
  }

  Future<LocalUser?> findByUsername(String username) {
    return (select(localUsers)..where((tbl) => tbl.username.equals(username)))
        .getSingleOrNull();
  }

  Future<List<LocalUser>> getActiveUsers() {
    return (select(localUsers)..where((tbl) => tbl.isDeleted.equals(false)))
        .get();
  }

  Future<List<LocalUser>> getDirtyUsers() {
    return (select(localUsers)..where((tbl) => tbl.isDirty.equals(true))).get();
  }

  Future<int> updateUser(LocalUsersCompanion entry) {
    return (update(localUsers)..where((tbl) => tbl.id.equals(entry.id.value)))
        .write(entry);
  }

  Future<void> markAllDeleted({required DateTime timestamp}) {
    return (update(localUsers)..where((tbl) => tbl.isDeleted.equals(false)))
        .write(
      LocalUsersCompanion(
        isDeleted: const Value(true),
        updatedAt: Value(timestamp),
        isDirty: const Value(true),
      ),
    );
  }
}

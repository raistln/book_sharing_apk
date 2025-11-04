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
    return (select(localUsers)..where((tbl) => tbl.id.equals(id))).getSingleOrNull();
  }

  Future<int> insertUser(LocalUsersCompanion entry) => into(localUsers).insert(entry);

  Future<void> markAllDeleted({required DateTime timestamp}) {
    return (update(localUsers)..where((tbl) => tbl.isDeleted.equals(false))).write(
      LocalUsersCompanion(
        isDeleted: const Value(true),
        updatedAt: Value(timestamp),
        isDirty: const Value(true),
      ),
    );
  }
}

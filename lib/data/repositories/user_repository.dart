import 'package:uuid/uuid.dart';
import 'package:drift/drift.dart';

import '../local/user_dao.dart';
import '../local/database.dart';

class UserRepository {
  UserRepository(this._dao, {Uuid? uuid}) : _uuid = uuid ?? const Uuid();

  final UserDao _dao;
  final Uuid _uuid;

  Stream<LocalUser?> watchActiveUser() => _dao.watchActiveUser();

  Future<LocalUser?> getActiveUser() => _dao.getActiveUser();

  Future<LocalUser?> getById(int id) => _dao.getById(id);

  Future<List<LocalUser>> getActiveUsers() => _dao.getActiveUsers();

  Future<LocalUser> createUser({required String username}) async {
    final now = DateTime.now();
    return _dao.attachedDatabase.transaction(() async {
      final existing = await _dao.findByUsername(username);
      await _dao.markAllDeleted(timestamp: now);

      if (existing != null) {
        await _dao.updateUserFields(
          userId: existing.id,
          entry: LocalUsersCompanion(
            uuid: Value(existing.uuid),
            username: Value(username),
            remoteId: const Value<String?>(null),
            isDeleted: const Value(false),
            isDirty: const Value(true),
            syncedAt: const Value<DateTime?>(null),
            createdAt: Value(now),
            updatedAt: Value(now),
          ),
        );
        return (await _dao.getById(existing.id))!;
      }

      final userUuid = _uuid.v4();
      final id = await _dao.insertUser(
        LocalUsersCompanion.insert(
          uuid: userUuid,
          username: username,
          isDirty: const Value(true),
          isDeleted: const Value(false),
          createdAt: Value(now),
          updatedAt: Value(now),
        ),
      );
      return (await _dao.getById(id))!;
    });
  }
}

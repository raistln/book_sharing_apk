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
      await _dao.markAllDeleted(timestamp: now);
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

import 'package:uuid/uuid.dart';
import 'package:drift/drift.dart';

import '../local/user_dao.dart';
import '../local/database.dart';
import '../../services/supabase_user_service.dart';

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

  Future<void> updatePinData({
    required int userId,
    required String pinHash,
    required String pinSalt,
    required DateTime pinUpdatedAt,
    bool markDirty = false,
  }) async {
    await _dao.updateUserFields(
      userId: userId,
      entry: LocalUsersCompanion(
        pinHash: Value(pinHash),
        pinSalt: Value(pinSalt),
        pinUpdatedAt: Value(pinUpdatedAt),
        updatedAt: Value(pinUpdatedAt),
        isDirty:
            markDirty ? const Value(true) : const Value.absent(),
        syncedAt: markDirty ? const Value<DateTime?>(null) : const Value.absent(),
      ),
    );
  }

  Future<void> clearPinData({required int userId}) async {
    final now = DateTime.now();
    await _dao.updateUserFields(
      userId: userId,
      entry: LocalUsersCompanion(
        pinHash: const Value(null),
        pinSalt: const Value(null),
        pinUpdatedAt: const Value(null),
        updatedAt: Value(now),
        isDirty: const Value(true),
        syncedAt: const Value<DateTime?>(null),
      ),
    );
  }

  Future<LocalUser> importRemoteUser(SupabaseUserRecord record) async {
    final now = DateTime.now();
    final db = _dao.attachedDatabase;

    return db.transaction(() async {
      await _dao.markAllDeleted(timestamp: now);

      final existingByRemote = await _dao.findByRemoteId(record.id);
      final existing = existingByRemote ?? await _dao.findByUsername(record.username);

      if (existing != null) {
        await _dao.updateUserFields(
          userId: existing.id,
          entry: LocalUsersCompanion(
            remoteId: Value(record.id),
            username: Value(record.username),
            isDeleted: Value(record.isDeleted),
            isDirty: const Value(false),
            syncedAt: Value(now),
            updatedAt: Value(record.updatedAt ?? now),
            pinHash: Value(record.pinHash),
            pinSalt: Value(record.pinSalt),
            pinUpdatedAt: Value(record.pinUpdatedAt),
          ),
        );
        return (await _dao.getById(existing.id))!;
      }

      final createdAt = record.createdAt ?? now;
      final updatedAt = record.updatedAt ?? now;

      final id = await _dao.insertUser(
        LocalUsersCompanion.insert(
          uuid: record.id,
          username: record.username,
          remoteId: Value(record.id),
          isDirty: const Value(false),
          isDeleted: Value(record.isDeleted),
          createdAt: Value(createdAt),
          updatedAt: Value(updatedAt),
          syncedAt: Value(now),
          pinHash: Value(record.pinHash),
          pinSalt: Value(record.pinSalt),
          pinUpdatedAt: Value(record.pinUpdatedAt),
        ),
      );

      return (await _dao.getById(id))!;
    });
  }
}

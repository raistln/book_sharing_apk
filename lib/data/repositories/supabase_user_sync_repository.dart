import 'dart:developer' as developer;

import 'package:drift/drift.dart';

import '../local/user_dao.dart';
import '../local/database.dart';
import '../../services/supabase_user_service.dart';

class SupabaseUserSyncRepository {
  SupabaseUserSyncRepository({
    required UserDao userDao,
    required SupabaseUserService userService,
  })  : _userDao = userDao,
        _userService = userService;

  final UserDao _userDao;
  final SupabaseUserService _userService;

  Future<void> syncFromRemote({String? accessToken}) async {
    developer.log(
      'Descargando usuarios remotos desde Supabase.',
      name: 'SupabaseUserSyncRepository',
    );

    final remoteUsers = await _userService.fetchUsers(accessToken: accessToken);
    if (remoteUsers.isEmpty) {
      developer.log(
        'No se encontraron usuarios remotos en Supabase.',
        name: 'SupabaseUserSyncRepository',
      );
      return;
    }

    final db = _userDao.attachedDatabase;
    final now = DateTime.now();

    await db.transaction(() async {
      for (final remote in remoteUsers) {
        final existingById = await _userDao.findByRemoteId(remote.id);
        final existing = existingById ?? await _userDao.findByUsername(remote.username);

        if (existing != null) {
          if (existing.isDirty) {
            await _userDao.updateUserFields(
              userId: existing.id,
              entry: LocalUsersCompanion(
                remoteId: existing.remoteId == null
                    ? Value(remote.id)
                    : const Value<String?>.absent(),
                syncedAt: Value(now),
              ),
            );
            developer.log(
              'Se omite la actualización de ${existing.username} por cambios locales pendientes.',
              name: 'SupabaseUserSyncRepository',
            );
            continue;
          }

          await _userDao.updateUserFields(
            userId: existing.id,
            entry: LocalUsersCompanion(
              remoteId: Value(remote.id),
              username: Value(remote.username),
              isDeleted: Value(remote.isDeleted),
              isDirty: const Value(false),
              syncedAt: Value(now),
              updatedAt: Value(remote.updatedAt ?? now),
            ),
          );
          developer.log(
            'Usuario remoto ${remote.username} reconciliado con registro local (id: ${existing.id}).',
            name: 'SupabaseUserSyncRepository',
          );
        } else {
          await _userDao.insertUser(
            LocalUsersCompanion.insert(
              uuid: remote.id,
              username: remote.username,
              remoteId: Value(remote.id),
              isDeleted: Value(remote.isDeleted),
              isDirty: const Value(false),
              createdAt: Value(remote.createdAt ?? now),
              updatedAt: Value(remote.updatedAt ?? now),
              syncedAt: Value(now),
            ),
          );
          developer.log(
            'Usuario remoto ${remote.username} insertado localmente.',
            name: 'SupabaseUserSyncRepository',
          );
        }
      }
    });
  }

  Future<void> pushLocalChanges({String? accessToken}) async {
    final dirtyUsers = await _userDao.getDirtyUsers();
    if (dirtyUsers.isEmpty) {
      developer.log(
        'No hay usuarios sucios para sincronizar.',
        name: 'SupabaseUserSyncRepository',
      );
      return;
    }

    final syncTime = DateTime.now();
    developer.log(
      'Sincronizando ${dirtyUsers.length} usuario(s) local(es) con Supabase.',
      name: 'SupabaseUserSyncRepository',
    );

    for (final user in dirtyUsers) {
      final provisionalRemoteId = user.remoteId ?? user.uuid;

      try {
        var ensuredRemoteId = provisionalRemoteId;

        if (user.remoteId == null) {
          developer.log(
            'Creando usuario remoto para ${user.username} (uuid: ${user.uuid}).',
            name: 'SupabaseUserSyncRepository',
          );
          ensuredRemoteId = await _userService.createUser(
            id: provisionalRemoteId,
            username: user.username,
            isDeleted: user.isDeleted,
            createdAt: user.createdAt,
            updatedAt: user.updatedAt,
            accessToken: accessToken,
          );
          developer.log(
            'Usuario remoto creado con id $ensuredRemoteId.',
            name: 'SupabaseUserSyncRepository',
          );
        } else {
          developer.log(
            'Actualizando usuario remoto ${user.username} (remoteId: ${user.remoteId}).',
            name: 'SupabaseUserSyncRepository',
          );
          final updated = await _userService.updateUser(
            id: provisionalRemoteId,
            username: user.username,
            isDeleted: user.isDeleted,
            updatedAt: user.updatedAt,
            accessToken: accessToken,
          );

          if (!updated) {
            developer.log(
              'No se encontró usuario remoto, se crea de nuevo ${user.username}.',
              name: 'SupabaseUserSyncRepository',
            );
            ensuredRemoteId = await _userService.createUser(
              id: provisionalRemoteId,
              username: user.username,
              isDeleted: user.isDeleted,
              createdAt: user.createdAt,
              updatedAt: user.updatedAt,
              accessToken: accessToken,
            );
            developer.log(
              'Usuario recreado con id $ensuredRemoteId.',
              name: 'SupabaseUserSyncRepository',
            );
          }
        }

        await _userDao.updateUserFields(
          userId: user.id,
          entry: LocalUsersCompanion(
            remoteId: Value(ensuredRemoteId),
            isDirty: const Value(false),
            syncedAt: Value(syncTime),
          ),
        );
        developer.log(
          'Usuario ${user.username} sincronizado correctamente (remoteId: $ensuredRemoteId).',
          name: 'SupabaseUserSyncRepository',
        );
      } on SupabaseUserServiceException {
        rethrow;
      } catch (error) {
        developer.log(
          'Error sincronizando usuario ${user.username}: $error',
          name: 'SupabaseUserSyncRepository',
          level: 1000,
        );
        throw SupabaseUserSyncException(error.toString());
      }
    }
  }
}

class SupabaseUserSyncException implements Exception {
  SupabaseUserSyncException(this.message);

  final String message;

  @override
  String toString() => 'SupabaseUserSyncException: $message';
}

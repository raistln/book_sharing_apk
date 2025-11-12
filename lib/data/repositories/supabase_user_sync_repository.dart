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

  Future<void> pushLocalChanges({String? accessToken}) async {
    final dirtyUsers = await _userDao.getDirtyUsers();
    if (dirtyUsers.isEmpty) {
      return;
    }

    final syncTime = DateTime.now();

    for (final user in dirtyUsers) {
      final provisionalRemoteId = user.remoteId ?? user.uuid;

      try {
        var ensuredRemoteId = provisionalRemoteId;

        if (user.remoteId == null) {
          ensuredRemoteId = await _userService.createUser(
            id: provisionalRemoteId,
            username: user.username,
            isDeleted: user.isDeleted,
            createdAt: user.createdAt,
            updatedAt: user.updatedAt,
            accessToken: accessToken,
          );
        } else {
          final updated = await _userService.updateUser(
            id: provisionalRemoteId,
            username: user.username,
            isDeleted: user.isDeleted,
            updatedAt: user.updatedAt,
            accessToken: accessToken,
          );

          if (!updated) {
            ensuredRemoteId = await _userService.createUser(
              id: provisionalRemoteId,
              username: user.username,
              isDeleted: user.isDeleted,
              createdAt: user.createdAt,
              updatedAt: user.updatedAt,
              accessToken: accessToken,
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
      } on SupabaseUserServiceException {
        rethrow;
      } catch (error) {
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

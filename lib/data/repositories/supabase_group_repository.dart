import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';

import '../local/book_dao.dart';
import '../local/database.dart';
import '../local/group_dao.dart';
import '../local/user_dao.dart';
import '../../services/supabase_book_service.dart';
import '../../services/supabase_group_service.dart';

class SupabaseGroupSyncRepository {
  SupabaseGroupSyncRepository({
    required GroupDao groupDao,
    required UserDao userDao,
    required BookDao bookDao,
    SupabaseGroupService? groupService,
    SupabaseBookService? bookService,
  })  : _groupDao = groupDao,
        _bookDao = bookDao,
        _userDao = userDao,
        _groupService = groupService ?? SupabaseGroupService(),
        _bookService = bookService ?? SupabaseBookService();

  final GroupDao _groupDao;
  final BookDao _bookDao;
  final UserDao _userDao;
  final SupabaseGroupService _groupService;
  final SupabaseBookService _bookService;

  Future<void> syncFromRemote({String? accessToken}) async {
    final remoteGroups = await _groupService.fetchGroups(accessToken: accessToken);
    final db = _groupDao.attachedDatabase;
    final now = DateTime.now();

    if (kDebugMode) {
      debugPrint('[GroupSync] Received ${remoteGroups.length} groups from Supabase');
    }

    await db.transaction(() async {
      for (final remote in remoteGroups) {
        if (kDebugMode) {
          debugPrint(
            '[GroupSync] Processing group ${remote.id} — members=${remote.members.length}, shared=${remote.sharedBooks.length}',
          );
        }
        final existingGroup = await _groupDao.findGroupByRemoteId(remote.id);
        final ownerUser = remote.ownerId != null
            ? await _userDao.findByRemoteId(remote.ownerId!)
            : null;

        final ownerIdValue = ownerUser != null
            ? Value(ownerUser.id)
            : const Value<int>.absent();
        final ownerRemoteValue = remote.ownerId != null
            ? Value(remote.ownerId!)
            : const Value<String>.absent();

        int localGroupId;
        String localGroupUuid;

        if (existingGroup != null) {
          await _groupDao.updateGroupFields(
            groupId: existingGroup.id,
            entry: GroupsCompanion(
              name: Value(remote.name),
              ownerUserId: ownerIdValue,
              ownerRemoteId: ownerRemoteValue,
              isDeleted: const Value(false),
              isDirty: const Value(false),
              syncedAt: Value(now),
              updatedAt: Value(now),
            ),
          );
          localGroupId = existingGroup.id;
          localGroupUuid = existingGroup.uuid;
        } else {
          final insertCompanion = GroupsCompanion.insert(
            uuid: remote.id,
            remoteId: Value(remote.id),
            name: remote.name,
            ownerUserId: ownerIdValue,
            ownerRemoteId: ownerRemoteValue,
            isDeleted: const Value(false),
            isDirty: const Value(false),
            syncedAt: Value(now),
            createdAt: Value(remote.createdAt),
            updatedAt: Value(now),
          );
          localGroupId = await _groupDao.insertGroup(insertCompanion);
          localGroupUuid = remote.id;
        }

        for (final remoteMember in remote.members) {
          final localUser = await _ensureLocalUser(
            remoteId: remoteMember.userId,
            createdAtFallback: remoteMember.createdAt,
          );
          if (localUser == null) {
            if (kDebugMode) {
              debugPrint('[GroupSync] Skipping member ${remoteMember.id} — user ${remoteMember.userId} unavailable locally');
            }
            continue;
          }

          final existingMember =
              await _groupDao.findMemberByRemoteId(remoteMember.id) ??
              await _groupDao.findMember(groupId: localGroupId, userId: localUser.id);

          final memberRemoteValue = Value(remoteMember.userId);

          if (existingMember != null) {
            await _groupDao.updateMemberFields(
              memberId: existingMember.id,
              entry: GroupMembersCompanion(
                memberUserId: Value(localUser.id),
                memberRemoteId: memberRemoteValue,
                role: Value(remoteMember.role),
                isDeleted: const Value(false),
                isDirty: const Value(false),
                syncedAt: Value(now),
                updatedAt: Value(now),
              ),
            );
          } else {
            await _groupDao.insertMember(
              GroupMembersCompanion.insert(
                uuid: remoteMember.id,
                remoteId: Value(remoteMember.id),
                groupId: localGroupId,
                groupUuid: localGroupUuid,
                memberUserId: localUser.id,
                memberRemoteId: memberRemoteValue,
                role: Value(remoteMember.role),
                isDeleted: const Value(false),
                isDirty: const Value(false),
                syncedAt: Value(now),
                createdAt: Value(remoteMember.createdAt),
                updatedAt: Value(now),
              ),
            );
          }
        }

        final sharedRecords = remote.sharedBooks.isNotEmpty
            ? remote.sharedBooks
            : await _groupService.fetchSharedBooksForGroup(
                groupId: remote.id,
                accessToken: accessToken,
              );

        if (remote.sharedBooks.isEmpty && kDebugMode) {
          debugPrint(
            '[GroupSync] Fallback fetched ${sharedRecords.length} shared books for group ${remote.id}',
          );
        }

        for (final remoteShared in sharedRecords) {
          if (remoteShared.bookUuid == null) {
            if (kDebugMode) {
              debugPrint('[GroupSync] Shared book ${remoteShared.id} has null bookUuid, skipping');
            }
            continue;
          }

          var localBook = await _bookDao.findByUuid(remoteShared.bookUuid!);
          if (localBook == null) {
            SupabaseBookRecord? remoteBook;
            try {
              remoteBook = await _bookService.fetchBookById(
                id: remoteShared.bookUuid!,
                accessToken: accessToken,
              );
            } catch (error) {
              if (kDebugMode) {
                debugPrint(
                  '[GroupSync] Failed to fetch remote book ${remoteShared.bookUuid}: $error',
                );
              }
              remoteBook = null;
            }

            if (remoteBook != null) {
              final bookOwner = await _ensureLocalUser(
                remoteId: remoteBook.ownerId,
                createdAtFallback: remoteBook.createdAt,
              );
              final sharedOwnerUser = await _ensureLocalUser(
                remoteId: remoteShared.ownerId,
                createdAtFallback: remoteShared.createdAt,
              );
              final ownerUserIdValue = bookOwner?.id ?? sharedOwnerUser?.id;
              final ownerRemoteIdValue = bookOwner?.remoteId ?? remoteShared.ownerId;

              await _bookDao.insertBook(
                BooksCompanion.insert(
                  uuid: remoteBook.id,
                  remoteId: Value(remoteBook.id),
                  ownerUserId: ownerUserIdValue != null
                      ? Value(ownerUserIdValue)
                      : const Value<int?>.absent(),
                  ownerRemoteId: Value(ownerRemoteIdValue),
                  title: remoteBook.title,
                  author: Value(remoteBook.author),
                  isbn: Value(remoteBook.isbn),
                  barcode: Value(remoteBook.barcode),
                  coverPath: Value(remoteBook.coverUrl),
                  status: Value(remoteBook.status),
                  notes: Value(remoteBook.notes),
                  isDeleted: Value(remoteBook.isDeleted),
                  isDirty: const Value(false),
                  createdAt: Value(remoteBook.createdAt),
                  updatedAt: Value(remoteBook.updatedAt ?? remoteBook.createdAt),
                  syncedAt: Value(now),
                ),
              );

              localBook = await _bookDao.findByUuid(remoteShared.bookUuid!);
            } else if (kDebugMode) {
              debugPrint('[GroupSync] Remote book ${remoteShared.bookUuid} not found on Supabase');
            }

            if (localBook == null) {
              if (kDebugMode) {
                debugPrint('[GroupSync] Skipping shared book ${remoteShared.id} — missing local book ${remoteShared.bookUuid}');
              }
              continue;
            }
          }

          final sharedOwner = await _ensureLocalUser(
            remoteId: remoteShared.ownerId,
            createdAtFallback: remoteShared.createdAt,
          );
          if (sharedOwner == null) {
            if (kDebugMode) {
              debugPrint('[GroupSync] Skipping shared book ${remoteShared.id} — owner ${remoteShared.ownerId} unavailable locally');
            }
            continue;
          }

          final existingShared =
              await _groupDao.findSharedBookByRemoteId(remoteShared.id);

          final sharedOwnerValue = sharedOwner.id;
          final sharedOwnerRemoteValue = Value(remoteShared.ownerId);
          final sharedVisibilityValue = Value(remoteShared.visibility);
          final sharedAvailableValue = Value(remoteShared.isAvailable);
          final sharedUpdatedValue =
              Value(remoteShared.updatedAt ?? remoteShared.createdAt);

          int localSharedId;
          String localSharedUuid;

          if (existingShared != null) {
            await _groupDao.updateSharedBookFields(
              sharedBookId: existingShared.id,
              entry: SharedBooksCompanion(
                groupId: Value(localGroupId),
                groupUuid: Value(localGroupUuid),
                bookId: Value(localBook.id),
                bookUuid: Value(localBook.uuid),
                ownerUserId: Value(sharedOwnerValue),
                ownerRemoteId: sharedOwnerRemoteValue,
                visibility: sharedVisibilityValue,
                isAvailable: sharedAvailableValue,
                isDeleted: const Value(false),
                isDirty: const Value(false),
                syncedAt: Value(now),
                updatedAt: sharedUpdatedValue,
              ),
            );
            localSharedId = existingShared.id;
            localSharedUuid = existingShared.uuid;
            if (kDebugMode) {
              debugPrint('[GroupSync] Updated shared book ${remoteShared.id} for group $localGroupUuid');
            }
          } else {
            final insertShared = SharedBooksCompanion.insert(
              uuid: remoteShared.id,
              remoteId: Value(remoteShared.id),
              groupId: localGroupId,
              groupUuid: localGroupUuid,
              bookId: localBook.id,
              bookUuid: localBook.uuid,
              ownerUserId: sharedOwnerValue,
              ownerRemoteId: sharedOwnerRemoteValue,
              visibility: sharedVisibilityValue,
              isAvailable: sharedAvailableValue,
              isDeleted: const Value(false),
              isDirty: const Value(false),
              syncedAt: Value(now),
              createdAt: Value(remoteShared.createdAt),
              updatedAt: sharedUpdatedValue,
            );
            localSharedId = await _groupDao.insertSharedBook(insertShared);
            localSharedUuid = remoteShared.id;
            if (kDebugMode) {
              debugPrint('[GroupSync] Inserted shared book ${remoteShared.id} for group $localGroupUuid');
            }
          }

          for (final remoteLoan in remoteShared.loans) {
            final fromUser = await _userDao.findByRemoteId(remoteLoan.fromUser);
            final toUser = await _userDao.findByRemoteId(remoteLoan.toUser);

            if (fromUser == null || toUser == null) {
              if (kDebugMode) {
                debugPrint('[GroupSync] Skipping loan ${remoteLoan.id} — from=${remoteLoan.fromUser} to=${remoteLoan.toUser} missing locally');
              }
              continue;
            }

            final existingLoan =
                await _groupDao.findLoanByRemoteId(remoteLoan.id);

            final dueDateValue = remoteLoan.dueDate != null
                ? Value(remoteLoan.dueDate)
                : const Value<DateTime?>.absent();
            final returnedAtValue = remoteLoan.returnedAt != null
                ? Value(remoteLoan.returnedAt)
                : const Value<DateTime?>.absent();
            final cancelledAtValue = remoteLoan.cancelledAt != null
                ? Value(remoteLoan.cancelledAt)
                : const Value<DateTime?>.absent();
            final loanUpdatedValue =
                Value(remoteLoan.updatedAt ?? remoteLoan.createdAt);

            final baseLoan = LoansCompanion(
              sharedBookId: Value(localSharedId),
              sharedBookUuid: Value(localSharedUuid),
              fromUserId: Value(fromUser.id),
              fromRemoteId: Value(remoteLoan.fromUser),
              toUserId: Value(toUser.id),
              toRemoteId: Value(remoteLoan.toUser),
              status: Value(remoteLoan.status),
              startDate: Value(remoteLoan.startDate),
              dueDate: dueDateValue,
              returnedAt: returnedAtValue,
              cancelledAt: cancelledAtValue,
              isDeleted: const Value(false),
              isDirty: const Value(false),
              syncedAt: Value(now),
              updatedAt: loanUpdatedValue,
            );

            if (existingLoan != null) {
              await _groupDao.updateLoanFields(
                loanId: existingLoan.id,
                entry: baseLoan,
              );
            } else {
              await _groupDao.insertLoan(
                LoansCompanion.insert(
                  uuid: remoteLoan.id,
                  remoteId: Value(remoteLoan.id),
                  sharedBookId: localSharedId,
                  sharedBookUuid: localSharedUuid,
                  fromUserId: fromUser.id,
                  fromRemoteId: Value(remoteLoan.fromUser),
                  toUserId: toUser.id,
                  toRemoteId: Value(remoteLoan.toUser),
                  status: Value(remoteLoan.status),
                  startDate: Value(remoteLoan.startDate),
                  dueDate: dueDateValue,
                  returnedAt: returnedAtValue,
                  cancelledAt: cancelledAtValue,
                  isDeleted: const Value(false),
                  isDirty: const Value(false),
                  syncedAt: Value(now),
                  createdAt: Value(remoteLoan.createdAt),
                  updatedAt: loanUpdatedValue,
                ),
              );
            }
          }
        }
      }
    });
  }

  Future<void> pushLocalChanges({String? accessToken}) async {
    final dirtySharedBooks = await _groupDao.getDirtySharedBooks();
    if (dirtySharedBooks.isEmpty) {
      if (kDebugMode) {
        debugPrint('[GroupSync] No shared_books pending upload.');
      }
      return;
    }

    final syncTime = DateTime.now();
    if (kDebugMode) {
      debugPrint('[GroupSync] Uploading ${dirtySharedBooks.length} shared book(s) to Supabase');
    }

    for (final shared in dirtySharedBooks) {
      if (shared.isDeleted) {
        final remoteId = shared.remoteId;

        if (remoteId != null && remoteId.isNotEmpty) {
          try {
            await _groupService.deleteSharedBook(
              id: remoteId,
              updatedAt: shared.updatedAt,
              accessToken: accessToken,
            );
          } catch (error) {
            if (kDebugMode) {
              debugPrint('[GroupSync] Failed to delete shared book ${shared.uuid} remotely: $error');
            }
            rethrow;
          }
        }

        await _groupDao.updateSharedBookFields(
          sharedBookId: shared.id,
          entry: SharedBooksCompanion(
            isDirty: const Value(false),
            syncedAt: Value(syncTime),
          ),
        );
        continue;
      }

      final group = await _groupDao.findGroupById(shared.groupId);
      if (group == null) {
        if (kDebugMode) {
          debugPrint('[GroupSync] Skipping shared book ${shared.uuid}: group ${shared.groupId} missing locally');
        }
        continue;
      }

      final groupRemoteId = group.remoteId;
      if (groupRemoteId == null || groupRemoteId.isEmpty) {
        if (kDebugMode) {
          debugPrint('[GroupSync] Skipping shared book ${shared.uuid}: group ${group.id} lacks remoteId');
        }
        continue;
      }

      final owner = await _userDao.getById(shared.ownerUserId);
      final ownerRemoteId = (shared.ownerRemoteId != null && shared.ownerRemoteId!.isNotEmpty)
          ? shared.ownerRemoteId!
          : owner?.remoteId;
      if (ownerRemoteId == null || ownerRemoteId.isEmpty) {
        if (kDebugMode) {
          debugPrint('[GroupSync] Skipping shared book ${shared.uuid}: owner ${shared.ownerUserId} lacks remoteId');
        }
        continue;
      }

      final book = await _bookDao.findById(shared.bookId);
      final remoteBookId = book?.remoteId ?? shared.bookUuid;
      if (remoteBookId.isEmpty) {
        if (kDebugMode) {
          debugPrint('[GroupSync] Skipping shared book ${shared.uuid}: book ${shared.bookId} lacks remoteId');
        }
        continue;
      }

      final provisionalRemoteId = shared.remoteId ?? shared.uuid;

      try {
        var ensuredRemoteId = provisionalRemoteId;

        if (shared.remoteId == null) {
          ensuredRemoteId = await _groupService.createSharedBook(
            id: provisionalRemoteId,
            groupId: groupRemoteId,
            bookUuid: remoteBookId,
            ownerId: ownerRemoteId,
            visibility: shared.visibility,
            isAvailable: shared.isAvailable,
            isDeleted: shared.isDeleted,
            createdAt: shared.createdAt,
            updatedAt: shared.updatedAt,
            accessToken: accessToken,
          );
          if (kDebugMode) {
            debugPrint('[GroupSync] Created remote shared book ${shared.uuid} -> $ensuredRemoteId');
          }
        } else {
          final updated = await _groupService.updateSharedBook(
            id: provisionalRemoteId,
            groupId: groupRemoteId,
            bookUuid: remoteBookId,
            ownerId: ownerRemoteId,
            visibility: shared.visibility,
            isAvailable: shared.isAvailable,
            isDeleted: shared.isDeleted,
            updatedAt: shared.updatedAt,
            accessToken: accessToken,
          );

          if (!updated) {
            ensuredRemoteId = await _groupService.createSharedBook(
              id: provisionalRemoteId,
              groupId: groupRemoteId,
              bookUuid: remoteBookId,
              ownerId: ownerRemoteId,
              visibility: shared.visibility,
              isAvailable: shared.isAvailable,
              isDeleted: shared.isDeleted,
              createdAt: shared.createdAt,
              updatedAt: shared.updatedAt,
              accessToken: accessToken,
            );
            if (kDebugMode) {
              debugPrint('[GroupSync] Remote shared book ${shared.uuid} missing, recreated as $ensuredRemoteId');
            }
          }
        }

        await _groupDao.updateSharedBookFields(
          sharedBookId: shared.id,
          entry: SharedBooksCompanion(
            remoteId: Value(ensuredRemoteId),
            ownerRemoteId: Value(ownerRemoteId),
            isDirty: const Value(false),
            syncedAt: Value(syncTime),
          ),
        );
      } catch (error) {
        if (kDebugMode) {
          debugPrint('[GroupSync] Failed to push shared book ${shared.uuid}: $error');
        }
        rethrow;
      }
    }
  }

  Future<LocalUser?> _ensureLocalUser({
    required String remoteId,
    required DateTime createdAtFallback,
  }) async {
    var localUser = await _userDao.findByRemoteId(remoteId);
    if (localUser != null) {
      return localUser;
    }

    final sanitizedId = remoteId.replaceAll(RegExp('[^a-zA-Z0-9]'), '');
    final suffix = sanitizedId.isNotEmpty
        ? (sanitizedId.length >= 8 ? sanitizedId.substring(0, 8) : sanitizedId.padRight(8, '0'))
        : '00000000';
    final placeholderUsername = 'miembro_$suffix';
    final now = DateTime.now();

    try {
      final userId = await _userDao.insertUser(
        LocalUsersCompanion.insert(
          uuid: remoteId,
          username: placeholderUsername,
          remoteId: Value(remoteId),
          isDeleted: const Value(false),
          isDirty: const Value(false),
          createdAt: Value(createdAtFallback),
          updatedAt: Value(now),
          syncedAt: Value(now),
        ),
      );
      localUser = await _userDao.getById(userId);
    } catch (_) {
      localUser = await _userDao.findByRemoteId(remoteId);
    }

    return localUser;
  }
}

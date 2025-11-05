import 'package:drift/drift.dart';

import '../local/book_dao.dart';
import '../local/database.dart';
import '../local/group_dao.dart';
import '../local/user_dao.dart';
import '../../services/supabase_group_service.dart';

class SupabaseGroupSyncRepository {
  SupabaseGroupSyncRepository({
    required GroupDao groupDao,
    required UserDao userDao,
    required BookDao bookDao,
    SupabaseGroupService? groupService,
  })  : _groupDao = groupDao,
        _bookDao = bookDao,
        _userDao = userDao,
        _groupService = groupService ?? SupabaseGroupService();

  final GroupDao _groupDao;
  final BookDao _bookDao;
  final UserDao _userDao;
  final SupabaseGroupService _groupService;

  Future<void> syncFromRemote({String? accessToken}) async {
    final remoteGroups = await _groupService.fetchGroups(accessToken: accessToken);
    final db = _groupDao.attachedDatabase;
    final now = DateTime.now();

    await db.transaction(() async {
      for (final remote in remoteGroups) {
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
          final localUser = await _userDao.findByRemoteId(remoteMember.userId);
          if (localUser == null) {
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

        for (final remoteShared in remote.sharedBooks) {
          if (remoteShared.bookUuid == null) {
            continue;
          }

          final localBook = await _bookDao.findByUuid(remoteShared.bookUuid!);
          if (localBook == null) {
            continue;
          }

          final sharedOwner = await _userDao.findByRemoteId(remoteShared.ownerId);
          if (sharedOwner == null) {
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
          }

          for (final remoteLoan in remoteShared.loans) {
            final fromUser = await _userDao.findByRemoteId(remoteLoan.fromUser);
            final toUser = await _userDao.findByRemoteId(remoteLoan.toUser);

            if (fromUser == null || toUser == null) {
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
}

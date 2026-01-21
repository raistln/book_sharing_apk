import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';

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
    final remoteGroups =
        await _groupService.fetchGroups(accessToken: accessToken);
    final db = _groupDao.attachedDatabase;
    final now = DateTime.now();

    if (kDebugMode) {
      debugPrint(
          '[GroupSync] Received ${remoteGroups.length} groups from Supabase');
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

        final ownerIdValue =
            ownerUser != null ? Value(ownerUser.id) : const Value<int>.absent();
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
            username: remoteMember.username,
            createdAtFallback: remoteMember.createdAt,
          );
          if (localUser == null) {
            if (kDebugMode) {
              debugPrint(
                  '[GroupSync] Skipping member ${remoteMember.id} — user ${remoteMember.userId} unavailable locally');
            }
            continue;
          }

          final existingMember =
              await _groupDao.findMemberByRemoteId(remoteMember.id) ??
                  await _groupDao.findMemberIncludingDeleted(
                      groupId: localGroupId, userId: localUser.id);

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
          // CHECK FOR DELETION (Hard Delete Strategy)
          if (remoteShared.isDeleted) {
            final existingShared =
                await _groupDao.findSharedBookByRemoteId(remoteShared.id);
            if (existingShared != null) {
              if (kDebugMode) {
                debugPrint(
                    '[GroupSync] HARD DELETING shared book ${remoteShared.id} (remote isDeleted=true)');
              }
              await _groupDao.deleteSharedBook(existingShared.id);
            }
            continue;
          }

          if (remoteShared.bookUuid == null) {
            if (kDebugMode) {
              debugPrint(
                  '[GroupSync] Shared book ${remoteShared.id} has null bookUuid, skipping');
            }
            continue;
          }

          var localBook = await _bookDao.findByUuid(remoteShared.bookUuid!);

          // Also check by remoteId to prevent duplicates
          localBook ??= await _bookDao.findByRemoteId(remoteShared.bookUuid!);

          if (localBook == null) {
            // Create book from shared_books data directly
            if (kDebugMode) {
              debugPrint(
                  '[GroupSync] Creating local book from shared_books data: ${remoteShared.title}');
            }

            final sharedOwnerUser = await _ensureLocalUser(
              remoteId: remoteShared.ownerId,
              createdAtFallback: remoteShared.createdAt,
            );

            if (sharedOwnerUser != null) {
              // Triple-check for duplicates before inserting:
              // 1. By UUID (already checked above)
              // 2. By remoteId (already checked above)
              // 3. By title + author + ISBN combination to catch any edge cases
              var existingByContent = await _bookDao.findByTitleAndAuthor(
                remoteShared.title,
                remoteShared.author ?? '',
                ownerUserId: sharedOwnerUser.id,
              );

              // If found by title+author, also verify ISBN matches if both have ISBN
              if (existingByContent != null &&
                  remoteShared.isbn != null &&
                  existingByContent.isbn != null) {
                if (existingByContent.isbn != remoteShared.isbn) {
                  // Different ISBN, might be different edition - allow as separate book
                  existingByContent = null;
                }
              }

              // Final check by UUID
              final finalCheck =
                  await _bookDao.findByUuid(remoteShared.bookUuid!);

              if (finalCheck == null && existingByContent == null) {
                await _bookDao.insertBook(
                  BooksCompanion.insert(
                    uuid: remoteShared.bookUuid!,
                    remoteId: Value(remoteShared.bookUuid!),
                    ownerUserId: Value(sharedOwnerUser.id),
                    ownerRemoteId: Value(remoteShared.ownerId),
                    title: remoteShared.title,
                    author: (remoteShared.author != null &&
                            remoteShared.author!.trim().isNotEmpty)
                        ? Value(remoteShared.author!.trim())
                        : const Value.absent(),
                    isbn: (remoteShared.isbn != null &&
                            remoteShared.isbn!.trim().isNotEmpty)
                        ? Value(remoteShared.isbn!.trim())
                        : const Value.absent(),
                    coverPath: Value(remoteShared.coverUrl),
                    status: Value(
                        remoteShared.isAvailable ? 'available' : 'loaned'),
                    description: const Value(null),
                    isDeleted: const Value(false),
                    isDirty: const Value(false),
                    createdAt: Value(remoteShared.createdAt),
                    updatedAt:
                        Value(remoteShared.updatedAt ?? remoteShared.createdAt),
                    syncedAt: Value(now),
                    pageCount: Value(remoteShared.pageCount),
                    publicationYear: Value(remoteShared.publicationYear),
                  ),
                );
                if (kDebugMode) {
                  debugPrint(
                      '[GroupSync] Created book ${remoteShared.bookUuid} from shared_books data (${remoteShared.title})');
                }
              } else if (finalCheck != null) {
                if (kDebugMode) {
                  debugPrint(
                      '[GroupSync] Book ${remoteShared.bookUuid} already exists, reusing');
                }
                localBook = finalCheck;
              } else if (existingByContent != null) {
                if (kDebugMode) {
                  debugPrint(
                      '[GroupSync] Book "${remoteShared.title}" already exists locally as ID ${existingByContent.id}, reusing');
                }
                localBook = existingByContent;
                // Update remoteId if missing
                if (existingByContent.remoteId == null ||
                    existingByContent.remoteId!.isEmpty) {
                  await _bookDao.updateBookFields(
                    bookId: existingByContent.id,
                    entry: BooksCompanion(
                      remoteId: Value(remoteShared.bookUuid!),
                      syncedAt: Value(now),
                    ),
                  );
                }
              }

              // Fetch the book one more time to ensure we have the correct reference
              localBook ??= await _bookDao.findByUuid(remoteShared.bookUuid!);
            }

            if (localBook == null) {
              if (kDebugMode) {
                debugPrint(
                    '[GroupSync] Skipping shared book ${remoteShared.id} — could not create local book ${remoteShared.bookUuid}');
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
              debugPrint(
                  '[GroupSync] Skipping shared book ${remoteShared.id} — owner ${remoteShared.ownerId} unavailable locally');
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

          if (existingShared != null) {
            // CRITICAL FIX: If local version is dirty, DO NOT overwrite with remote
            if (existingShared.isDirty) {
              if (kDebugMode) {
                debugPrint(
                    '[GroupSync] Skipping update for shared book ${existingShared.id} (local isDirty=true)');
              }
              // Skip update to preserve local availability changes
            } else {
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
                  isDeleted: Value(remoteShared.isDeleted),
                  genre: Value(remoteShared.genre),
                  isDirty: const Value(false),
                  syncedAt: Value(now),
                  updatedAt: sharedUpdatedValue,
                ),
              );
              if (kDebugMode) {
                debugPrint(
                    '[GroupSync] Updated shared book ${remoteShared.id} for group $localGroupUuid');
              }
            }
            localSharedId = existingShared.id;
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
              isDeleted: Value(remoteShared.isDeleted),
              genre: Value(remoteShared.genre),
              isDirty: const Value(false),
              syncedAt: Value(now),
              createdAt: Value(remoteShared.createdAt),
              updatedAt: sharedUpdatedValue,
            );
            localSharedId = await _groupDao.insertSharedBook(insertShared);
            if (kDebugMode) {
              debugPrint(
                  '[GroupSync] Inserted shared book ${remoteShared.id} for group $localGroupUuid');
            }
          }

          for (final remoteLoan in remoteShared.loans) {
            // Handle manual loans (external borrowers without accounts)
            final isManualLoan = remoteLoan.borrowerUserId.isEmpty;

            final lender =
                await _userDao.findByRemoteId(remoteLoan.lenderUserId);
            if (lender == null) {
              if (kDebugMode) {
                debugPrint(
                    '[GroupSync] Skipping loan ${remoteLoan.id} — lender=${remoteLoan.lenderUserId} missing locally');
              }
              continue;
            }

            // For non-manual loans, find the borrower
            LocalUser? borrower;
            if (!isManualLoan) {
              borrower = await _ensureLocalUser(
                remoteId: remoteLoan.borrowerUserId,
                username: remoteLoan.borrowerUsername,
                createdAtFallback: remoteLoan.createdAt,
              );
              if (borrower == null) {
                if (kDebugMode) {
                  debugPrint(
                      '[GroupSync] Skipping loan ${remoteLoan.id} — borrower=${remoteLoan.borrowerUserId} missing locally');
                }
                continue;
              }
            }

            // Ensure lender exists locally (and update username if available)
            await _ensureLocalUser(
              remoteId: remoteLoan.lenderUserId,
              username: remoteLoan.lenderUsername,
              createdAtFallback: remoteLoan.createdAt,
            );

            final existingLoan =
                await _groupDao.findLoanByRemoteId(remoteLoan.id);

            final dueDateValue = remoteLoan.dueDate != null
                ? Value(remoteLoan.dueDate)
                : const Value<DateTime?>.absent();
            final returnedAtValue = remoteLoan.returnedAt != null
                ? Value(remoteLoan.returnedAt)
                : const Value<DateTime?>.absent();
            final approvedAtValue = remoteLoan.approvedAt != null
                ? Value(remoteLoan.approvedAt)
                : const Value<DateTime?>.absent();
            final borrowerReturnedAtValue =
                remoteLoan.borrowerReturnedAt != null
                    ? Value(remoteLoan.borrowerReturnedAt)
                    : const Value<DateTime?>.absent();
            final lenderReturnedAtValue = remoteLoan.lenderReturnedAt != null
                ? Value(remoteLoan.lenderReturnedAt)
                : const Value<DateTime?>.absent();

            final loanUpdatedValue =
                Value(remoteLoan.updatedAt ?? remoteLoan.createdAt);

            // For manual loans, borrowerUserId is null
            final borrowerIdValue =
                isManualLoan ? const Value<int?>(null) : Value(borrower!.id);

            final baseLoan = LoansCompanion(
              sharedBookId: Value(localSharedId),
              borrowerUserId: borrowerIdValue,
              lenderUserId: Value(lender.id),
              status: Value(remoteLoan.status),
              requestedAt: Value(remoteLoan.requestedAt),
              approvedAt: approvedAtValue,
              dueDate: dueDateValue,
              borrowerReturnedAt: borrowerReturnedAtValue,
              lenderReturnedAt: lenderReturnedAtValue,
              returnedAt: returnedAtValue,
              // Note: externalBorrowerName/Contact not available in SupabaseLoanRecord
              // These fields will be set when the loan is created locally
              isDeleted: const Value(false),
              isDirty: const Value(false),
              syncedAt: Value(now),
              updatedAt: loanUpdatedValue,
            );

            if (existingLoan != null) {
              if (existingLoan.isDirty) {
                if (kDebugMode) {
                  debugPrint(
                      '[GroupSync] Skipping update for DIRTY local loan ${existingLoan.uuid}');
                }
                continue;
              }
              await _groupDao.updateLoanFields(
                loanId: existingLoan.id,
                entry: baseLoan,
              );
            } else {
              await _groupDao.insertLoan(
                LoansCompanion.insert(
                  uuid: remoteLoan.id,
                  remoteId: Value(remoteLoan.id),
                  sharedBookId: Value(localSharedId),
                  borrowerUserId: borrowerIdValue,
                  lenderUserId: lender.id,
                  status: Value(remoteLoan.status),
                  requestedAt: Value(remoteLoan.requestedAt),
                  approvedAt: approvedAtValue,
                  dueDate: dueDateValue,
                  borrowerReturnedAt: borrowerReturnedAtValue,
                  lenderReturnedAt: lenderReturnedAtValue,
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

        // RECONCILIATION: Pruning orphans (Must be inside group loop)
        // Only deletes items that are synced (remoteId!=null) but missing from current remote list
        final remoteSharedIds = sharedRecords.map((r) => r.id).toSet();
        final localSharedBooks =
            await _groupDao.findSharedBooksByGroupId(localGroupId);

        for (final local in localSharedBooks) {
          if (local.remoteId != null &&
              local.remoteId!.isNotEmpty &&
              !remoteSharedIds.contains(local.remoteId) &&
              !local.isDirty) {
            if (kDebugMode) {
              debugPrint(
                '[GroupSync] RECONCILIATION: Pruning orphan shared book ${local.id} (remoteId ${local.remoteId} missing from server)',
              );
            }
            await _groupDao.deleteSharedBook(local.id);
          }
        }
      }
    });
  }

  Future<void> pushLocalChanges({String? accessToken}) async {
    final dirtySharedBooks = await _groupDao.getDirtySharedBooks();
    if (kDebugMode) {
      debugPrint(
          '[GroupSync] Found ${dirtySharedBooks.length} dirty shared books');
    }
    if (dirtySharedBooks.isNotEmpty) {
      final syncTime = DateTime.now();
      if (kDebugMode) {
        debugPrint(
            '[GroupSync] Uploading ${dirtySharedBooks.length} shared book(s) to Supabase');
        for (final s in dirtySharedBooks) {
          debugPrint(
              '[GroupSync] -> Dirty SharedBook: ${s.uuid}, isAvailable: ${s.isAvailable}, isDirty: ${s.isDirty}');
        }
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
                debugPrint(
                    '[GroupSync] Failed to delete shared book ${shared.uuid} remotely: $error');
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
            debugPrint(
                '[GroupSync] Skipping shared book ${shared.uuid}: group ${shared.groupId} missing locally');
          }
          continue;
        }

        final groupRemoteId = group.remoteId;
        if (groupRemoteId == null || groupRemoteId.isEmpty) {
          if (kDebugMode) {
            debugPrint(
                '[GroupSync] Skipping shared book ${shared.uuid}: group ${group.id} lacks remoteId');
          }
          continue;
        }

        final owner = await _userDao.getById(shared.ownerUserId);
        final ownerRemoteId =
            (shared.ownerRemoteId != null && shared.ownerRemoteId!.isNotEmpty)
                ? shared.ownerRemoteId!
                : owner?.remoteId;
        if (ownerRemoteId == null || ownerRemoteId.isEmpty) {
          if (kDebugMode) {
            debugPrint(
                '[GroupSync] Skipping shared book ${shared.uuid}: owner ${shared.ownerUserId} lacks remoteId');
          }
          continue;
        }

        final book = await _bookDao.findById(shared.bookId);
        final remoteBookId = book?.remoteId ?? shared.bookUuid;
        if (remoteBookId.isEmpty) {
          if (kDebugMode) {
            debugPrint(
                '[GroupSync] Skipping shared book ${shared.uuid}: book ${shared.bookId} lacks remoteId');
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
              title: book?.title ?? '',
              author: book?.author,
              isbn: book?.isbn,
              coverUrl: book?.coverPath,
              visibility: shared.visibility,
              isAvailable: shared.isAvailable,
              isDeleted: shared.isDeleted,
              genre: book?.genre ?? shared.genre,
              pageCount: book?.pageCount,
              publicationYear: book?.publicationYear,
              createdAt: shared.createdAt,
              updatedAt: shared.updatedAt,
              accessToken: accessToken,
            );
            if (kDebugMode) {
              debugPrint(
                  '[GroupSync] Created remote shared book ${shared.uuid} -> $ensuredRemoteId (isAvailable: ${shared.isAvailable})');
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
              genre: book?.genre ?? shared.genre,
              pageCount: book?.pageCount,
              publicationYear: book?.publicationYear,
              updatedAt: shared.updatedAt,
              accessToken: accessToken,
            );

            if (!updated) {
              ensuredRemoteId = await _groupService.createSharedBook(
                id: provisionalRemoteId,
                groupId: groupRemoteId,
                bookUuid: remoteBookId,
                ownerId: ownerRemoteId,
                title: book?.title ?? '',
                author: book?.author,
                isbn: book?.isbn,
                coverUrl: book?.coverPath,
                visibility: shared.visibility,
                isAvailable: shared.isAvailable,
                isDeleted: shared.isDeleted,
                genre: book?.genre ?? shared.genre,
                pageCount: book?.pageCount,
                publicationYear: book?.publicationYear,
                createdAt: shared.createdAt,
                updatedAt: shared.updatedAt,
                accessToken: accessToken,
              );
              if (kDebugMode) {
                debugPrint(
                    '[GroupSync] Remote shared book ${shared.uuid} missing, recreated as $ensuredRemoteId');
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
            debugPrint(
                '[GroupSync] Failed to push shared book ${shared.uuid}: $error');
          }
          rethrow;
        }
      }
    }

    final dirtyLoans = await _groupDao.getDirtyLoans();
    if (kDebugMode) {
      debugPrint('[GroupSync] Found ${dirtyLoans.length} dirty loans');
    }
    if (dirtyLoans.isNotEmpty) {
      final syncTime = DateTime.now();
      if (kDebugMode) {
        debugPrint(
            '[GroupSync] Uploading ${dirtyLoans.length} loan(s) to Supabase');
      }

      for (final loan in dirtyLoans) {
        try {
          final sharedBook =
              await _groupDao.findSharedBookById(loan.sharedBookId!);
          if (sharedBook == null || sharedBook.remoteId == null) {
            if (kDebugMode) {
              debugPrint(
                  '[GroupSync] Skipping loan ${loan.uuid}: shared book ${loan.sharedBookId} missing remoteId (book found: ${sharedBook != null})');
            }
            continue;
          }

          final lender = await _userDao.getById(loan.lenderUserId);
          if (lender == null || lender.remoteId == null) {
            if (kDebugMode) {
              debugPrint(
                  '[GroupSync] Skipping loan ${loan.uuid}: lender ${loan.lenderUserId} missing remoteId (lender found: ${lender != null})');
            }
            continue;
          }

          String? borrowerRemoteId;
          if (loan.borrowerUserId != null) {
            final borrower = await _userDao.getById(loan.borrowerUserId!);
            if (borrower == null || borrower.remoteId == null) {
              if (kDebugMode) {
                debugPrint(
                    '[GroupSync] Skipping loan ${loan.uuid}: borrower ${loan.borrowerUserId} missing remoteId');
              }
              continue;
            }
            borrowerRemoteId = borrower.remoteId;
          }

          final provisionalRemoteId = loan.remoteId ?? loan.uuid;
          var ensuredRemoteId = provisionalRemoteId;

          if (kDebugMode) {
            debugPrint(
                '[GroupSync] Syncing loan ${loan.uuid} (manual: ${loan.externalBorrowerName != null})');
          }

          if (loan.remoteId == null) {
            ensuredRemoteId = await _groupService.createLoan(
              id: provisionalRemoteId,
              sharedBookId: sharedBook.remoteId!,
              borrowerUserId: borrowerRemoteId,
              lenderUserId: lender.remoteId!,
              externalBorrowerName: loan.externalBorrowerName,
              externalBorrowerContact: loan.externalBorrowerContact,
              status: loan.status,
              requestedAt: loan.requestedAt,
              approvedAt: loan.approvedAt,
              dueDate: loan.dueDate,
              borrowerReturnedAt: loan.borrowerReturnedAt,
              lenderReturnedAt: loan.lenderReturnedAt,
              returnedAt: loan.returnedAt,
              isDeleted: loan.isDeleted,
              createdAt: loan.createdAt,
              updatedAt: loan.updatedAt,
              accessToken: accessToken,
            );
            if (kDebugMode) {
              debugPrint(
                  '[GroupSync] Created remote loan ${loan.uuid} -> $ensuredRemoteId');
            }
          } else {
            final updated = await _groupService.updateLoan(
              id: provisionalRemoteId,
              status: loan.status,
              approvedAt: loan.approvedAt,
              dueDate: loan.dueDate,
              borrowerReturnedAt: loan.borrowerReturnedAt,
              lenderReturnedAt: loan.lenderReturnedAt,
              returnedAt: loan.returnedAt,
              isDeleted: loan.isDeleted,
              updatedAt: loan.updatedAt,
              accessToken: accessToken,
            );

            if (!updated) {
              ensuredRemoteId = await _groupService.createLoan(
                id: provisionalRemoteId,
                sharedBookId: sharedBook.remoteId!,
                borrowerUserId: borrowerRemoteId,
                lenderUserId: lender.remoteId!,
                externalBorrowerName: loan.externalBorrowerName,
                externalBorrowerContact: loan.externalBorrowerContact,
                status: loan.status,
                requestedAt: loan.requestedAt,
                approvedAt: loan.approvedAt,
                dueDate: loan.dueDate,
                borrowerReturnedAt: loan.borrowerReturnedAt,
                lenderReturnedAt: loan.lenderReturnedAt,
                returnedAt: loan.returnedAt,
                isDeleted: loan.isDeleted,
                createdAt: loan.createdAt,
                updatedAt: loan.updatedAt,
                accessToken: accessToken,
              );
              if (kDebugMode) {
                debugPrint(
                    '[GroupSync] Remote loan ${loan.uuid} missing, recreated as $ensuredRemoteId');
              }
            }
          }

          await _groupDao.updateLoanFields(
            loanId: loan.id,
            entry: LoansCompanion(
              remoteId: Value(ensuredRemoteId),
              isDirty: const Value(false),
              syncedAt: Value(syncTime),
            ),
          );
        } catch (error) {
          if (kDebugMode) {
            debugPrint('[GroupSync] Failed to push loan ${loan.uuid}: $error');
          }
          // Don't rethrow, continue with other loans
        }
      }
    }
  }

  Future<LocalUser?> _ensureLocalUser({
    required String remoteId,
    String? username,
    required DateTime createdAtFallback,
  }) async {
    var localUser = await _userDao.findByRemoteId(remoteId);

    // If user exists, optionally update username if it was a placeholder
    if (localUser != null) {
      if (username != null &&
          (localUser.username.startsWith('miembro_') ||
              localUser.username.isEmpty)) {
        await _userDao.updateUserFields(
          userId: localUser.id,
          entry: LocalUsersCompanion(
            username: Value(username),
            updatedAt: Value(DateTime.now()),
          ),
        );
        return _userDao.getById(localUser.id);
      }
      return localUser;
    }

    final placeholderUsername = username ??
        () {
          final sanitizedId = remoteId.replaceAll(RegExp('[^a-zA-Z0-9]'), '');
          final suffix = sanitizedId.isNotEmpty
              ? (sanitizedId.length >= 8
                  ? sanitizedId.substring(0, 8)
                  : sanitizedId.padRight(8, '0'))
              : '00000000';
          return 'miembro_$suffix';
        }();

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

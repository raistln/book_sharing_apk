import 'package:drift/drift.dart';
import '../../data/local/database.dart';
import '../../services/supabase_loan_service.dart';
import '../local/sync_cursor_dao.dart';
import 'dart:developer' as developer;

class SupabaseLoanSyncRepository {
  final AppDatabase _db;
  final SupabaseLoanService _api;
  final SyncCursorDao _syncCursorDao;

  SupabaseLoanSyncRepository(this._db, this._api, this._syncCursorDao);

  Future<void> syncLoans(String userId) async {
    try {
      await _pushLocalChanges(userId);
      await _pullRemoteChanges(userId);
    } catch (e, stack) {
      developer.log('Error syncing loans', error: e, stackTrace: stack);
      rethrow;
    }
  }

  Future<void> _pushLocalChanges(String userId) async {
    // Since Drift joins with same table are tricky without aliases,
    // let's fetch loans first, then resolve UUIDs.
    final dirtyLoans = await (_db.select(_db.loans)
          ..where((l) => l.isDirty.equals(true)))
        .get();

    if (dirtyLoans.isEmpty) return;

    // Resolve dependencies
    final bookIds = dirtyLoans.map((l) => l.bookId).whereType<int>().toSet();
    final userIds = dirtyLoans
        .map((l) => [l.borrowerUserId, l.lenderUserId])
        .expand((i) => i)
        .whereType<int>()
        .toSet();

    final books =
        await (_db.select(_db.books)..where((b) => b.id.isIn(bookIds))).get();
    final users = await (_db.select(_db.localUsers)
          ..where((u) => u.id.isIn(userIds)))
        .get();

    final bookMap = {for (var b in books) b.id: b.uuid};
    final userMap = {for (var u in users) u.id: u.remoteId ?? u.uuid};

    final loansPayload = dirtyLoans
        .map((l) {
          final bookUuid = l.bookId != null ? bookMap[l.bookId] : null;
          final borrowerUuid =
              l.borrowerUserId != null ? userMap[l.borrowerUserId] : null;
          final lenderUuid = userMap[l.lenderUserId] ?? userId;

          // Bug #6 Fix: Validation guards
          if (l.sharedBookId == null && bookUuid == null) {
            developer.log(
                'Skipping loan ${l.id} push: No sharedBookId and no bookUuid.',
                name: 'SupabaseLoanSyncRepository');
            return null;
          }
          if (l.borrowerUserId != null && borrowerUuid == null) {
            developer.log(
                'Skipping loan ${l.id} push: borrowerUserId is set but borrowerUuid is missing (not synced yet?).',
                name: 'SupabaseLoanSyncRepository');
            return null;
          }

          return {
            'uuid': l.uuid,
            'shared_book_id': l.sharedBookId,
            'book_uuid': bookUuid,
            'borrower_user_id': borrowerUuid,
            'lender_user_id': lenderUuid,
            'external_borrower_name': l.externalBorrowerName,
            'external_borrower_contact': l.externalBorrowerContact,
            'status': l.status,
            'requested_at': l.requestedAt.toIso8601String(),
            'approved_at': l.approvedAt?.toIso8601String(),
            'due_date': l.dueDate?.toIso8601String(),
            'lender_returned_at': l.lenderReturnedAt?.toIso8601String(),
            'borrower_returned_at': l.borrowerReturnedAt?.toIso8601String(),
            'returned_at': l.returnedAt?.toIso8601String(),
            'created_at': l.createdAt.toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
            'is_deleted': l.isDeleted,
          };
        })
        .whereType<Map<String, dynamic>>()
        .toList();

    // 2. Upsert to Supabase
    await _api.upsertLoans(loansPayload);

    // 3. Mark as clean locally
    await _db.batch((batch) {
      for (final loan in dirtyLoans) {
        batch.update(
          _db.loans,
          LoansCompanion(
            isDirty: const Value(false),
            syncedAt: Value(DateTime.now()),
          ),
          where: (t) => t.id.equals(loan.id),
        );
      }
    });
  }

  Future<void> _pullRemoteChanges(String userId) async {
    final since = await _syncCursorDao.getCursor('loans');

    final remoteLoans = await _api.fetchUserLoans(userId: userId, since: since);

    if (remoteLoans.isEmpty) return;

    // Collect UUIDs to resolve
    final bookUuids = <String>{};
    final userUuids = <String>{};

    for (var data in remoteLoans) {
      if (data['book_uuid'] != null) bookUuids.add(data['book_uuid'] as String);
      if (data['borrower_user_id'] != null) {
        userUuids.add(data['borrower_user_id'] as String);
      }
      if (data['lender_user_id'] != null) {
        userUuids.add(data['lender_user_id'] as String);
      }
    }

    // Resolve to IDs
    // Note: If sync is incomplete, we might miss some books/users.
    // Ideally we should sync users/books first or fetch missing ones.
    // For now, we ignore if missing (loan will have null FK or fail if strictly required).
    final books = await (_db.select(_db.books)
          ..where((b) => b.uuid.isIn(bookUuids)))
        .get();
    final users = await (_db.select(_db.localUsers)
          ..where((u) => u.remoteId.isIn(userUuids)))
        .get();

    final bookIdMap = {for (var b in books) b.uuid: b.id};
    final userIdMap = {for (var u in users) u.remoteId: u.id};

    final missingUserUuids = userUuids
        .where((uuid) => uuid.isNotEmpty && !userIdMap.containsKey(uuid))
        .toList();
    for (final uuid in missingUserUuids) {
      final ensuredId = await _ensureLocalUserId(
        remoteId: uuid,
        createdAtFallback: DateTime.now(),
      );
      if (ensuredId != null) {
        userIdMap[uuid] = ensuredId;
      }
    }

    for (final data in remoteLoans) {
      final uuid = data['uuid'] as String;
      final updatedAt = DateTime.parse(data['updated_at'] as String);

      final bookUuid = data['book_uuid'] as String?;
      final borrowerUuid = data['borrower_user_id'] as String?;
      final lenderUuid = data['lender_user_id'] as String?;

      final bookId = bookUuid != null ? bookIdMap[bookUuid] : null;
      final borrowerId = borrowerUuid != null ? userIdMap[borrowerUuid] : null;
      final lenderId = lenderUuid != null ? userIdMap[lenderUuid] : null;

      if (lenderId == null) {
        developer.log(
          'Loan $uuid ignored: lender UUID $lenderUuid not found locally.',
          name: 'SupabaseLoanSyncRepository',
        );
        continue;
      }

      // Bug #5 Fix: Check if local is dirty before overwriting
      final existing = await (_db.select(_db.loans)
            ..where((l) => l.uuid.equals(uuid)))
          .getSingleOrNull();

      if (existing != null) {
        if (existing.isDirty) {
          developer.log('Skipping loan $uuid download: Local changes pending.',
              name: 'SupabaseLoanSyncRepository');
          continue;
        }

        // Bug #14: Conflict resolution (only update if remote is newer)
        if (existing.updatedAt.isAfter(updatedAt)) {
          developer.log('Skipping loan $uuid download: Local record is newer.',
              name: 'SupabaseLoanSyncRepository');
          continue;
        }
      }

      await _db.into(_db.loans).insert(
            LoansCompanion(
              uuid: Value(uuid),
              sharedBookId: Value(data['shared_book_id'] as int?),
              bookId: Value(bookId),
              borrowerUserId: Value(borrowerId),
              lenderUserId: Value(lenderId),
              externalBorrowerName:
                  Value(data['external_borrower_name'] as String?),
              externalBorrowerContact:
                  Value(data['external_borrower_contact'] as String?),
              status: Value(data['status'] as String),
              requestedAt:
                  Value(DateTime.parse(data['requested_at'] as String)),
              approvedAt: Value(data['approved_at'] != null
                  ? DateTime.parse(data['approved_at'])
                  : null),
              dueDate: Value(data['due_date'] != null
                  ? DateTime.parse(data['due_date'])
                  : null),
              lenderReturnedAt: Value(data['lender_returned_at'] != null
                  ? DateTime.parse(data['lender_returned_at'])
                  : null),
              borrowerReturnedAt: Value(data['borrower_returned_at'] != null
                  ? DateTime.parse(data['borrower_returned_at'])
                  : null),
              returnedAt: Value(data['returned_at'] != null
                  ? DateTime.parse(data['returned_at'])
                  : null),
              createdAt: Value(DateTime.parse(data['created_at'] as String)),
              updatedAt: Value(updatedAt),
              isDeleted: Value(data['is_deleted'] as bool? ?? false),
              isDirty: const Value(false),
              syncedAt: Value(DateTime.now()),
            ),
            mode: InsertMode.insertOrReplace,
          );
    }

    // Update cursor with the max updatedAt from remote
    final maxUpdatedAt = remoteLoans
        .map((l) => DateTime.tryParse(l['updated_at'] as String? ?? ''))
        .whereType<DateTime>()
        .fold<DateTime?>(
            null, (max, d) => max == null || d.isAfter(max) ? d : max);

    if (maxUpdatedAt != null) {
      await _syncCursorDao.updateCursor('loans', maxUpdatedAt);
    }
  }

  Future<int?> _ensureLocalUserId({
    required String remoteId,
    required DateTime createdAtFallback,
  }) async {
    final existing = await (_db.select(_db.localUsers)
          ..where((u) => u.remoteId.equals(remoteId)))
        .getSingleOrNull();
    if (existing != null) {
      return existing.id;
    }

    final sanitizedId = remoteId.replaceAll(RegExp('[^a-zA-Z0-9]'), '');
    final suffix = sanitizedId.isNotEmpty
        ? (sanitizedId.length >= 8
            ? sanitizedId.substring(0, 8)
            : sanitizedId.padRight(8, '0'))
        : '00000000';
    final placeholderUsername = 'miembro_$suffix';
    final now = DateTime.now();

    try {
      final id = await _db.into(_db.localUsers).insert(
            LocalUsersCompanion.insert(
              uuid: remoteId,
              username: placeholderUsername,
              remoteId: Value(remoteId),
              isDirty: const Value(false),
              isDeleted: const Value(false),
              createdAt: Value(createdAtFallback),
              updatedAt: Value(now),
              syncedAt: Value(now),
            ),
          );
      return id;
    } catch (_) {
      final fallback = await (_db.select(_db.localUsers)
            ..where((u) => u.remoteId.equals(remoteId)))
          .getSingleOrNull();
      return fallback?.id;
    }
  }
}

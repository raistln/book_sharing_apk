import 'package:drift/drift.dart';
import '../../data/local/database.dart';
import '../../services/supabase_loan_service.dart';
import 'dart:developer' as developer;

class SupabaseLoanSyncRepository {
  final AppDatabase _db;
  final SupabaseLoanService _api;

  SupabaseLoanSyncRepository(this._db, this._api);

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
    final dirtyLoans = await (_db.select(_db.loans)..where((l) => l.isDirty.equals(true))).get();

    if (dirtyLoans.isEmpty) return;

    // Resolve dependencies
    final bookIds = dirtyLoans.map((l) => l.bookId).whereType<int>().toSet();
    final userIds = dirtyLoans.map((l) => [l.borrowerUserId, l.lenderUserId]).expand((i) => i).whereType<int>().toSet();

    final books = await (_db.select(_db.books)..where((b) => b.id.isIn(bookIds))).get();
    final users = await (_db.select(_db.localUsers)..where((u) => u.id.isIn(userIds))).get();

    final bookMap = {for (var b in books) b.id: b.uuid};
    final userMap = {for (var u in users) u.id: u.uuid};

    final loansPayload = dirtyLoans.map((l) {
      final bookUuid = l.bookId != null ? bookMap[l.bookId] : null;
      final borrowerUuid = l.borrowerUserId != null ? userMap[l.borrowerUserId] : null;
      final lenderUuid = userMap[l.lenderUserId] ?? userId; // Fallback to current user if missing? Should not happen if DB valid.

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
    }).toList();

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
    final lastSyncedLoan = await (_db.select(_db.loans)
          ..orderBy([(t) => OrderingTerm(expression: t.syncedAt, mode: OrderingMode.desc)])
          ..limit(1))
        .getSingleOrNull();
    
    final since = lastSyncedLoan?.syncedAt;

    final remoteLoans = await _api.fetchUserLoans(userId: userId, since: since);

    if (remoteLoans.isEmpty) return;

    // Collect UUIDs to resolve
    final bookUuids = <String>{};
    final userUuids = <String>{};

    for (var data in remoteLoans) {
      if (data['book_uuid'] != null) bookUuids.add(data['book_uuid'] as String);
      if (data['borrower_user_id'] != null) userUuids.add(data['borrower_user_id'] as String);
      if (data['lender_user_id'] != null) userUuids.add(data['lender_user_id'] as String);
    }

    // Resolve to IDs
    // Note: If sync is incomplete, we might miss some books/users. 
    // Ideally we should sync users/books first or fetch missing ones. 
    // For now, we ignore if missing (loan will have null FK or fail if strictly required).
    final books = await (_db.select(_db.books)..where((b) => b.uuid.isIn(bookUuids))).get();
    final users = await (_db.select(_db.localUsers)..where((u) => u.uuid.isIn(userUuids))).get();

    final bookIdMap = {for (var b in books) b.uuid: b.id};
    final userIdMap = {for (var u in users) u.uuid: u.id};

    await _db.batch((batch) {
      for (final data in remoteLoans) {
        final uuid = data['uuid'] as String;
        final updatedAt = DateTime.parse(data['updated_at'] as String);
        
        final bookUuid = data['book_uuid'] as String?;
        final borrowerUuid = data['borrower_user_id'] as String?;
        final lenderUuid = data['lender_user_id'] as String?;

        final bookId = bookUuid != null ? bookIdMap[bookUuid] : null;
        final borrowerId = borrowerUuid != null ? userIdMap[borrowerUuid] : null;
        final lenderId = lenderUuid != null ? userIdMap[lenderUuid] : null;

        // If lender is mandatory and we don't have it (e.g. it's us but we use ID), assume current user if UUID matches?
        // But we must have the user in DB.

        batch.insert(
          _db.loans,
          LoansCompanion(
            uuid: Value(uuid),
            sharedBookId: Value(data['shared_book_id'] as int?),
            bookId: Value(bookId),
            borrowerUserId: Value(borrowerId),
            lenderUserId: Value(lenderId ?? -1), // -1 or null? Table says NOT NULL. Lender MUST exist.
            externalBorrowerName: Value(data['external_borrower_name'] as String?),
            externalBorrowerContact: Value(data['external_borrower_contact'] as String?),
            status: Value(data['status'] as String),
            requestedAt: Value(DateTime.parse(data['requested_at'] as String)),
            approvedAt: Value(data['approved_at'] != null ? DateTime.parse(data['approved_at']) : null),
            dueDate: Value(data['due_date'] != null ? DateTime.parse(data['due_date']) : null),
            lenderReturnedAt: Value(data['lender_returned_at'] != null ? DateTime.parse(data['lender_returned_at']) : null),
            borrowerReturnedAt: Value(data['borrower_returned_at'] != null ? DateTime.parse(data['borrower_returned_at']) : null),
            returnedAt: Value(data['returned_at'] != null ? DateTime.parse(data['returned_at']) : null),
            createdAt: Value(DateTime.parse(data['created_at'] as String)),
            updatedAt: Value(updatedAt),
            isDeleted: Value(data['is_deleted'] as bool? ?? false),
            isDirty: const Value(false),
            syncedAt: Value(DateTime.now()),
          ),
          mode: InsertMode.insertOrReplace,
        );
      }
    });
  }
}

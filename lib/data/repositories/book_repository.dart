import 'dart:async';

import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../local/book_dao.dart';
import '../local/database.dart';
import '../local/group_dao.dart';
import '../../services/group_sync_controller.dart';
import '../../services/sync_service.dart';

class BookRepository {
  BookRepository(
    this._bookDao, {
    required GroupDao groupDao,
    GroupSyncController? groupSyncController,
    Uuid? uuid,
    this.bookSyncController,
  })  : _groupDao = groupDao,
        _groupSyncController = groupSyncController,
        _uuid = uuid ?? const Uuid();

  final BookDao _bookDao;
  final GroupDao _groupDao;
  final GroupSyncController? _groupSyncController;
  final Uuid _uuid;
  final SyncController? bookSyncController;

  static const _sharedStatuses = {'available', 'loaned', 'archived'};

  void _markGroupSyncPending() {
    _groupSyncController?.markPendingChanges();
  }

  void _scheduleSync() {
    final controller = bookSyncController;
    if (controller == null) {
      return;
    }

    controller.markPendingChanges();
    unawaited(controller.sync());
  }

  Stream<List<Book>> watchAll({int? ownerUserId}) =>
      _bookDao.watchActiveBooks(ownerUserId: ownerUserId);

  Future<List<Book>> fetchActiveBooks({int? ownerUserId}) =>
      _bookDao.getActiveBooks(ownerUserId: ownerUserId);

  Stream<List<BookReview>> watchReviews(int bookId) =>
      _bookDao.watchReviewsForBook(bookId);

  Future<List<BookReview>> fetchActiveReviews() => _bookDao.getActiveReviews();

  Future<int> addBook({
    required String title,
    String? author,
    String? isbn,
    String? barcode,
    String? coverPath,
    String status = 'available',
    String? notes,
    LocalUser? owner,
  }) async {
    final now = DateTime.now();
    final bookUuid = _uuid.v4();
    final bookId = await _bookDao.insertBook(
      BooksCompanion.insert(
        uuid: bookUuid,
        title: title,
        author: Value(author),
        isbn: Value(isbn),
        barcode: Value(barcode),
        coverPath: Value(coverPath),
        status: Value(status),
        notes: Value(notes),
        ownerUserId: owner != null ? Value(owner.id) : const Value.absent(),
        ownerRemoteId: owner?.remoteId != null
            ? Value(owner!.remoteId)
            : const Value.absent(),
        createdAt: Value(now),
        updatedAt: Value(now),
      ),
    );
    await _autoShareBook(
      bookId: bookId,
      bookUuid: bookUuid,
      status: status,
      timestamp: now,
      ownerUserId: owner?.id,
      ownerRemoteId: owner?.remoteId,
    );
    _scheduleSync();
    return bookId;
  }

  Future<int> addReview({
    required Book book,
    required int rating,
    String? review,
    required LocalUser author,
  }) async {
    final now = DateTime.now();

    final existing = await _bookDao.findReviewForUser(
      bookId: book.id,
      authorUserId: author.id,
    );

    if (existing != null) {
      await _bookDao.updateReview(
        reviewId: existing.id,
        entry: BookReviewsCompanion(
          rating: Value(rating),
          review: Value(review),
          authorRemoteId: author.remoteId != null
              ? Value(author.remoteId)
              : const Value.absent(),
          isDeleted: const Value(false),
          isDirty: const Value(true),
          syncedAt: const Value(null),
          updatedAt: Value(now),
        ),
      );
      _scheduleSync();
      return existing.id;
    }

    final reviewId = await _bookDao.insertReview(
      BookReviewsCompanion.insert(
        uuid: _uuid.v4(),
        bookId: book.id,
        bookUuid: book.uuid,
        authorUserId: author.id,
        authorRemoteId: author.remoteId != null
            ? Value(author.remoteId)
            : const Value.absent(),
        rating: rating,
        review: Value(review),
        isDirty: const Value(true),
        isDeleted: const Value(false),
        createdAt: Value(now),
        updatedAt: Value(now),
      ),
    );
    _scheduleSync();
    return reviewId;
  }

  Future<bool> updateBook(Book book) async {
    final now = DateTime.now();
    final updated = book.copyWith(
      updatedAt: now,
      isDirty: true,
    );
    final result = await _bookDao.updateBook(updated.toCompanion(true));
    if (result) {
      await _autoShareBook(
        bookId: book.id,
        bookUuid: book.uuid,
        status: updated.status,
        timestamp: now,
        ownerUserId: book.ownerUserId,
        ownerRemoteId: book.ownerRemoteId,
      );
    }
    _scheduleSync();
    return result;
  }

  Future<List<SharedBook>> deleteBook(Book book) async {
    final now = DateTime.now();
    await _bookDao.softDeleteBook(
      bookId: book.id,
      timestamp: now,
    );
    await _bookDao.softDeleteReviewsForBook(
      bookId: book.id,
      timestamp: now,
    );
    final removedSharedBooks =
        await _softDeleteSharedBooks(bookId: book.id, timestamp: now);
    if (removedSharedBooks.isNotEmpty) {
      _markGroupSyncPending();
    }
    _scheduleSync();
    return removedSharedBooks;
  }

  Future<Book?> findById(int id) => _bookDao.findById(id);

  bool _shouldShare(String status) => _sharedStatuses.contains(status);

  Future<void> _autoShareBook({
    required int bookId,
    required String bookUuid,
    required String status,
    required DateTime timestamp,
    int? ownerUserId,
    String? ownerRemoteId,
  }) async {
    if (ownerUserId == null) {
      return;
    }

    final shouldShare = _shouldShare(status);

    if (!shouldShare) {
      final removedSharedBooks =
          await _softDeleteSharedBooks(bookId: bookId, timestamp: timestamp);
      if (removedSharedBooks.isNotEmpty) {
        _markGroupSyncPending();
      }
      return;
    }

    final groups = await _groupDao.getGroupsForUser(ownerUserId);
    if (groups.isEmpty) {
      return;
    }

    final db = _groupDao.attachedDatabase;
    var changed = false;
    await db.transaction(() async {
      for (final group in groups) {
        final existing = await _groupDao.findSharedBookByGroupAndBook(
          groupId: group.id,
          bookId: bookId,
        );
        if (existing != null) {
          await _groupDao.updateSharedBookFields(
            sharedBookId: existing.id,
            entry: SharedBooksCompanion(
              isDeleted: const Value(false),
              isDirty: const Value(true),
              syncedAt: const Value(null),
              updatedAt: Value(timestamp),
              isAvailable: Value(status != 'loaned'),
            ),
          );
          changed = true;
          continue;
        }

        await _groupDao.insertSharedBook(
          SharedBooksCompanion.insert(
            uuid: _uuid.v4(),
            groupId: group.id,
            groupUuid: group.uuid,
            bookId: bookId,
            bookUuid: bookUuid,
            ownerUserId: ownerUserId,
            ownerRemoteId: ownerRemoteId != null
                ? Value(ownerRemoteId)
                : const Value.absent(),
            isAvailable: Value(status != 'loaned'),
            visibility: const Value('group'),
            isDirty: const Value(true),
            isDeleted: const Value(false),
            syncedAt: const Value(null),
            createdAt: Value(timestamp),
            updatedAt: Value(timestamp),
          ),
        );
        changed = true;
      }
    });

    if (changed) {
      _markGroupSyncPending();
    }
  }

  Future<List<SharedBook>> _softDeleteSharedBooks({
    required int bookId,
    required DateTime timestamp,
  }) async {
    final existing = await _groupDao.findSharedBooksByBookId(bookId);
    if (existing.isEmpty) {
      return const [];
    }

    for (final shared in existing) {
      await _groupDao.softDeleteSharedBook(
        sharedBookId: shared.id,
        timestamp: timestamp,
      );
    }
    return existing;
  }
}

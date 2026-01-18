import 'dart:async';
import 'dart:developer' as developer;

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

  void _markGroupSyncPending() {
    final controller = _groupSyncController;
    if (controller != null && controller.mounted) {
      controller.markPendingChanges();
    }
  }

  void _scheduleSync() {
    final controller = bookSyncController;
    if (controller != null && controller.mounted) {
      controller.markPendingChanges();
      unawaited(controller.sync());
    }
  }

  /// Shares all existing books (except private/archived) with a newly joined group
  Future<void> shareExistingBooksWithGroup({
    required Group group,
    required LocalUser owner,
  }) async {
    developer.log(
      '[shareExistingBooksWithGroup] Sharing existing books for user ${owner.id} with group ${group.id}',
      name: 'BookRepository',
    );

    final books = await fetchActiveBooks(ownerUserId: owner.id);
    final now = DateTime.now();
    var sharedCount = 0;

    for (final book in books) {
      if (!_shouldShare(book.status, book.isPhysical)) {
        developer.log(
          '[shareExistingBooksWithGroup] Skipping book ${book.id} (status: ${book.status}, physical: ${book.isPhysical})',
          name: 'BookRepository',
        );
        continue;
      }

      // Check if already shared
      final existing = await _groupDao.findSharedBookByGroupAndBook(
        groupId: group.id,
        bookId: book.id,
      );

      if (existing != null) {
        developer.log(
          '[shareExistingBooksWithGroup] Book ${book.id} already shared with group ${group.id}',
          name: 'BookRepository',
        );
        continue;
      }

      // Share the book
      await _groupDao.insertSharedBook(
        SharedBooksCompanion.insert(
          uuid: _uuid.v4(),
          groupId: group.id,
          groupUuid: group.uuid,
          bookId: book.id,
          bookUuid: book.uuid,
          ownerUserId: owner.id,
          ownerRemoteId: owner.remoteId != null
              ? Value(owner.remoteId!)
              : const Value.absent(),
          isAvailable: Value(book.status != 'loaned'),
          visibility: const Value('group'),
          isDirty: const Value(true),
          isDeleted: const Value(false),
          syncedAt: const Value(null),
          createdAt: Value(now),
          updatedAt: Value(now),
        ),
      );
      sharedCount++;
    }

    developer.log(
      '[shareExistingBooksWithGroup] Shared $sharedCount books with group ${group.id}',
      name: 'BookRepository',
    );

    // Note: Sync is handled by the controller via syncOnCriticalEvent()
    // No need to mark pending here to avoid duplicate syncs
  }

  Stream<List<Book>> watchAll({int? ownerUserId}) =>
      _bookDao.watchActiveBooks(ownerUserId: ownerUserId);

  Future<List<Book>> fetchActiveBooks({int? ownerUserId}) =>
      _bookDao.getActiveBooks(ownerUserId: ownerUserId);

  Stream<Book?> watchBook(int bookId) => _bookDao.watchBookById(bookId);

  Future<List<BookReview>> fetchActiveReviews() => _bookDao.getActiveReviews();

  Stream<List<BookReview>> watchReviews(int bookId) =>
      _bookDao.watchReviewsForBook(bookId);

  Future<int> addBook({
    required String title,
    String? author,
    String? isbn,
    String? barcode,
    String? coverPath,
    String status = 'available',
    String? notes,
    bool isRead = false,
    LocalUser? owner,
    String? genre,
    bool isPhysical = true,
    int? pageCount,
    int? publicationYear,
  }) async {
    // Check for duplicates
    Book? existingBook;

    // First check by ISBN if provided
    if (isbn != null && isbn.trim().isNotEmpty) {
      existingBook = await _bookDao.findByIsbn(
        isbn.trim(),
        ownerUserId: owner?.id,
      );
      if (existingBook != null) {
        throw Exception('¡Oye! Ya tienes ese libro en tu biblioteca 📚');
      }
    }

    // Then check by title + author if both provided
    if (author != null && author.trim().isNotEmpty) {
      existingBook = await _bookDao.findByTitleAndAuthor(
        title.trim(),
        author.trim(),
        ownerUserId: owner?.id,
      );
      if (existingBook != null) {
        throw Exception('¡Oye! Ya tienes ese libro en tu biblioteca 📚');
      }
    }

    final now = DateTime.now();
    final bookUuid = _uuid.v4();
    final bookId = await _bookDao.insertBook(
      BooksCompanion.insert(
        uuid: bookUuid,
        title: title,
        author: (author != null && author.trim().isNotEmpty)
            ? Value(author.trim())
            : const Value.absent(),
        isbn: (isbn != null && isbn.trim().isNotEmpty)
            ? Value(isbn.trim())
            : const Value.absent(),
        barcode: (barcode != null && barcode.trim().isNotEmpty)
            ? Value(barcode.trim())
            : const Value.absent(),
        coverPath: Value(coverPath),
        status: Value(status),
        notes: Value(notes),
        isRead: Value(isRead),
        readAt: isRead ? Value(now) : const Value.absent(),
        ownerUserId: owner != null ? Value(owner.id) : const Value.absent(),
        ownerRemoteId: owner?.remoteId != null
            ? Value(owner!.remoteId)
            : const Value.absent(),
        createdAt: Value(now),
        updatedAt: Value(now),
        genre: Value(genre),
        isPhysical: Value(isPhysical),
        pageCount: Value(pageCount),
        publicationYear: Value(publicationYear),
      ),
    );
    await _autoShareBook(
      bookId: bookId,
      bookUuid: bookUuid,
      status: status,
      isPhysical: isPhysical,
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

    // Don't use copyWith here - it would overwrite changes from the format null values are converted to Value(null)
    // instead of Value.absent(). This allows us to actually set fields to null.
    var companion = book.toCompanion(false);

    // Enforce readAt logic
    if (book.isRead) {
      // If marked as read but no date set, set it to now
      if (book.readAt == null) {
        companion = companion.copyWith(readAt: Value(now));
      }
    } else {
      // If marked as unread, clear the date
      companion = companion.copyWith(readAt: const Value(null));
    }

    companion = companion.copyWith(
      updatedAt: Value(now),
      isDirty: const Value(true),
    );

    final result = await _bookDao.updateBook(companion);
    if (result) {
      await _autoShareBook(
        bookId: book.id,
        bookUuid: book.uuid,
        status: book.status,
        isPhysical: book.isPhysical,
        timestamp: now,
        ownerUserId: book.ownerUserId,
        ownerRemoteId: book.ownerRemoteId,
      );
    }
    _scheduleSync();
    return result;
  }

  Future<List<SharedBook>> deleteBook(Book book) async {
    // Check if book has any active or pending loans
    final sharedBooks = await _groupDao.findSharedBooksByBookId(book.id);

    for (final sharedBook in sharedBooks) {
      final activeLoans =
          await _groupDao.getActiveLoansForSharedBook(sharedBook.id);
      if (activeLoans.isNotEmpty) {
        // Check if any loans are active or pending
        final hasActivePendingLoans = activeLoans.any((loan) =>
            loan.status == 'active' ||
            loan.status == 'requested' ||
            loan.status == 'requested');

        if (hasActivePendingLoans) {
          throw Exception(
              'No puedes eliminar este libro porque tiene préstamos activos o pendientes. '
              'Por favor, completa o cancela todos los préstamos antes de eliminarlo.');
        }
      }
    }

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

  bool _shouldShare(String status, bool isPhysical) {
    // Non-physical books (digital) are never shared
    if (!isPhysical) return false;

    // Don't share private or archived books
    // Only share available and loaned books
    return status == 'available' || status == 'loaned';
  }

  /// Mapea el status local a visibility e isAvailable para SharedBooks
  (String visibility, bool isAvailable) _mapStatusToSharedBookValues(
      String status) {
    switch (status) {
      case 'private':
        return ('private', false);
      case 'archived':
        return ('archived', false);
      case 'loaned':
        return ('group', false);
      case 'available':
      default:
        return ('group', true);
    }
  }

  Future<void> _autoShareBook({
    required int bookId,
    required String bookUuid,
    required String status,
    required bool isPhysical,
    required DateTime timestamp,
    int? ownerUserId,
    String? ownerRemoteId,
  }) async {
    if (ownerUserId == null) {
      developer.log('[_autoShareBook] ownerUserId is null, skipping.',
          name: 'BookRepository');
      return;
    }

    final shouldShare = _shouldShare(status, isPhysical);
    developer.log(
        '[_autoShareBook] Processing book $bookId (status: $status, isPhysical: $isPhysical, shouldShare: $shouldShare)',
        name: 'BookRepository');

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
      developer.log(
          '[_autoShareBook] User $ownerUserId has no groups to share with.',
          name: 'BookRepository');
      return;
    }

    developer.log(
        '[_autoShareBook] Sharing book $bookId with ${groups.length} groups.',
        name: 'BookRepository');

    final db = _groupDao.attachedDatabase;
    var changed = false;
    await db.transaction(() async {
      for (final group in groups) {
        final existing = await _groupDao.findSharedBookByGroupAndBook(
          groupId: group.id,
          bookId: bookId,
        );
        if (existing != null) {
          final (visibility, isAvailable) =
              _mapStatusToSharedBookValues(status);
          await _groupDao.updateSharedBookFields(
            sharedBookId: existing.id,
            entry: SharedBooksCompanion(
              visibility: Value(visibility),
              isAvailable: Value(isAvailable),
              isDirty: const Value(true),
              syncedAt: const Value(null),
              updatedAt: Value(timestamp),
            ),
          );
          changed = true;
          continue;
        }

        final (visibility, isAvailable) = _mapStatusToSharedBookValues(status);
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
            isAvailable: Value(isAvailable),
            visibility: Value(visibility),
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

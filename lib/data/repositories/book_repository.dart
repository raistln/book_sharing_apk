import 'dart:async';

import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../local/book_dao.dart';
import '../local/database.dart';
import '../../services/sync_service.dart';

class BookRepository {
  BookRepository(this._dao, {Uuid? uuid, this.bookSyncController})
      : _uuid = uuid ?? const Uuid();

  final BookDao _dao;
  final Uuid _uuid;
  final SyncController? bookSyncController;

  void _scheduleSync() {
    final controller = bookSyncController;
    if (controller == null) {
      return;
    }

    controller.markPendingChanges();
    unawaited(controller.sync());
  }

  Stream<List<Book>> watchAll() => _dao.watchActiveBooks();

  Future<List<Book>> fetchActiveBooks() => _dao.getActiveBooks();

  Stream<List<BookReview>> watchReviews(int bookId) =>
      _dao.watchReviewsForBook(bookId);

  Future<List<BookReview>> fetchActiveReviews() => _dao.getActiveReviews();

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
    final bookId = await _dao.insertBook(
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

    final existing = await _dao.findReviewForUser(
      bookId: book.id,
      authorUserId: author.id,
    );

    if (existing != null) {
      await _dao.updateReview(
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

    final reviewId = await _dao.insertReview(
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
    final updated = book.copyWith(
      updatedAt: DateTime.now(),
      isDirty: true,
    );
    final result = await _dao.updateBook(updated.toCompanion(true));
    _scheduleSync();
    return result;
  }

  Future<void> deleteBook(Book book) async {
    final now = DateTime.now();
    await _dao.softDeleteBook(
      bookId: book.id,
      timestamp: now,
    );
    await _dao.softDeleteReviewsForBook(
      bookId: book.id,
      timestamp: now,
    );
    _scheduleSync();
  }

  Future<Book?> findById(int id) => _dao.findById(id);
}

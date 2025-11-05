import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../local/book_dao.dart';
import '../local/database.dart';

class BookRepository {
  BookRepository(this._dao, {Uuid? uuid}) : _uuid = uuid ?? const Uuid();

  final BookDao _dao;
  final Uuid _uuid;

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
  }) {
    final now = DateTime.now();
    final bookUuid = _uuid.v4();
    return _dao.insertBook(
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
      return existing.id;
    }

    return _dao.insertReview(
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
  }

  Future<bool> updateBook(Book book) {
    final updated = book.copyWith(
      updatedAt: DateTime.now(),
      isDirty: true,
    );
    return _dao.updateBook(updated.toCompanion(true));
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
  }

  Future<Book?> findById(int id) => _dao.findById(id);
}
